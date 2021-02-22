# Who:  Rachel Lewis
# What: fibonacci.asm
# Why:  calculate the nth Fibonacci number in an iterative loop
# When: 3/17/19
# How:  $t0: user-indicated value of n
#	$t1: a, as defined in pseudocode example in project description
#	$t2: b, as defined in pseudocode example in project description
#	$t3: temp, as defined in pseudocode example in project description
#	$t4: incrimented counter variable

.data
fibArray:	.space		188	#an array that holds 46 values
n_prompt:	.asciiz 	"Enter nth number for Fibonacci sequence F(n): "
n_not_positive:	.asciiz 	"n must be positive"
n_too_big:	.asciiz 	"n is too large. Value cannot be displayed in 32 bits"
output_prompt:	.asciiz 	"F("
paren:		.asciiz 	") = "
arrayOutput:	.asciiz 	"Fibonacci sequence from 0 to n: "
space:		.asciiz 	" "
new_line:	.asciiz 	"\n"

.text
inputLoop:
li $v0, 4			#syscall code for printing a string
la $a0, n_prompt		#load address to n_prompt into $a0
syscall
li $v0, 5			#syscall code for reading an integer
syscall
bgt $v0, 46, errorLoop1		#if n > 46 (largest possible value of n that can be represented in 32 bits), give error
blt $v0, 0, errorLoop2		#if n is negative, give another error
move $t0, $v0			#user value of n in $t0
mul $t0, $t0, 4			#multiply n by 4 to get indecies of the array
addiu $t0, $t0, 4		#add 4 to n to create ceiling for array
li $t2, 1			# a = $t1, b = $t2, temp = $t3 incrimented index = $t4

fibonacciLoop:
beq $t4, $t0, output		#If $t4 = $t0 (nth item in array is reached), exit loop
sw $t1, fibArray($t4)		#Else, put calculated fibonacci number in array at index $t4
move $t3, $t2			#temp = b
addu $t2, $t2, $t1		#b += a
move $t1, $t3			#a = temp
addiu $t4, $t4, 4		#increment index by 4
j fibonacciLoop			#continue looping

output:
li $t4, 0			#reset incrementing index to 0
li $v0, 4			#syscall code for printing a string
la $a0, output_prompt		#print output_prompt
syscall
subiu $t0, $t0, 4		#remove array ceiling
divu $t0, $t0, 4		#divide by 4 to get original number that user input
li $v0, 1			#syscall code for printing an integer
la $a0, ($t0)			#load n into $a0
syscall
li $v0, 4			#syscall code for printing a string
la $a0, paren			#complete printing of "F(n) = "
syscall
mul $t0, $t0, 4			#multiply n by 4 to get indecies of the array
li $v0, 1			#syscall code for printing an integer
lw $a0, fibArray($t0)		#place nth item in array into $a0
syscall
li $v0, 4			#syscall code for printing a string
la $a0, new_line		#load new_line into $a0
syscall 
li $v0, 4			#syscall code for printing a string
la $a0, arrayOutput		#Load address to output prompt into $a0
syscall 
addiu $t0, $t0, 4		#add 4 to n to create ceiling for array
j outputLoop			#jump to outputLoop to display contents of the array

outputLoop:
beq $t4, $t0, exitLoop		#If $t4 = $t0 (nth item in array is reached), exit loop
li $v0, 1			#syscall code for printing an integer
lw $a0, fibArray($t4)		#Else, retreive calculated fibonacci number in array at index $t4
syscall
li $v0, 4			#syscall code for printing a string
la $a0, space			#Load address to space character into $a0
syscall 
addiu $t4, $t4, 4		#increment index by 4
j outputLoop			#continue looping

errorLoop1:			#error if n is too big
li $v0, 4			#syscall code for printing a string
la $a0, n_too_big		#tell user that n is too large
syscall
li $v0, 4			#syscall code for printing a string
la $a0, new_line		#Load address to new line character into $a0
syscall
li $v0, 4			#syscall code for printing a string
la $a0, new_line		#Load address to new line character into $a0
syscall
j inputLoop			#ask user for n again

errorLoop2:			#error if n is negative
li $v0, 4			#syscall code for printing a string
la $a0, n_not_positive		#tell user that n needs to be positive
syscall
li $v0, 4			#syscall code for printing a string
la $a0, new_line		#Load address to new line character into $a0
syscall
li $v0, 4			#syscall code for printing a string
la $a0, new_line		#Load address to new line character into $a0
syscall
j inputLoop			#ask user for n again

exitLoop:
li $v0, 10			# terminate the program
syscall
