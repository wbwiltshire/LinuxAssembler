# PURPOSE: Provide reference examples of different math instructions
	
	# Addition using constants
	xor		%rax, %rax				# zero rax
	add		$8, %al					# add 8 into al (8bit)
	addb	$8, %al					# same as above
	add		$8, %ax					# add 8 into ax (16bit)
	addw	$8, %ax					# same as above
	add		$8, %eax				# add 8 into eax (32bit)
	addl	$8, %eax				# same as above
	add		$8, %rax				# add 8 into rax (64bit)
	addq	$8, %rax				# same as above
	
	# Addition using indirect addressing mode (move a value from and address in a register)
	# Note: uses lea instruction as a functional equivalent to mov used in code above
	xor		%rax, %rax				# zero rax
	lea		oneb, %rbx				# load effective address (not the value) to rbx  
	addb	(%rbx), %al				# add value at addess in rbx with al (8bit)
	lea		onei, %rbx				# 
	addw	(%rbx), %ax				# 16bit
	lea		onel, %rbx				# 
	addl	(%rbx), %eax			# 32bit
	lea		oneq, %rbx				# 
	addq	(%rbx), %rax			# 64bit
	
	# Addition using index base pointer addressing mode (move value using a base pointer, index, and multiplier)
									# or you can do it this way, when the list location isn't know till later
	xor		%rax, %rax				# zero rax
	lea		listb, %rbx				# load address into base register rbx
	mov		$1, %rsi				# access 2nd item in the list (0 based index)
	add		(%rbx,%rsi,1), %al		# load value in list into al (8bit)
	lea		listi, %rbx				# 
	add		(%rbx,%rsi,2), %ax		# 16bit
	lea		listl, %rbx				# 
	add		(%rbx,%rsi,4), %eax		# 32bit
	lea		listq, %rbx				# 
	add		(%rbx,%rsi,8), %rax		# 64bit
	
	# Subtraction using constants
	mov		$0xff, %rax				# move 255 rax
	sub		$8, %al					# sub 8 into al (8 bit)
	subb	$8, %al					# same as above
	sub		$8, %ax					# sub 8 into ax (16 bit)
	subw	$8, %ax					# same as above
	sub		$8, %eax				# sub 8 into eax (32 bit)
	subl	$8, %eax				# same as above
	sub		$8, %rax				# sub 8 into rax (64 bit)
	subq	$8, %rax				# same as above
	
	###
	### MULTIPLICATION ###
	###
	# Unsigned Multiplication using direct mode
	mov		$4, %al
			# NOTE: Can't multiply 8 bit registers, since 8 bits is too small to hold result
	#mul	$4, %al					# NOT ALLOWED
	mov		$4, %bl					# move 4 to bl
	mul		%bl						# implied register is al and result in al (8 bit)
	mul		%bx						# implied register is ax and result in ax (16 bit)
	mul		%ebx					# implied register is eax and result in eax (32 bit)
	mul		%rbx					# implied register is rax and result in rax (64 bit)
	# Unsigned Multiplication using indirect mode
	mulb	(oneb)					# implied register is al and result in al (8 bit)
	mulw	(onei)					# (16 bit)
	mull	(onel)					# (32 bit)
	mulq	(oneq)					# (64 bit)

	# Signed Multiplication using direct mode
	mov		$4, %ax					# move 4 to ax
			# NOTE: Can't multiply 8 bit registers, since 8 bits is too small to hold result
	#imul	$4, %al					# NOT ALLOWED
	imul	$4, %ax					# multiply ax by 4 (16 bit) - result in ax
	imul	$4, %eax				# multiply eax by 4 (32 bit) - result in eax
	imul	$4, %rax				# multiply rax by 4 (64 bit) - result in rax

	# Signed Multiplication using indirect mode
	imulb	(oneb)					# implied register is al and result in ax (16 bit)
	imulw	(onei)					# (16 bit)
	imull	(onel)					# (32 bit)
	imulq	(oneq)					# (64 bit)
	
	###
	### DIVISION ###
	###
		# NOTE: Can't divide by constants; must use registers
		
	# Unsigned Division using direct mode
		# DIVIDEND in the following registers:
			# ax
			# dx:ax
			# edx:eax
			# rdx:rax
		# DIVISOR in any other registers or memory location
		# QUOTIENT in the following registers:
			# al (8 bit)
			# ax (16 bit)
			# eax (32 bit)
			# rax (64 bit)
		# REMAINDER in the following registers:
			# ah
			# dx
			# edx
			# rdx

	mov		$16, %rax
	mov		$4, %rbx				# move 4 to bl
	div		%bl						# implied register is ax and quotient in al (8 bit) and remainer in ah
	mov		$16, %rax
	div		%bx						# implied register is ax and result in ax:dx (16 bit)
	mov		$16, %rax
	div		%ebx					# implied register is eax and result in eax:edx (32 bit)
	mov		$16, %rax
	div		%rbx					# implied register is rax and result in rax:rdx (64 bit)
	# Unsigned Division using indirect mode
	mov		$16, %rax
	divb	(oneb)					# implied register is ax and quotient in al (8 bit) and remainer in ah
	divw	(onei)					# (16 bit)
	divl	(onel)					# (32 bit)
	divq	(oneq)					# (64 bit)
	
	# Signed Division using direct mode
	mov		$16, %rax
	mov		$4, %rbx				# move 4 to bl
	idiv	%bl						# implied register is ax and quotient in al (8 bit) and remainer in ah
	mov		$16, %rax
	idiv	%bx						# implied register is ax and result in ax:dx (16 bit)
	mov		$16, %rax
	idiv	%ebx					# implied register is eax and result in eax:edx (32 bit)
	mov		$16, %rax
	idiv	%rbx					# implied register is rax and result in rax:rdx (64 bit)

	# Signed Division using indirect mode
	mov		$16, %rax
	idivb	(oneb)					# implied register is al and result in ax (16 bit)
	idivw	(onei)					# (16 bit)
	idivl	(onel)					# (32 bit)
	idivq	(oneq)					# (64 bit)
