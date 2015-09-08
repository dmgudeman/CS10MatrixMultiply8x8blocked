# David Gudeman
# CS10
# Lab 6: 8x8 matrix multiply

.data
Instructions: .asciiz "Type in integers followed by a space\n"
EnterRowA: .asciiz "\nArray a - Enter row  "
EnterRowB: .asciiz "\nArray b - Enter row  "
EmptyLine: .asciiz "\n"
PrintRow: .asciiz "Row "
Colon: .asciiz ": "
Dash: .asciiz "- "
Space: .asciiz " "

listsz: .word 72 # number of integers in the array
answer: .space 200
answersz: .word 16
rowCount: .word 8
charCount: .byte 16 # this is the character count for input string 
columnCount: .word 32
blockCount: .word 4 
rowLength: .word 8

.text
#####################get some memory to catch strings#####
la $t4, 256($sp) # set address to catch STRING in $t4
la $s4, 256($sp) # save address of STRING for LoopB
########################Print out instructions ############
li $v0, 4    # service number to PRINT STRING
li $a1, 9    # ok to load 9 characters
la $a0, Instructions
syscall
li $v0, 4    # service number to PRINT STRING
li $a1, 9    # ok to load 9 characters
la $a0, EmptyLine
 syscall
########################Input String Text for array a ############
addi $t6, $zero, 1 # set enterString counter to 0
enterStringA: #Enter string numbers
li $v0, 4    # service number to PRINT STRING
li $a1, 9    # ok to load 9 characters
la $a0, EnterRowA
syscall
li $v0, 1    # service number PRINT INTEGER
move $a0, $t6 #load the value of the counter to print row number
syscall
li $v0, 4    # service number to PRINT STRING
li $a1, 2    # ok to load 2 characters
la $a0, Colon
syscall
lw $t7, charCount #load in number of columns in input array
lw $t8, rowCount #load in number of rows per array
lw $t5, columnCount #load the number of columns in both arrays
la $a0, ($t4)# loads address to write the string to
add $a1, $t7, 1   # 8 bytes (characters) +1 allows 4 characters and 4 spaces on string input
li $v0, 8    # service number READ STRING
syscall      # read value goes into $t4

addi $t6, $t6, 1 # increment loop counter by one
addi $t4, $t4, 16 # move 8 spaces in the memory to catch next string of 4 char
ble $t6, $t8, enterStringA # ends loop at number of rows to be entered
########################Print an Empty Line #######################
li $v0, 4    # service number to PRINT STRING
li $a1, 2    # ok to load 2 characters
la $a0, EmptyLine
syscall
########################Input String Text for array b ##############
li $t6, 1 # reset the counter to collect array B
enterStringB: #Enter string numbers
li $v0, 4    # service number to PRINT STRING
li $a1, 9    # ok to load 9 characters
la $a0, EnterRowB
syscall
li $v0, 1    # service number PRINT INTEGER
move $a0, $t6 #load the value of the counter to print row number
syscall
li $v0, 4    # service number to PRINT STRING
li $a1, 2    # ok to load 2 characters
la $a0, Colon
syscall
la $a0, ($t4)# to continue catching strings
add $a1, $t7, 1   # ok to load 9 colums (characters) +1
li $v0, 8    # service number READ STRING
syscall      # read value goes into $t4
addi $t6, $t6, 1 # increment loop counter by one
addi $t4, $t4, 16 # move 16 spaces in the memory to catch next string of 8 char
ble $t6, $t8, enterStringB # ends loop at number of rows to be entered
############convert char to integers and put in new array#########
mul $s0, $t7, $t5   # $s0 = array dimension

sub $sp, $sp, $s0 #make room on stack for number of words in the array
la $s1 ($sp)     #load base address of the array in $s1
li $t0, 0        # $t0 = # elems init'd

convertSringToInteger:beq $t0, 128, doneConvert # No. of char to convert to integers
lb $s3, ($s4) # store byte from $s4 into $s3
sub $s3, $s3, 0x30 # subtract 0x30 from character to convert to integer
sb $s3, ($s1) # store byte from $s3 to $s1
addi $s1, $s1, 4 # step to next array cell
addi $t0, $t0, 1 # count elem just init'd
addi $s4, $s4, 2 #increment the characters
b convertSringToInteger

