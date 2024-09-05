.text

usefultask:
	# Program which can perform useful computations, whereas 
	# the exception handler takes care of input/output.
	# Unlike polling, with interrupts it is very easy to perform 
	# useful computations in addition to handling input/output and 
	# not waste computing time with unnecessary waiting.
	# This shall remain unchanged!
	b usefultask

# Bootup code
.ktext
# DONE Implement the system initialization here. What do you need to do for this?
# Enable interrupt enable bit for keyboard
	addiu $t0 $t0 0x2
	sw $t0 0xffff0000
# DONE Jump to our useful task
	la $t0 usefultask
	mtc0 $t0 $14
	andi $t0 $t0 0
eret


# Exception handler
# Here, you may use $k0 and $k1
# Other registers must be saved first
.ktext 0x80000180
	# Save all registers that we will use in the exception handler
	move $k1, $at
	sw $v0 exc_v0
	sw $a0 exc_a0

	mfc0 $k0 $13		# Cause register

# The following case can serve you as an example for detecting a specific exception:
# test if our PC is mis-aligned; in this case the machine hangs
	bne $k0 0x18 okpc	# Bad PC exception
	mfc0 $a0 $14		# EPC
	andi $a0 $a0 0x3	# Is EPC word aligned?
	beq $a0 0 okpc
fail:	j fail			# PC is not aligned -> processor hangs

# The PC is ok, test for further exceptions/interrupts
okpc:
	andi $a0 $k0 0x7c
	beq $a0 0 interrupt	# 0 means interrupt

# Exception code. For problem 2.3, it is not required to handle exceptions.
	j ret

# Interrupt-specific code
# DONE Implement handlers for keyboard and display interrupts here.
# You may outsource the actual functionality to functions (similar to problem 2.2).
interrupt:
	andi $a0 $k0 0x400	# keyboard interrupt?
	bne $a0 0 keyboard
	
	andi $a0 $k0 0x800	# display interrupt?
	bne $a0 0 display
	
	j ret
keyboard:
# Check for buffer full
	andi $a0 $a0 0		# clean $a0
	
	la $k1 buffer
	lb $a0 15($k1)		# check last byte of buffer
	beq $a0 0 notfull
full: 
# Turn off keyboard interrupt
	lw $a0 0xffff0000
	andi $a0 $a0 0x1
	sw $a0 0xffff0000
	
	j ret
notfull: 
# Add new input
# Use loop to search for last byte available
	lb $a0 ($k1)
	beq $a0 0 found
	addiu $k1 $k1 0x1
	j notfull
found:
	lb $a0 0xffff0004
	sb $a0 ($k1)
# Turn on display interrupt
	lw $a0 0xffff0008
	ori $a0 $a0 0x2
	sw $a0 0xffff0008
	
	j ret
	
display:
# Check for buffer null
	andi $a0 $a0 0		# clean $a0
	
	la $k1 buffer
	lb $a0 0($k1)		# check first byte of buffer
	bne $a0 0 notnull
null:
# Turn off display interrupt
	lw $a0 0xffff0008
	andi $a0 $a0 0x1
	sw $a0 0xffff0008
	
	j ret	
notnull:
# Print first byte
	sw $a0 0xffff000c
	la $v0 15($k1)
# Delete printed byte, clean last byte and change position of the rest
nextbyte:
	 lb $a0 1($k1)
	 sb $a0 0($k1)
	 
	 beq $a0 0 done		# byte == 0
	 addiu $k1 $k1 0x1
	 
	 bne $k1 $v0 nextbyte	# reach byte 16
	 sb $0 ($k1)		# let byte 16 be 0
done:
# Turn on keyboard interrupt
	lw $a0 0xffff0000
	ori $a0 $a0 0x2
	sw $a0 0xffff0000
	
	j ret
		 
ret:
# Restore used registers
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
# No additional registers needed

# DONE Allocate your 16-byte buffer here (save from 0-16, clear from 16-0)
buffer: .word 0
	.word 0
	.word 0
	.word 0
