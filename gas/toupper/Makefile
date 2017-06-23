ASM=as
CA=gcc
AFLAGS=--gstabs
CFLAGS=-c -Wall
LD=ld
LDFLAGS=
SOURCES=main.s toUpper.s 
EXECUTABLE=toupper
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@ 

clean:
	rm -f toupper
	rm -f *.o
