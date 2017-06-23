ASM=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=
SOURCES=main.s toHex.s toChars.s memCopy.s printElapsed.s print32.s
EXECUTABLE=hexdump
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f hexdump
	rm -f *.o
