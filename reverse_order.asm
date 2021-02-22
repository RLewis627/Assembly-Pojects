# Who:  Rachel Lewis
# What: one_per_line.asm
# Why:  An array of 20 ints, which are printed one per line
# When: March 3, 2019
# How: 	$t0 - Incrimented/Decrimented by 4 to access array elements
#	$t1 - Holds user input for number of ints printed per line
#	$t2 - Incrimented by 1 to track number of ints being printed per line. Compared to $t1
#	$t3 - Array bit size stored

.data
array:		.space		80
array_bit_size:	.word		80
prompt:		.asciiz 	"Enter 20 elements"
new_line:	.asciiz 	"\n"
space:		.asciiz 	" "
int_prompt:	.asciiz 	"Enter number of integers to be printed per line: "

.text
lw $t3, array_bit_size		#load address to array bit size into $t3
addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 84		#load address to prompt into $a0
syscall 		

addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 102		#load address to new line character into $a0
syscall		

j input_loop			#jump to loop to take in input

input_loop:		
beq $t0, $t3, intermediate_loop	#If register $t0 = 80 (80 bits -> 20 words in array) exit loop
addiu $v0, $0, 5		#syscall code for reading an integer
syscall
sw $v0, array($t0)		#Else, save integer that was read in into index $t0 of array
addiu $t0, $t0, 4		#Incriment contents of $t0 by 4
j input_loop			#Continue looping

intermediate_loop:
subu $t0, $t3, 4		#load the value of 76 into register $t0. This will be decremented to print array in reverse
addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 102		#load address to new line character into $a0
syscall
j output_loop			#jump to output loop

output_loop:
beq $t0, -4, user_defined_input	#If register $t0 = -4 jump to user_defined_loop1
lw $a0, array($t0)		#Else, load array element with index $t0 to register $a0
subu $t0, $t0, 4		#Decriment contents of $t0 by 4
li $v0, 1			#syscall code for writing an integer
syscall
addiu $v0, $0, 4		#syscall code for writing a string
lui $at, 4097			
ori $a0, $at, 104		#load address to space character into $a0
syscall
j output_loop			#jump to output_loop to begin printing contents of array

user_defined_input:
addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 102		#load address to new line character into $a0
syscall
addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 106		#load address to int_prompt into $a0
syscall
addiu $v0, $0, 5		#syscall code for reading an integer
syscall
addu $t1, $v0, $0		#register $t1 holds user-defined number of ints per line
addu $t0, $0, $0		#reset register $t0 back to 0
j user_defined_loop1		#jump to first user_defined loop

user_defined_loop1:		#user_defined_loop1 is a collection of branch statements that determine whether a new line will be printed
beq $t0, $t3, exit		#If register $t0 = 80 (80 bits -> 20 words in array) exit loop
beq $t2, $t1, space_loop	#If register $t2 = user-defined number of ints, jump to space loop

user_defined_loop2:
lw $a0, array($t0)		#Else, load array element with index $t0 to register $a0
addiu $t0, $t0, 4		#Incriment contents of $t0 by 4 (bytes)
li $v0, 1			#syscall code for writing an integer
syscall
addiu $v0, $0, 4		#syscall code for writing a string
lui $at, 4097			
ori $a0, $at, 104		#load address to space character into $a0
syscall
addiu $t2, $t2, 1
j user_defined_loop1		#Continue looping, back to the branch statements

space_loop:
addiu $v0, $0, 4		#syscall code for printing a string
lui $at, 4097			
ori $a0, $at, 102		#load address to new line character into $a0
syscall
addu $t2, $0, $0		#reset incrimenting register $t2 to 0
j user_defined_loop2		#jump back to loop to continue printing ints

exit:
li $v0, 10			# terminate the program
syscall