doneConvert:
################Table of registers for the loop counters###############
#$t0 holds b array value
#$t1 holds i counter - a array row
#$t2 holds j counter - a array column
#$t3 holds k counter - b array row
#$t4 holds l counter - b array column
#$t5 holds calulations for b array
#$t6 holds value for b cell
#$t7 holds calculations for a array
#$t8 holds value for a cell and catches a value to add
#$t9 holds a array value and final calulation

#$s0 holds x counter - block 
#$s1 holds i calulcations a row
#$s2 holds j calculations a column
#$s3 holds k calculations b row
#$s4 holds throw away  l calculations b columns
#$s5 holds address for start of b array
#$s6 holds address for b array element
#$s7 holds address for a array element

#$a2 hold counter for the answer which incrments by 4
#$a3 holds address for the answer
##################initialize values for the loops###################
li $t0, 0x00
li $t1, 0x00 # i counter (array a rows)
li $t2, 0x00 # j counter (array a columns)
li $t3, 0x00 # k counter (array b rows)
li $t4, 0x00 # l counter (array b columns)
li $a2, 0x00 # ANSWER COUNTER
li $t7, 0x00 # m start the loop counter to calculate the answer array
li $t8, 0    # j counter for columns of Array One
li $t9, 0    # k counter for rows of Array Two
li $s0, 4    # holds address for the start of the
lw $s4, rowLength
####################################################   X1  CALCULATE A1B1
la $a0, 0($sp)   # array a: base address
la $s5, 256($sp) # array b: base address
la $a3 1028($sp) # array ANSWER: base address for X1

topOfBlockX1:
i_loopX1:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX1:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX1:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $sp, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX1 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX1 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX1 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX1 # loop branch for block counter
############################## X1 A2 B3 #####################################
la $a0, 4($sp)   # array a: base address 
la $s5, 384($sp) # array b: base address
la $a3 1028($sp) # array ANSWER: reset to base X1
topOfBlockX11:
li $t1, 0       # array a: reset counter
i_loopX11:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX11:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX11:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $sp, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX11 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX11 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX11 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX11 # loop branch for block counter
###########  PRINT  A1B1 + A2B3 #################################



################## X2 ###################
li $t0, 0x00
li $t1, 0x00 # i counter (array a rows)
li $t2, 0x00 # j counter (array a columns)
li $t3, 0x00 # k counter (array b rows)
li $t4, 0x00 # l counter (array b columns)
li $a2, 0x00 # ANSWER COUNTER
li $t7, 0x00 # m start the loop counter to calculate the answer array
li $t8, 0    # j counter for columns of Array One
li $t9, 0    # k counter for rows of Array Two
li $s0, 4    # holds address for the start of the
lw $s4, rowLength
####### X2 CALCULATE A1 B2
#la $s4, 0($sp)  # load address $sp 
la $a0, 0($sp)  # array a base sddress
la $s5 272($sp) # array b base address
la $a3 1092($sp) # array ANSWER: X2 base address
topOfBlockX2:
i_loopX2:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX2:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX2:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $sp, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX2 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX2 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX2 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX2 # loop branch for block counter
##############################  X22 A2B4#####################################
la $a0, 4($sp)    # array a: base address
la $s5, 400($sp)  # array b: base address
la $a3, 1092($sp) # array ANSWER: X22 base address
topOfBlockX22:
li $t1, 0       # array a: reset counter
i_loopX22:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX22:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loop2X2:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $sp, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loop2X2 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX22 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX22 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX22 # loop branch for block counter

##################  X3    ##################
li $t0, 0x00
li $t1, 0x00 # i counter (array a rows)
li $t2, 0x00 # j counter (array a columns)
li $t3, 0x00 # k counter (array b rows)
li $t4, 0x00 # l counter (array b columns)
li $a2, 0x00 # ANSWER COUNTER
li $t7, 0x00 # m start the loop counter to calculate the answer array
li $t8, 0    # j counter for columns of Array One
li $t9, 0    # k counter for rows of Array Two
li $s0, 4    # holds address for the start of the
lw $s4, rowLength
#######  X3 CALCULATE A3B1
la $a0, 128($sp)   # array a: base address
la $s5, 256($sp) # array b: base address
la $a3 1156($sp) # array ANSWER: X3 base address

