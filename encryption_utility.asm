# Who:  Rachel Lewis
# What: encryption_utility.asm
# Why:  Read from and write to a file while encrypting the contents
# When: 5/5/2019 
# How: $t0: address to CONSOLE_RECEIVER_CONTROL, input read counter, counter for file data buffer
#      $t1: file read buffer counter, address to bytes in buffer, counter for passphrase buffer
#      $t2: byte from file data buffer
#      $t3: byte from passphrase buffer
#      $s0: address to CONSOLE_RECEIVER_DATA, file description for DST file
#      $s1: file description for SRC file
#      $s2: number of characters read in from file
.data
SRC_Path_Buffer:	.space		256
DST_Path_Buffer:	.space		256
Passphrase_Buffer:	.space		257
Encryption_Buffer:	.space		1024
.eqv	CONSOLE_RECEIVER_CONTROL        0xffff0000
.eqv	CONSOLE_RECEIVER_READY_MASK     0x00000001
.eqv	CONSOLE_RECEIVER_DATA           0xffff0004
asterisk:		.asciiz 	"*"
SRC_Prompt:		.asciiz 	"Enter source file path: "
DST_Prompt:		.asciiz		"Enter destination file path: "
Pass_Prompt:		.asciiz		"Enter a passphrase: "
error_prompt1:		.asciiz		"There was an error in opening the SRC file"
error_prompt2:		.asciiz		"There was an error in opening the DST file"
error_prompt3:		.asciiz		"There was an error in reading from the SRC file"
error_prompt4:		.asciiz		"There was an error in writing to the DST file"
.align 2

.text

#prompt for source file path
la $a0, SRC_Prompt			#load source file prompt into $a0
li $v0, 4				#syscall code for print string
syscall
la $a0, SRC_Path_Buffer			#load address to source file buffer in $a0
li $a1, 256				#number of characters to read in $a1
li $v0, 8				#syscall code for reading a string
syscall

#prompt for destination file path
la $a0, DST_Prompt			#load destination file prompt into $a0
li $v0, 4				#syscall code for print string
syscall
la $a0, DST_Path_Buffer			#load address to destination file buffer in $a0
li $a1, 256				#number of characters to read in $a1
li $v0, 8				#syscall code for reading a string
syscall

#prompt for passphrase
la $a0, Pass_Prompt			#prompt user for pass phrase
li $v0, 4				#syscall code for print string
syscall

passphrase:
lw $t0, CONSOLE_RECEIVER_CONTROL	#load receiver control into $t0
andi $t0, $t0, CONSOLE_RECEIVER_READY_MASK  #check if that value exists
beqz $t0, passphrase			#if it doesn't, then loop back to continue waiting for input

lbu $s0, CONSOLE_RECEIVER_DATA		#else, load that received value into $s0
li $a0, '*'				#load an asterisk into $a0, which we will print later
beq $s0, 10, clean_SRC			#once we reach a value of 10 (enter key) stop collecting passphrase
beq $t1, 257, clean_SRC			#once buffer is filled stop collecting passphrase
sb $s0, Passphrase_Buffer($t1)		#store that value into the Passphrase_Buffer at index $t1
addiu $t1, $t1, 1			#increpent buffer counter $t1
li $v0, 11				#syscall code for printing a string
syscall					

j passphrase				#continue looping

clean_SRC:				#scrub user-defined source file of enter keys
li $t0, 0       			#loop counter
clean1:
beq $t0, 256, clean_DST			#if we have read the enire buffer, start cleaning the DST file
lb $t1, SRC_Path_Buffer($t0)		#load byte from buffer into $t1
bne $t1, 10, L1				#if that byte != enter-key then continue to the next byte
sb $zero, SRC_Path_Buffer($t0)		#else, if byte = enter-key, then replace that byte with 0
L1:
addi $t0, $t0, 1			#increment counter
j clean1				#continue looping

clean_DST:				#scrub user-defined destination file of enter keys
li $t0, 0      				#loop counter
clean2:
beq $t0, 256, open_files		#if we have read the enire buffer, start opening the files
lb $t1, DST_Path_Buffer($t0)		#load byte from buffer into $t1
bne $t1, 10, L2				#if that byte != enter-key then continue to the next byte
sb $zero, DST_Path_Buffer($t0)		#else, if byte = enter-key, then replace that byte with 0
L2:
addi $t0, $t0, 1			#increment counter
j clean2				#continue looping

open_files:
#Open files
la $a0, DST_Path_Buffer			#load address to destination file name into $a0
li $a1, 1				#write only, don't append
li $a2, 0				
li $v0, 13				#syscall code for opening a file
syscall
move $s0, $v0				#file description for DST file in $s0

la $a0, SRC_Path_Buffer			#load address to source file name into $a0
li $a1, 0				#read only
li $a2, 0
li $v0, 13				#syscall code for opening a file
syscall
move $s1, $v0				#file description for SRC file in $s1

#read from source file
read_file:
move $a0, $s1				#copy SRC file description into $a0
la $a1, Encryption_Buffer		#address of file-reading buffer put into $a1
li $a2, 1024				#we want to read 1024 characters
li $v0, 14				#syscall code for reading a file
syscall
move $s2, $v0				#number of characters read in placed into $s2

li $t0, 0				#$t0 = counter for file data buffer
li $t1, 0				#$t1 = counter for passphrase buffer
encryption:
beq $t0, $s2, write_file		#if file buffer counter = number of characters read in, we begin writing to the file
lb $t2, Encryption_Buffer($t0)		#else, load byte from file data buffer into $t2
lb $t3, Passphrase_Buffer($t1)		#load byte from passphrase buffer into $t3
beq $t3, 0, reset			#if that byte = null terminator, then reset passphrase pointer
beq $t3, 10, reset			#if that byte = enter-key, then reset passphrase pointer
cont:
xor $t2, $t2, $t3			#bitwise or operation on file data and passphrase
sb $t2, Encryption_Buffer($t0)		#result stored into file data buffer at index $t0
addiu $t0, $t0, 1			#increment file data counter
addiu $t1, $t1, 1			#increment passphrase counter
j encryption				#continue looping
reset:
li $t1, 0				#reset passphrase pointer back to 0
lb $t3, Passphrase_Buffer($t1)		#load byte from passphrase buffer into $t3
j cont

#write to destination file
write_file:
move $a0, $s0				#copy DST file description into $a0
la $a1, Encryption_Buffer		#address of file-reading buffer put into $a1
move $a2, $s2				#number of characters we write = number of characters we read in from SRC file
li $v0, 15				#syscall code for writing to a file
syscall
bnez $s2, read_file			#if we didn't reach the end of the file, continue the whole process again

#close files
close_file:
move $a0, $s0				#move DST file file description into $a0
li $v0, 16				#syscall code for closing a file
syscall
move $a0, $s1				#move SRC file file description into $a0
li $v0, 16				#syscall code for closing a file
syscall

exit:	
li $v0, 10				#terminate the program
syscall