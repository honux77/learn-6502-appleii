; Mockingboard minimal tone demo (Slot 4, VIA #1, AY chip #1)
; ca65 syntax
;
; How to run (Monitor):
;   assemble/link to load at $0800, then in monitor: 800G
;
; If no sound:
;   - Apple2TS 설정에서 Mockingboard를 Slot 4로 활성화했는지 확인
;   - Slot이 다르면 BASE 주소를 바꿔야 함 (아래 BASE)

        .setcpu "6502"
        .segment "CODE"
        .org $0800

; --------- Mockingboard addresses (Slot 4 base: $C400) ----------
; Slot S base is $C000 + (S * $0100)  -> slot 4 = $C400
BASE    = $C400

ORB1    = BASE+$00    ; VIA port B  (function codes)
ORA1    = BASE+$01    ; VIA port A  (data: reg#, value)
DDRB1   = BASE+$02
DDRA1   = BASE+$03

; --------- Function codes (common Mockingboard Sound II style) ---
FC_INACTIVE     = $04
FC_SET_REG      = $07
FC_WRITE_DATA   = $06
; (Reset often $00, but not needed for this minimal demo)

; --------- AY register numbers ----------
AY_TONE_A_FINE  = 0
AY_TONE_A_COARSE= 1
AY_MIXER        = 7
AY_VOL_A        = 8

; ---------------------------------------------------------------
start:
        sei                     ; (minimal) 인터럽트 끔

        ; VIA 포트를 모두 출력으로
        lda #$FF
        sta DDRB1
        sta DDRA1

        ; 안전하게 Inactive 상태로
        lda #FC_INACTIVE
        sta ORB1

        ; ---- AY 세팅: 채널 A 톤만 켜기 ----
        ; Mixer (R7): bit0=1이면 Tone A OFF, 0이면 ON
        ;             bit3=1이면 Noise A OFF, 0이면 ON
        ; 여기서는 톤 A ON, 노이즈 OFF로 설정
        ; => bit0=0 (톤A ON), bit3=1 (노이즈A OFF)
        ; 다른 채널도 꺼두는 값으로 대충 0b00111000 = $38 정도 사용
        lda #AY_MIXER
        ldy #$38
        jsr ay_write

        ; ---- 주파수 설정 (Tone A period) ----
        ; period = 12-bit (fine + coarse)
        ; 아래 값은 "대충 잘 들리는" 값으로 잡은 것 (정확한 음정 목적 아님)
        lda #AY_TONE_A_FINE
        ldy #$A0
        jsr ay_write

        lda #AY_TONE_A_COARSE
        ldy #$01
        jsr ay_write

        ; ---- 볼륨 설정 (0~15) ----
        lda #AY_VOL_A
        ldy #$0F            ; 최대 볼륨
        jsr ay_write

hold:
        jsr delay
        jmp hold

; ---------------------------------------------------------------
; ay_write
;  in: A = AY register number (0..15)
;      Y = value
; ---------------------------------------------------------------
ay_write:
        pha                 ; reg# 저장

        ; 1) Set register number
        sta ORA1            ; ORA <- reg#
        lda #FC_SET_REG
        sta ORB1
        lda #FC_INACTIVE
        sta ORB1

        ; 2) Write data
        tya
        sta ORA1            ; ORA <- value
        lda #FC_WRITE_DATA
        sta ORB1
        lda #FC_INACTIVE
        sta ORB1

        pla
        rts

; ---------------------------------------------------------------
; crude delay loop
; ---------------------------------------------------------------
delay:
        ldx #$40
d1:     ldy #$FF
d2:     dey
        bne d2
        dex
        bne d1
        rts

        .byte 0
