#define AY_ADDR   (*(volatile unsigned char*)0xC400)
#define AY_DATA   (*(volatile unsigned char*)0xC401)

void ay_write(unsigned char r, unsigned char v) {
    AY_ADDR = r;
    AY_DATA = v;
}

/* 아주 단순한 지연 루프 */
void delay(unsigned int t) {
    volatile unsigned int i;
    for (i = 0; i < t; i++) ;
}

void play_tone(unsigned int period) {
    ay_write(0, period & 0xFF);
    ay_write(1, (period >> 8) & 0x0F);
    ay_write(8, 0x0F);
}

void silence(void) {
    ay_write(8, 0x00);
}

int main(void) {
    ay_write(7, 0b11111110);   // mixer: channel A tone ON

    play_tone(0x0EE);  // DO
    delay(20000);

    play_tone(0x0C8);  // RE
    delay(20000);

    play_tone(0x0AE);  // MI
    delay(20000);

    silence();
    return 0;
}
