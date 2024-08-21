; Simple graphics program for Apple II
; Draws a diagonal line in low-resolution graphics mode

; Constants
LORES_BASE = $0400   ; Base address for low-res graphics
COUT = $FDED         ; Output character routine

    ORG $0300    ; Start our program at $0300

START:  JSR $FB40    ; Set graphics mode (GR command)
    LDA #0       ; Black color
    STA $30      ; Store color in zero page

LOOP:   
    LDX $30      ; Load current position
    LDA #0       ; Black color
    STA LORES_BASE,X ; Draw pixel
    INC $30      ; Move to next position
    LDA $30      ; Check if we've reached the end
    CMP #40      ; 40 is the width of the screen
    BNE LOOP     ; If not, continue drawing

    RTS          ; Return to BASIC

; To run the program, use:
; CALL 768