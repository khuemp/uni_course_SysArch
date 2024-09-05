.text

# Bootup code
# Since we only implement input/output with polling here and do no computations, all your code can be here.

.ktext
start:
	# DONE Implement input/output with polling
# Wait for the display to be ready
waitdp:
	lw 	$t0 0xffff0008
	andi	$t0 $t0 0x1
	beq	$t0 0 start
# Display is now ready (done printing out last input)
# Wait for the keyboard to be ready
waitkb:
	lw 	$t1 0xffff0000
	andi	$t1 $t1 0x1
	beq	$t1 0 waitkb
# Keyboard is now ready (exist an input)
	lw	$t2 0xffff0004		# load input from keyboard
	sw	$t2 0xffff000c		# save input to display
	
	b start
