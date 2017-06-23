CA=nasm
CFLAGS=-f elf64 
LD=ld
LDFLAGS=-dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e main
SOURCES=main.asm
EXECUTABLE=hola
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
