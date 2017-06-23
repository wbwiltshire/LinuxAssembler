CA=nasm
CFLAGS=-f elf64 
LD=ld
LDFLAGS=
SOURCES=main.asm
EXECUTABLE=helloworld
OBJECTS=$(SOURCES:.asm=.o)

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) $(OBJECTS) -o $@ $(LDFLAGS)
	chmod 755 $(EXECUTABLE)

%.o: %.asm
	$(CA) $(CFLAGS) $< -o $@

clean:
	rm -f $(EXECUTABLE)
	rm -f *.o