topOfBlockX3:
i_loopX3:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX3:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX3:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $a0, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX3 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX3 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX3 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX3 # loop branch for block counter
############################## X33 A4 B3 #####################################
la $a0, 132($sp)  # array a: base address 
la $s5, 384($sp)  # array b: base address
la $a3, 1156($sp) # array ANSWER: X33 base address
topOfBlockX33:
li $t1, 0         # array a: reset counter
i_loopX33:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX33:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX33:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $a0, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX33 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX33 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX33 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX33 # loop branch for block counter

##################  X4    ##################
li $t0, 0x00
li $t1, 0x00 # i counter (array a rows)
li $t2, 0x00 # j counter (array a columns)
li $t3, 0x00 # k counter (array b rows)
li $t4, 0x00 # l counter (array b columns)
li $a2, 0x00 # ANSWER COUNTER
li $t7, 0x00 # m start the loop counter to calculate the answer array
li $t8, 0    # j counter for columns of Array One
li $t9, 0    # k counter for rows of Array Two
li $s0, 4    # holds address for the start of the
lw $s4, rowLength
#######  X4 CALCULATE A3B2
la $a0, 128($sp)   # array a: base address
la $s5, 272($sp) # array b: base address
la $a3 1220($sp) # array ANSWER: X4 base address

topOfBlockX4:
i_loopX4:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX4:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX4:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $a0, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX4 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX4 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX4 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX4 # loop branch for block counter
############################## X44 A4 B4 #####################################
la $a0, 132($sp)  # array a: base address 
la $s5, 400($sp)  # array b: base address
la $a3, 1220($sp) # array ANSWER: X44 base address
topOfBlockX44:
li $t1, 0         # array a: reset counter
i_loopX44:
li $t4, 0       # array b: l column counter
#li $t1, 0       # array a: i row counter
l_loopX44:
li $t2, 0       # array a: j column counter
li $t3, 0       # array b: k row counter
k_loopX44:
#set up b array
mul $s4, $t4, 4   # array b: l * (word) caclulates the b column
mul $s3, $t3, 32  # array b: k * (length of row) calculates the b row in 4x4 submatrix
add $t5, $s3, $s4 # array b: add (word * l) + (length of row * k) = offset ($t5)
add $s6, $s5, $t5 # array b: add offset ($t5) to base of b array $s6 yields b cell address
#lw $t6, ($s6)    # array b: operand for b loaded in $t6
#set up a array

mul $s3, $t2, 4   # array a: j * 4 calculates the a column, reduntant calculation to $s3
add $t7, $t1, $s3 # array a: (i + 32)+(j*4) yields offset
add $s7, $a0, $t7 # array a: this adjusts the address to fetch
#calculate
lw $t0, ($s6)	  # array b: load operand
lw $t9, ($s7)     # array a: load operand 
mul $t9, $t0, $t9 # a * b store in $t9
lw $t8 ($a3)      # array ANSWER - pull word out to add from the answer field
add $t8, $t9, $t8 # c + ab 
sw $t8, ($a3)     # array ANSWER store back in answer field
#increment counters
addi $t2, $t2, 1  # array a: increment j
addi $t3, $t3, 1  # array b: increment k
blt $t3, 4, k_loopX44 # counts 4 iterations for submatrix
addi $a2, $a2, 1  # ANSWER: increment counter 
#increment counters
addi $a3, $a3, 4  #increments the address for the answer every 4
addi $t4, $t4, 1  # array b: $t4 is l, column counter for b
blt $t4, 4, l_loopX44 #  counts 4 iterations for submatrix
#increment counter
add $t1, $t1, 32  # array a: i * 4 calculates a row in 4x4 submatrix
#addi $t1, $t1, 1  # array a: $t1 is i, row counter for a
blt $t1, 128, i_loopX44 # counts 4 iterations 
addi $s0, $s0, 1 # iterates the block counter
blt $s0, 4, topOfBlockX44 # loop branch for block counter

