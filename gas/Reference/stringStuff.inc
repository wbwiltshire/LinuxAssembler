# PURPOSE: Provide reference examples of string processing

	# Conventions:	
	# rsi always points to source
	# rdi always points to destination
	# rcx typically used as count register
	# movs : moves and then auto-increments rsi and rdi
	
	# Move single byte memory to memory (rsi/rdi auto-increment)
	lea			sourceString, %rsi	# load address of string into rsi
	lea			destination, %rdi	# load destination address of string into rdi
	movsb							# moves single byte from memory location to memory location
	movsw							# moves 2 more byte (word)
	movsl							# moves 4 more bytes (long) for a total of 7 bytes
	
	# set direction flag to 1 (0 -> rsi/rdi increment, 1-> rsi/rdi decremented on move)
	std								

	# Move single byte repeatedly on count
	lea			sourceString, %rsi	# load address of string into rsi
	lea			destinationRep, %rdi # load destination address of string into rdi
	mov			$11, %rcx			# number of times to repeat
	cld								# clear direction flag to 0(0 -> rsi/rdi increment, 1-> rsi/rdi decremented on move)
	rep			movsb				# repeatedly moves string of bytes from memory location to memory location 
	
	# Store -- Good way to initialize memory
	lea			destinationStos, %rdi # load destination address of string into rdi
	mov			$0xff, %rax			# initialization value
	mov			$11, %rcx			# count
	rep			stosb				# initialize destination with 11 bytes of zeros from rax (actually al)
	
	
	# Compare -- cmps subtracts destination string from source string and sets the EFLAGS register
	lea			sourceString, %rsi	# load address of string into rsi
	lea			destinationRep, %rdi 	# load destination address of string into rdi
	mov			$11, %rcx			# count
	cld								# clear direction flag to 0(0 -> rsi/rdi increment, 1-> rsi/rdi decremented on move)
	rep			cmpsb				# repeatedly compares string of bytes for count 
									# ZF should be set

	lea			sourceString, %rsi	# load address of string into rsi
	lea			destination, %rdi 	# load destination address of string into rdi
	mov			$11, %rcx			# count
	cld								# clear direction flag to 0(0 -> rsi/rdi increment, 1-> rsi/rdi decremented on move)
	rep			cmpsb				# repeatedly compares string of bytes for count 
									# ZF will not be set
	
	# Scan
	lea			destinationRep, %rdi 	# load address of string to search into rdi
	xor     	%rax, %rax          # search for null string terminator '\0'
	xor     	%rcx, %rcx          # set max string len
	not     	%rcx
	cld                             # clear the direction flag
	repne   	scasb               # scan string byte by byte
	jnz			stringExit			# ZF isn't set if no match is found
	not     	%rcx                # else, compute the match position
									# rcx now has position of the match
				
stringExit:
