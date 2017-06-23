ASM=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=
SOURCES=main.s 
EXECUTABLE=readkeyboard
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f readkeyboard
	rm -f *.o
