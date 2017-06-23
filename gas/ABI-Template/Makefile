AS=as
AFLAGS=--gstabs
LD=ld
LDFLAGS=
SOURCES=main.s function.s 
EXECUTABLE=template
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(AS) $(AFLAGS) $< -o $@

clean:
	rm -f template
	rm -f *.o
