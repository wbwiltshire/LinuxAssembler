#Function: intToString
# PURPOSE: Convert an integer number to a decimal string for print
#
# CALLING CONVENTION: C 
#	push buffer address
#	push number

# INPUT: 
#	buffer address: a buffer large enough to hold the largest possible number
#	number: an integer number to stringify

# OUTPUT:
#	The buffer will be over-writtend with the decimal string
#
# VARIABLES: The registers have the following uses
#
# %eax - current value
# %ecx - count of characters processed
# %edi - holds the base (10)
#
# CONSTANTS
.equ	stValue, 16 			# 1*8 + 8
.equ	stBuffer, 24			# 2*8 + 8

.type	intToString, @function
	.global	intToString
intToString:
	push	%rbp			# save stack for function return
	mov	%rsp, %rbp

	xor	%ecx, %ecx		# current character count to 0
	mov	stValue(%rbp), %rax	# move value into %eax
	movl	$10, %edi		# move in base

conversionLoop:
	xor 	%edx, %edx		# Clear out for division
	divl	%edi			# Divide (%eax / %edi)
					# Quotient in eax and remainder in edx
	addl	$'0', %edx		# convert to ascii
        push	%rdx			# push on stack and we'll pull off at the end
	incl	%ecx			# increment the digit count
	cmp	$0, %eax		# is quotient 0 yet?
	je	conversionEnd		# if so, we're done
	jmp	conversionLoop		# %eax already has next value, so back to top of loop

conversionEnd:				# string is now on the stack in reverse order
	mov	stBuffer(%rbp), %rdx	# get pointer to the buffer
reverseLoop:
	pop	%rax			# pushed entire register, but only need 1 byte
	movb	%al, (%edx)		# move byte to buffer
	decl	%ecx			# decrement character count
	incl	%edx			# move forward in buffer
	cmpl	$0, %ecx		# if count is 0, we're done
	je	reverseEnd
	jmp	reverseLoop
reverseEnd:
	movb	$0, (%edx)		# /0 - null terminate string

	mov	%rbp, %rsp		# restore stack for function return
	pop	%rbp
	ret	
