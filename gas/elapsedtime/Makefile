ASM=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=
SOURCES=main.s printElapsed.s
EXECUTABLE=elapsedtime
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f elapsedtime
	rm -f *.o
