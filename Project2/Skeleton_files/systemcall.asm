	.text
# user program
task:
	la      $a0, msg
	li	$v0, 4
	syscall
	li	$a0, 'D'
	li 	$v0, 11
loop:	syscall
	li	$a0, 'E'
	b	loop

# Data
	.data
msg: .asciiz "Hello World!"

# Bootup code
	.ktext
# DONE implement the bootup code
	la $t0 task		# load the beginning address in $t0
	mtc0 $t0 $14		# move address in $t0 to EPC
	andi $t0 $t0 0		# set register t0 back to 0x00000000
# The final exception return (eret) should jump to the beginning of the user program
eret

# Exception handler
# Here, you may use $k0 and $k1
# Other registers must be saved first
.ktext 0x80000180
	# Save all registers that we will use in the exception handler
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0
	sw $t0 exc_t0		# save t0
	sw $t1 exc_t1		# save t1
	sw $t2 exc_t2		# save t2

	mfc0 $k0 $13		# Cause register

# The following case can serve you as an example for detecting a specific exception:
# test if our PC is mis-aligned; in this case the machine hangs
	bne $k0 0x18 okpc	# Bad PC exception
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Is EPC word aligned (multiple of 4)?
	beq $a0 0 okpc
fail:	j fail			# PC is not aligned -> processor hangs

# The PC is ok, test for further exceptions/interrupts
okpc:
	andi $a0 $k0 0x7c	# check whether bit 6-2 of $13 equals 000000
	beq $a0 0 interrupt	# 0 means interrupt

# Exception code
# DONE Detect and implement system calls here.
	# Examine ExcCode (== 8)
	bne $a0 0x20 ret
	# Remember that an adjustment of the epc may be necessary. (only for syscall)
	mfc0 $t0 $14
	addiu $t0 $t0 0x4
	mtc0 $t0 $14
	# React to exception
	beq $v0 0x4 is4
	beq $v0 0xb is11
	j ret
# Implement syscall 4
is4: # Save each ascii character of string (1 byte/char) to the display data port
	lw $a0 exc_a0
nextchar:
	lb $t1 ($a0) 
	beq $t1 0 ret 		# check end of string
	sb $t1 0xffff000c
loop4: # Wait for the ready bit of the display to be set to print ascii character
	lw $t2 0xffff0008
	andi $t2 $t2 0x1
	beq $t2 0 loop4
	
	addiu $a0 $a0 0x1 	# move forward 1 character
	j nextchar
# Implement syscall 11
is11: # Save ascii character to the display data port 
	lw $a0 exc_a0	
	sw $a0 0xffff000c
loop11: # Wait for the ready bit of the display to be set to print ascii character
	lw $t2 0xffff0008
	andi $t2 $t2 0x1
	beq $t2 0 loop11
	
	j ret
# Interrupt-specific code (nothing to do here for this exercise)
interrupt:
	j ret
ret:
# Restore used registers
	lw $t0 exc_t0		# load t0
	lw $t1 exc_t1		# load t1
	lw $t2 exc_t2		# load t2
	lw $v0 exc_v0
	lw $a0 exc_a0
	move $at, $k1
	# Return to the EPC
	eret

# Internal kernel data
	.kdata
exc_v0:	.word 0
exc_a0:	.word 0
# DONE Additional space for registers you want to save temporarily in the exception handler
exc_t0: .word 0
exc_t1:	.word 0
exc_t2: .word 0
