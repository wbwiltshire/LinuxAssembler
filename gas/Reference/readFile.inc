# PURPOSE: Provide reference example opening and reading from a file

openFiles:
	# Open input file
 	mov 	$SYS_OPEN, %rax			# open syscall
	mov		$1,%rcx
	mov		argPtrs(,%rcx,8), %rdi	# move address of input file name to %rbx
	mov		$O_RDONLY, %rsi			# set to read only
	mov		$RDONLY_PERMS, %rdx		# doesn't really matter for reading
	syscall							# Open File
	cmp		$0, %rax
	jl		fileError
	mov		%rax, inFileFD			# save file handle

readLoop:
	# Start Read Loop
	mov		$SYS_READ, %rax			# read syscall
	mov		inFileFD, %rdi			# set file handle
	mov		$BUFFER_DATA, %rsi		# set buffer address and size
	mov		$BUFFER_SIZE, %rdx	
	syscall							# Read from file
	cmp		$EOF, %rax				# check if end of file
	jle		endReadLoop
	mov		$BUFFER_DATA, %rcx		# get address of buffer data 

	# Continue with reading
	jmp		readLoop

endReadLoop:
	# Close files					# No error checking needed on close
	mov		$SYS_CLOSE, %rax		# close syscall
	mov 	(inFileFD), %rdi 		# file handle
	syscall							# Close file
