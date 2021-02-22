# Who:  Rachel Lewis
# What: sort_array.asm
# Why:  A sorted array where user can find values in the array
# When: 4/2/2018
# How:  $t0: pointer variable, so that array elements can be retreived and stored
#	$t1: pointer variable, within the function that sorts the array
#	$t2: holds element located at array[$t1]
#	$t3: holds element located at array[$t1 - 1]
#	$t4: counter variable, compared to $s1 to branch out of loops
#	$t5: holds largest and smallest value in the array. Also holds temp value of mid/4 to check if index is correct
#	$s1: user value for number of ints in the array
#	$s2: $s1*4, gives user indicated byte size of the array

.data
array:		.space		200
num_of_ints:	.asciiz 	"How many signed integers do you want to put in the array? "
contents:	.asciiz 	"Contents of the array: "
search_value:	.asciiz 	"What value would you like to search for? "
value_found:	.asciiz 	"Value has been found\n\n"
value_not_found:.asciiz 	"Value has not been found\n\n"
new_line:	.asciiz 	"\n"
space:		.asciiz 	" "

.text
.globl main
main:
la $a0, num_of_ints		#prompt user for number of integers to be read in
li $v0, 4			#syscall code for printing a string
syscall
li $v0, 5			#syscall code for reading in an int
syscall
la $s0, ($v0)			#move that value into $s0, so it's protected
mul $s1, $s0, 4			#multiply $s0 by 4 to get byte index to the array. This will be the ceiling
j input_loop			#jump to loop to take in input

input_loop:			
beq $t4, $s1, display_array	#If ceiling of the array is reached, exit loop
li $v0, 5			#syscall code for reading an integer
syscall
sw $v0, array($t0)		#Else, save integer that was read in into index $t0 of array
bgez $v0, dontJump		#If this value is negative, we need the pointer to point immediatley after largest negative value
jal inc
dontJump:
addiu $t4, $t4, 4		#Increment counter
j sort_array			#Begin sorting the array

inc:
addiu $t0, $t0, 4		#Increment pointer to next value after the negative
jr $ra

sort_array:
li $t1, 0 			#($t1)i = 0
jal while
while:
bge $t1, $s1, input_loop	#while(i < n)
beq $t1, 0, first_if		#if(i==0)
bne $t1, 0, intermediate	#if this is not our first value we skip first for loop
first_if:
addiu $t1, $t1, 4		#i++
j while				#jump back to while condition
intermediate:
lw $t2, array($t1)		#$t2 = array(i)
lw $t3, array+-4($t1)		#t3 = array(i - 1)
bge $t2, $t3, second_if		#if[array(i) >= array(i - 1)], which is the desired outcome
blt $t2, $t3, else		#else if[array(i) < array(i - 1)], we must swap the values
second_if:
addiu $t1, $t1, 4		#i++
j while				#jump back to while condition
else:
sw $t2, array+-4($t1)		#array(i - 1) = array(i)
sw $t3, array($t1)		#array(i) = array(i - 1)
subiu $t1, $t1, 4		#i--
jr $ra				#jump back to while condition


display_array:		
move $t0, $0			#reset register $t1 back to 0
la $a0, contents		#Indicate that array contents will be displayed
li $v0, 4			#Syscall code for printing a string
syscall
j output_loop			#jump to output loop

output_loop:
beq $t0, $s1, search		#Once we hit ceiling of array, start asking user for search values
lw $a0, array($t0)		#Else, load array element with index $t0 to register $a0
addiu $t0, $t0, 4		#Incriment contents of $t1 by 4 (bytes)
li $v0, 1			#syscall code for writing an integer
syscall
li $v0, 4			#syscall code for writing a string
la $a0, space			#load address to space character into $a0
syscall
j output_loop			#Continue looping

search:
la $a0, new_line		#new line
li $v0, 4			#syscall code for printing a string
syscall
li $v0, 4			#syscall code for writing a string
la $a0, search_value		#Prompt user for value they want to search for
syscall
li $v0, 5			#syscall code for reading in an int
syscall
move $t0, $v0			#$t0 = search value
li $t1, 0			#$t1 = start
li $t2, 0			#$t2 = mid
move $t3, $s1			#t3 = end
lw $t5, array($t1)		#Load the value located at the beginning of the array into $t5
subiu $t3, $t3, 4		#Decrement ceiling value
beq $t0, $t5, true		#If search value is equal to the value at the beginning of the array, value is found
blt $t0, $t5, false		#If search value is less than the value at the beginning of the array, then we know value cannot be in the array
lw $t5, array($t3)		#Load the value located at the end of the array into $t5
addiu $t3, $t3, 4		#Put ceiling value back where it belongs
beq $t0, $t5, true		#If search value is equal to the value at the end of the array, value is found
bgt $t0, $t5, false		#If search value is greater than the value at the end of the array, then we know value cannot be in the array
j binarySearch			#If none of these are true, then we begin searching

binarySearch:
bgt $t1, $t3, false		#if (start > end) false
subu $t2, $t3, $t1		#mid = [end - start]
divu $t2, $t2, 2		#mid = [end - start] / 2
move $t5, $t2			#move mid value to $t5
divu $t5, $t5, 4		#divide that number by 4
mfhi $t5			#move the remainder to $t5
bnez $t5, shift_address		#if there exists a remainder then we know mid address is off by 2 bytes
cont:
addu $t2, $t2, $t1		#mid = start + [end - start] / 2
lw $t4, array($t2)		#$t4 = array(mid)
beq $t4, $t0, true		#if (array[mid] == searchVal) true
subiu $t3, $t2, 4		#end = mid - 1
bgt $t4, $t0, binarySearch	#if (array[mid] > searchVal) return binSearch
addiu $t3, $t2, 4		#put end value back to where it was
addiu $t1, $t2, 4		#start = mid + 1
j binarySearch			#continue searching

shift_address:			#Fixing an off-by-2 address
beqz $t2, cont			#If mid index = 0, there is nothing to fix, thus we continue back to where we were
subiu $t2, $t2, 2		#Subract 2 from mid index, which will give us a proper address to index of array
j cont				#continue back to where we were

true:
li $v0, 4			#syscall code for printing a string
la $a0, value_found		#tell the user that the value was found
syscall
j search			#ask user for another value to find
false:
li $v0, 4			#syscall code for printing a string
la $a0, value_not_found		#tell the user that the value was not found
syscall
j search			#ask user for another value to find