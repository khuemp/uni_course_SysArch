	.text
# User program 1: Output numbers
task1:	li	$a0, '0'
	li 	$v0, 11
	li 	$t0, 10	
loop1:	syscall
	addiu   $a0, $a0, 1
	divu    $t1, $a0, ':'
	multu   $t1, $t0
	mflo    $t1
	subu    $a0, $a0, $t1
	b	loop1

# User program 2: Output B
task2:	li	$a0, 'B'
	li	$v0, 11
loop2:  syscall
	b	loop2

# Bootup code
	.ktext
# DONE Implement the bootup code
# Initialize all required data structures
# The final exception return (eret) shall jump to the beginning of program 1
	# Initialize PCB of task 1
	la $a0 pcb_task1
	li $k0 1
	sw $k0 4($a0)
	la $k0 task1
	sw $k0 8($a0)
	# Initialize PCB of task 2
	la $a0 pcb_task2
	sw $0 4($a0)
	la $k0 task2
	sw $k0 8($a0)
	
	la $ra task1
	mtc0 $ra $14
	li $k0 100
	mtc0 $k0 $11
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

# Exception code
# Detect and implement system calls here. Here, you can reuse parts from problem 2.1
# Remember that an adjustment of the epc may be necessary.
# Detect syscall
	mfc0 $k0 $13
	sll $k0 $k0 25
	srl $k0 $k0 27
	bne $k0 8 ret
	# Save Next PC
	mfc0 $a0 $14
	addi $a0 $a0 4
	mtc0 $a0 $14
	# Detect type of syscall
	lw $v0 exc_v0
	beq $v0 4 print_str
	beq $v0 11 print_char
	j ret
print_str:
	# Load address of string to print from exc_a0
	lw $a0 exc_a0
prt_loop:
	# Load char to print
	lb $v0 ($a0)
	# Check  if at the end of string
	beq $v0 0 ret
	# Check readiness of display
	li $k0 0xffff0008
	lw $k0 ($k0)
	andi $k0 $k0 1
	bne $k0 1 prt_loop
	# Put char to print in dataport of display
	li $k0 0xffff000c
	sb $v0 ($k0)
	# Move to address of next char
	addi $a0 $a0 1
	j prt_loop
	
print_char:
	# Check readiness of display
	li $k0 0xffff0008
	lw $k0 ($k0)
	andi $k0 $k0 1
	bne $k0 1 print_char
	# Put char to print in dataport of display
	lw $a0 exc_a0
	li $v0 0xffff000c
	sw $a0 ($v0)
	j ret

# Interrupt-specific code

interrupt:
# DONE For timer interrupts, call timint
	# Switch process
	la $k0 pcb_task1
	lw $k0 4($k0)
	beq $k0 1 from1to2
from2to1:
	la $a0 pcb_task2
	la $v0 pcb_task1
	j timint
from1to2:
	la $a0 pcb_task1
	la $v0 pcb_task2
	j timint
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

	.ktext
# Helper functions
timint:
# DONE Process the timer interrupt here, and call this function from the exception handler
# $a0 PCB of running process
# $v0 PCB of waiting process
	# Save data of running process
	sw $0 4($a0)
	mfc0 $k0 $14
	sw $k0 8($a0)

	sw $at 12($a0)
	lw $k0 exc_v0
	sw $k0 16($a0)
	sw $v1 20($a0)
	lw $k0 exc_a0
	sw $k0 24($a0)
	sw $a1 28($a0)
	sw $a2 32($a0)
	sw $a3 36($a0)
	sw $t0 40($a0)
	sw $t1 44($a0)
	sw $t2 48($a0)
	sw $t3 52($a0)
	sw $t4 56($a0)
	sw $t5 60($a0)
	sw $t6 64($a0)
	sw $t7 68($a0)
	sw $s0 72($a0)
	sw $s1 76($a0)
	sw $s2 80($a0)
	sw $s3 84($a0)
	sw $s4 88($a0)
	sw $s5 92($a0)
	sw $s6 96($a0)
	sw $s7 100($a0)
	sw $t8 104($a0)
	sw $t9 108($a0)
	sw $fp 112($a0)
	sw $ra 116($a0)
	sw $gp 120($a0)
	sw $sp 124($a0)
	# Restore data of waiting process
	li $k0 1
	sw $k0 4($v0)
	lw $k0 8($v0)
	mtc0 $k0 $14

	lw $at 12($v0)
	lw $k0 16($v0)
	sw $k0 exc_v0
	lw $v1 20($v0)
	lw $k0 24($v0)
	sw $k0 exc_a0
	lw $a1 28($v0)
	lw $a2 32($v0)
	lw $a3 36($v0)
	lw $t0 40($v0)
	lw $t1 44($v0)
	lw $t2 48($v0)
	lw $t3 52($v0)
	lw $t4 56($v0)
	lw $t5 60($v0)
	lw $t6 64($v0)
	lw $t7 68($v0)
	lw $s0 72($v0)
	lw $s1 76($v0)
	lw $s2 80($v0)
	lw $s3 84($v0)
	lw $s4 88($v0)
	lw $s5 92($v0)
	lw $s6 96($v0)
	lw $s7 100($v0)
	lw $t8 104($v0)
	lw $t9 108($v0)
	lw $fp 112($v0)
	lw $ra 116($v0)
	lw $gp 120($v0)
	lw $sp 124($v0)
	# Set new timer interrupt	
	mtc0 $0 $9
	li $a0 100
	mtc0 $a0 $11
	j	ret

# Process control blocks
# Location 0: the program counter
# Location 1: state of the process; here 0 -> idle, 1 -> running
# Location 2: EPC
# Location 3-..: state of the registers
	.kdata
pcb_task1:
.word task1
.word 0			# State
.word 0			# PC
.word 0			# $at
.word 0			# $v0
.word 0			# $v1
.word 0			# $a0
.word 0			# $a1
.word 0			# $a2
.word 0			# $a3
.word 0			# $t0
.word 0			# $t1
.word 0			# $t2
.word 0			# $t3
.word 0			# $t4
.word 0			# $t5
.word 0			# $t6
.word 0			# $t7
.word 0			# $s0
.word 0			# $s1
.word 0			# $s2
.word 0			# $s3
.word 0			# $s4
.word 0			# $s5
.word 0			# $s6
.word 0			# $s7
.word 0			# $t8
.word 0			# $t9
.word 0			# $fp
.word 0			# $ra
.word 0			# $gp
.word 0			# $sp
pcb_task2:
.word task2
.word 0			# State
.word 0			# PC
.word 0			# $at
.word 0			# $v0
.word 0			# $v1
.word 0			# $a0
.word 0			# $a1
.word 0			# $a2
.word 0			# $a3
.word 0			# $t0
.word 0			# $t1
.word 0			# $t2
.word 0			# $t3
.word 0			# $t4
.word 0			# $t5
.word 0			# $t6
.word 0			# $t7
.word 0			# $s0
.word 0			# $s1
.word 0			# $s2
.word 0			# $s3
.word 0			# $s4
.word 0			# $s5
.word 0			# $s6
.word 0			# $s7
.word 0			# $t8
.word 0			# $t9
.word 0			# $fp
.word 0			# $ra
.word 0			# $gp
.word 0			# $sp