#########################################PRINT ANSWER ARRAY X1 and X2 ###########################
la $a3 1028($sp)# a3 will be the base address of answer array CONSTANT
la $a2 1092($sp)  # a2 prints second half of line
li $t2, 0 #initialize a counter for the OuterLoop
AnswerArrayPrintOut:
add $t4, $a3, $t2 # increments the answere array by 8
#addi $t4, $a3, 0   # sets up inner address incrementer
add  $t7, $a2, $t2   # a2 prints second half of line
addi $t1, $zero, 0 # initialize a counter for InnerLoopOutPut
addi $a0, $0, 0xA #ascii code for Line Feed
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall
zeroToFourPrint: # cycles through 4 integers per row
lw $t5, ($t4) #loads INTEGER to print into $t5
li $v0, 1 # service number PRINT INTEGER
move $a0, $t5 #load the value $t5 (INTEGER) into $a0 for syscall
syscall
li $v0, 4 # service number to PRINT SPACE
li $a1, 2 # ok to load 9 characters
la $a0, Space # load address of Space into $a0
syscall
addi $t1, $t1, 1 # increment counter for InnerLoopOutPut
addi $t4, $t4, 4 # add to get to the next word in array
bne $t1, 4, zeroToFourPrint # break out of inner loop at 4
fiveToEightPrint: # cycles through 4 integers per row
lw $t5, ($t7) #loads INTEGER to print into $t5
li $v0, 1 # service number PRINT INTEGER
move $a0, $t5 #load the value $t5 (INTEGER) into $a0 for syscall
syscall
li $v0, 4 # service number to PRINT SPACE
li $a1, 2 # ok to load 9 characters
la $a0, Space # load address of Space into $a0
syscall
addi $t1, $t1, 1 # increment counter for InnerLoopOutPut
addi $t7, $t7, 4 # add to get to the next word in array
blt $t1, 8, fiveToEightPrint # break out of inner loop at 4
addi $t2, $t2, 16 # increment outer loop counter by one
blt $t2,64, AnswerArrayPrintOut 

#########################################PRINT ANSWER ARRAY X3 and X4 ###########################
la $a3 1156($sp)# a3 will be the base address of answer array CONSTANT
la $a2 1220($sp)  # a2 prints second half of line
li $t2, 0 #initialize a counter for the OuterLoop
AnswerArrayPrintOut2:
add $t4, $a3, $t2 # increments the answere array by 8
#addi $t4, $a3, 0   # sets up inner address incrementer
add  $t7, $a2, $t2   # a2 prints second half of line
addi $t1, $zero, 0 # initialize a counter for InnerLoopOutPut
addi $a0, $0, 0xA #ascii code for Line Feed
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall
zeroToFourPrint2: # cycles through 4 integers per row
lw $t5, ($t4) #loads INTEGER to print into $t5
li $v0, 1 # service number PRINT INTEGER
move $a0, $t5 #load the value $t5 (INTEGER) into $a0 for syscall
syscall
li $v0, 4 # service number to PRINT SPACE
li $a1, 2 # ok to load 9 characters
la $a0, Space # load address of Space into $a0
syscall
addi $t1, $t1, 1 # increment counter for InnerLoopOutPut
addi $t4, $t4, 4 # add to get to the next word in array
bne $t1, 4, zeroToFourPrint2 # break out of inner loop at 4
fiveToEightPrint2: # cycles through 4 integers per row
lw $t5, ($t7) #loads INTEGER to print into $t5
li $v0, 1 # service number PRINT INTEGER
move $a0, $t5 #load the value $t5 (INTEGER) into $a0 for syscall
syscall
li $v0, 4 # service number to PRINT SPACE
li $a1, 2 # ok to load 9 characters
la $a0, Space # load address of Space into $a0
syscall
addi $t1, $t1, 1 # increment counter for InnerLoopOutPut
addi $t7, $t7, 4 # add to get to the next word in array
blt $t1, 8, fiveToEightPrint2 # break out of inner loop at 4
addi $t2, $t2, 16 # increment outer loop counter by one
blt $t2,64, AnswerArrayPrintOut2 
li $v0, 10
syscall 
