TARGET=blink

all: $(TARGET).bin
 
	
$(TARGET).o: $(TARGET).s
	as -mcpu=cortex-m3 -adhl -g -o $@ $< > $(TARGET).lst

$(TARGET).elf: $(TARGET).o
	ld -Ttext 0x8000000 $(TARGET).o -o $(TARGET).elf
   
$(TARGET).bin: $(TARGET).elf   
	objcopy -S -O binary $(TARGET).elf $(TARGET).bin
	size $(TARGET).elf
	
clean:
	rm *.elf *.o *.bin
