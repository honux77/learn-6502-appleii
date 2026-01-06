TARGET = beep doremi

all: $(TARGET).bin

$(TARGET).o: $(TARGET).s
	ca65 $< -o $@

$(TARGET).bin: $(TARGET).o simple.cfg
	ld65 $< -C simple.cfg -o $@

clean:
	rm -f *.o *.bin
