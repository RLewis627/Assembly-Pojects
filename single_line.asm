# Who:  Rachel Lewis
# What: one_per_line.asm
# Why:  An array of 20 ints, which are printed one per line
# When: March 3, 2019
# How:  $t0 - array bit size stored
#	$t1 - Incrimented by 4 to access array elements

.data
array:		.space		80
array_bit_size:	.word		80
prompt:		.asciiz 	"Enter 20 elements"
new_line:	.asciiz 	"\n"
space:		.asciiz 	" "

.text
lw $t0, array_bit_size		#load address to array bit size into $t0

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
beq $t1, $t0, intermediate_loop	#If register $t1 = 80 (80 bits -> 20 words in array) exit loop
addiu $v0, $0, 5		#syscall code for reading an integer
syscall
sw $v0, array($t1)		#Else, save integer that was read in into index $t1 of array
addiu $t1, $t1, 4		#Incriment contents of $t1 by 4 (bytes)
j input_loop			#Continue looping

intermediate_loop:		
addu $t1, $0, $0		#reset register $t1 back to 0
j output_loop			#jump to output loop

output_loop:
beq $t1, $t0, exit		#If register $t1 = 80 (80 bits -> 20 words in array) exit loop
lw $a0, array($t1)		#Else, load array element with index $t1 to register $a0
addiu $t1, $t1, 4		#Incriment contents of $t1 by 4 (bytes)
addiu $v0, $0, 1		#syscall code for writing an integer
syscall
addiu $v0, $0, 4		#syscall code for writing a string
lui $at, 4097			
ori $a0, $at, 104		#load address to new line character into $a0
syscall
j output_loop			#Continue looping

exit:
li $v0, 10			# terminate the program
syscall
