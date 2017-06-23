# PURPOSE: Provide reference examples of different addressing modes

	# Format = ADDRESS_OR_OFFSET(%BASE_OR_OFFSET,%INDEX,MULTIPLIER)
	# Address = ADDRESS_OR_OFFSET + %BASE_OR_OFFSET + (%INDEX * MULTIPLIER)
	
	# Immediate mode (move constants)
	mov		$8, %al					# load 8 into al (8bit)
	#mov	$4 + $4, %ax			### THIS DOESN'T WORK ###
	movw	$FOUR_PLUS_FOUR, %ax	# BUT THIS DOES WORK
	mov		$8, %eax				# 32bit
	mov		$8, %rax				# 64bit
	
	movb	$8, %al					# load 8 into al (8bit)
	movw	$8, %ax					# BUT THIS DOES WORK
	movl	$8, %eax				# 32bit
	movq	$8, %rax				# 64bit
	
	# Direct addressing mode (move value of a variable)
	mov		oneb, %al				# load value at oneb into al (8bit)
	mov		onei, %ax				# 16bit
	mov		onel, %eax				# 32bit
	mov		oneq, %rax				# 64bit

	movb	oneb, %al				# load value at oneb into al (8bit)
	movw	onei, %ax				# 16bit
	movl	onel, %eax				# 32bit
	movq	oneq, %rax				# 64bit
	
	# Indexed addressing mode (move a value in a list using an index and multiplier)
									# when the address of the list is at a fixed location
	mov		$1, %rsi				# access 2nd item in the list (0 based index)
	mov		listb(,%rsi,1), %al		# load value in list into al (8bit)
	mov		listi(,%rsi,2), %ax		# 16bit
	mov		listl(,%rsi,4), %eax	# 32bit
	mov		listq(,%rsi,8), %rax	# 64bit
	
									# Full version of the indexed base pointer format
	mov		$1, %rsi				# access 2nd item in the list (0 based index)
	mov		$0, %rbx				# this could be a secondary index or a base pointer
	mov		listq(%rbx,%rsi,8), %rax	# 64bit

	# Index base pointer addressing mode (move value using a base pointer, index, and multiplier)
									# or you can do it this way, when the list location isn't know till later
	mov		$listb, %rbx			# load address into base register rbx
	mov		$1, %rsi				# access 2nd item in the list (0 based index)
	mov		(%rbx,%rsi,1), %al		# load value in list into al (8bit)
	mov		$listi, %rbx				# 
	mov		(%rbx,%rsi,2), %ax		# 16bit
	mov		$listl, %rbx			# 
	mov		(%rbx,%rsi,4), %eax		# 32bit
	mov		$listq, %rbx			# 
	mov		(%rbx,%rsi,8), %rax		# 64bit
	
	# Indirect addressing mode (move a value from and address in a register)
	# Note: uses lea instruction as a functional equivalent to mov used in code above
	lea		oneb, %rbx				# load effective address (not the value) to rbx  
	movb	(%rbx), %al				# load value at addess in rbx into al (8bit)
	lea		onei, %rbx				# 
	movw	(%rbx), %ax				# 16bit
	lea		onel, %rbx				# 
	movl	(%rbx), %eax			# 32bit
	lea		oneq, %rbx				# 
	movq	(%rbx), %rax			# 64bit
	
	# Base pointer addressing mode
	