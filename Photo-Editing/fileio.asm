#name: Suzy Liu

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt" #used as input
output:	.asciiz "copy.pgm"	#used as output
error:    .asciiz "There is an error."
towrite:  .asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile

	la $a0, output		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

errorexist:
#print error string if error exists
	li $v0, 4
	la $a0, error
	syscall
	li $v0, 10 #end of the program
          syscall
	
readfile:
#Open the file to be read,using $a0
	li $v0, 13
#Conduct error check, to see if file exists
	blt $v0, 0, errorexist
# You will want to keep track of the file descriptor*
	li $a1, 0
	syscall
	move $s0, $v0
# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file
	li $v0, 14
	blt $v0, 0, errorexist
	move $a0, $s0
	la $a1, buffer
	li $a2, 2048
	syscall
# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)
	li $v0, 16
	move $a0, $s0
	syscall

	jr $ra
	
writefile:
#open file to be written to, using $a0.
	li $v0, 13
	li $t0, 0
	blt $v0, $t0, errorexist
	la $a0, output
	la $a1, 1
	syscall
	move $s0, $v0
#write the specified characters as seen on assignment PDF:
#P2
#24 7
#15
#write the content stored at the address in $a1.
	li $v0, 15
	blt $v0, $t0, errorexist
	move $a0, $s0
	la $a1, towrite
	li $a2, 11
	syscall
#copy	
	li $v0, 15
	blt $v0, $t0, errorexist
	move $a0, $s0
	la $a1, buffer
	li $a2, 2048
	syscall
	
#close the file (make sure to check for errors)
	li $v0, 16
	move $a0, $t2
	syscall	
	
	jr $ra
