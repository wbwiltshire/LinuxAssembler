ASM=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=-dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e _start
SOURCES=main.s printElapsed.s getArgs.s
EXECUTABLE=reference
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f $(EXECUTABLE)
	rm -f *.o
