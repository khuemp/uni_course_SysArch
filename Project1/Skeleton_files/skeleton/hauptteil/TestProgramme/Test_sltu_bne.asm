addiu $1, $0, 5
addiu $2, $0, 7
sltu $3, $1, $2
bne $3, $0, target
addiu $4, $0, 23
j end
target:
addiu $4, $0, 42
end: