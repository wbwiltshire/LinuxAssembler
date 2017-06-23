AS=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=
SOURCES=main.s memCopy.s memSet.s memCompare.s
EXECUTABLE=memfunctions
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(AS) $(AFLAGS) $< -o $@ 

clean:
	rm -f memfunctions
	rm -f *.o
