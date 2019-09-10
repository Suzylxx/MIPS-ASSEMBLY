# This program illustrates an exercise of capitalizing a string.
# The test string is hardcoded. The program should capitalize the input string
# Comment your work

	.data

inputstring: 	.asciiz "I am a student at McGill University "
outputstring:	.space 100

.text
.globl main
main:
    la $t0, inputstring  #load inputstring into t0
    la $t1, outputstring #load outputstring into t1

loop:
    lb $t2, 0($t0) #loads one byte of data from input to t2
    beq $t2, 0, end #checking end condition
    blt $t2, 'a', isupper #this means the character is uppercase
    bgt $t2, 'z', isupper #check if the character is uppercase
    sub $t2, $t2, 32 #change lowercase character into uppercase character
    sb $t2, 0($t1) #stores one byte of data from t2 in outputstring
    addi $t0, $t0, 1 #goes to next position
    addi $t1, $t1, 1 #start saving character at next position
    j loop

isupper: 
    sb $t2, 0($t1) #stores one byte of data from t2 in outputstring
    addi $t0, $t0, 1 #goes to next position
    addi $t1, $t1, 1 #start saving character at next position
    j loop

end:
    li $v0, 4
    la $a0,inputstring
    syscall #print inputstring
    li $v0, 4
    la $a0,outputstring
    syscall #print outputstring

    li $v0, 10 #end of the program
    syscall
