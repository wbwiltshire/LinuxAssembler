CC=gcc
CA=as
CFLAGS=
#AFLAGS=-gstabs
AFLAGS=
LD=ld
LDFLAGS=
SOURCES=
EXECUTABLE=

all: echoargs showargs

echoargs: main.s
	$(CC) $(CFLAGS) $< -o $@ 

showargs: showargs.o
	$(LD) $< -o $@ $(LDFLAGS)

showargs.o: showargs.s
	$(CA) $(AFLAGS) $< -o $@ 

clean:
	rm -f echoargs showargs
	rm -f *.o
