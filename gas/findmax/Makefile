CA=as
CFLAGS=-c -Wall
LD=ld
LDFLAGS=
SOURCES=main.s intToString.s
EXECUTABLE=findmax
OBJECTS=$(SOURCES:.s=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)

%.o: %.asm
	$(CA) $(CFLAGS) $< -o $@ 

clean:
	rm -f findmax
	rm -f *.o
