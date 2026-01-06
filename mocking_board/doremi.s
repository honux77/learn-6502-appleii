; Mockingboard: play DO-RE-MI (Slot 4, AY channel A)
; Build: ca65 -> ld65 with your minimal beep.cfg
; Run in monitor: 800G

        .setcpu "6502"
        .segment "CODE"
        .org $0800

; ---- Slot 4 base ($C400) ----
BASE    = $C400
ORB1    = BASE+$00
ORA1    = BASE+$01
DDRB1   = BASE+$02
DDRA1   = BASE+$03

; ---- Function codes ----
FC_INACTIVE     = $04
FC_SET_REG      = $07
FC_WRITE_DATA   = $06

; ---- AY register numbers ----
AY_TONE_A_FINE   = 0
AY_TONE_A_COARSE = 1
AY_MIXER         = 7
AY_VOL_A         = 8

; ------------------------------------------------------------
start:
        sei

        ; VIA ports output
        lda #$FF
        sta DDRB1
        sta DDRA1

        lda #FC_INACTIVE
        sta ORB1

        ; Mixer: Tone A ON (bit0=0), Noise A OFF (bit3=1)
        ; Other channels off-ish as well
        lda #AY_MIXER
        ldy #$38
        jsr ay_write

        ; Volume A max
        lda #AY_VOL_A
        ldy #$0F
        jsr ay_write

        ; --- play C4, D4, E4 ---
        ldx #$00
play_loop:
        ; load period from table (fine, coarse)
        lda note_table_fine,x
        tay
        lda #AY_TONE_A_FINE
        jsr ay_write

        lda note_table_coarse,x
        tay
        lda #AY_TONE_A_COARSE
        jsr ay_write

        ; hold note
        jsr note_delay

        ; short gap (volume 0)
        lda #AY_VOL_A
        ldy #$00
        jsr ay_write
        jsr gap_delay
        lda #AY_VOL_A
        ldy #$0F
        jsr ay_write

        inx

                cpx #3
                bcc play_loop   ; 0,1,2까지 반복
                ldx #0          ; 인덱스 초기화
                jmp play_loop   ; 무한 반복

endless:
        jmp endless

; ------------------------------------------------------------
; ay_write: A=reg#, Y=value
; ------------------------------------------------------------
ay_write:
        pha

        ; Set register #
        sta ORA1
        lda #FC_SET_REG
        sta ORB1
        lda #FC_INACTIVE
        sta ORB1

        ; Write value
        tya
        sta ORA1
        lda #FC_WRITE_DATA
        sta ORB1
        lda #FC_INACTIVE
        sta ORB1

        pla
        rts

; ------------------------------------------------------------
; Delays (tune by taste)
; ------------------------------------------------------------
note_delay:
        ldx #$70
nd1:    ldy #$FF
nd2:    dey
        bne nd2
        dex
        bne nd1
        rts

gap_delay:
        ldx #$20
gd1:    ldy #$FF
gd2:    dey
        bne gd2
        dex
        bne gd1
        rts

; ------------------------------------------------------------
; AY Tone period table (12-bit: coarse<<8 | fine)
; These are "handy" values that sound like C4-D4-E4-ish.
; If you want perfect tuning, we'll compute from AY clock.
; ------------------------------------------------------------
note_table_fine:
        .byte $D5, $FA, $20     ; C4, D4, E4 (fine, 예시값)
note_table_coarse:
        .byte $01, $01, $01     ; coarse (동일, fine만 극적으로 차이)

        .byte 0
