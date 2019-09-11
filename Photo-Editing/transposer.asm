#name: Suzy Liu

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "transposed.pgm"	#used as output
buffer:  .align 2
.space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

#any extra data you specify MUST be after this line 
conbuff: .space 2048
conbuff2: .align 2 
.space 2048
error:    .asciiz "There is an error."
towrite:  .asciiz "P2\n7 24\n15\n"

	.text
	.globl main

main:	la $a0,input 		#readfile takes $a0 as input
	jal readfile


	la $a0,buffer		#$a0 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a1 will specify the buffer that will hold the flipped array.
    	jal transpose


	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
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
#done in Q1
#Open the file to be read,using $a0
	li $v0, 13
	li $t0, 0
	blt $v0, $t0, errorexist
	la $a0, input
	syscall
	move $s0, $v0
# read from file
	li $v0, 14
	move $t2, $v0
	blt $v0, $t0, errorexist
	move $a0, $s0
	la $a1, conbuff
	li $a2, 2048
	syscall
# close the file (make sure to check for errors)
	li $v0, 16
	move $a0, $s0
	syscall
	la $t3, conbuff
	la $t4, buffer
	j convert
	
convert:
	lb $t0, 0($t3) 
	beqz $t0, return #if the string come to the end
	blt $t0, 48, movenext #see if the character is a number
	addi $t0, $t0, -48
	addi $t3, $t3, 1  #check next char
	lb $t1, 0($t3) 
	blt $t1, 48, movenexts #store t0 in t4, one digit
	mul $t0, $t0, 10 #when next char is number, t0 times 10
	addi $t1, $t1, -48
	add $t0, $t0, $t1 #t0 = 10*t0+t1
	sw $t0, 0($t4) #store the value in buffer, two digits
	addi $t3, $t3, 1
	addi $t4, $t4, 4
	j convert	
	
movenext:
	addi $t3, $t3, 1 #increment
	j convert

movenexts:
	sw $t0, 0($t4) #store the value in buffer
	addi $t4, $t4, 4 #increment
	addi $t3, $t3, 1 
	j convert		

return:	
	jr $ra		

transpose:
#Can assume 24 by 7 again for the input.txt file
#Try to understand the math before coding!
	li $t0, 0 # i=0-23
	li $t1, 0 # j=0-7
    loop1:
    	lw $t3, 0($a0) #start from first element in first row
    	sw $t3, 0($a1)
    	addi $a0, $a0, 96 #first element in next row
    	addi $a1, $a1, 4
    	addi $t1, $t1, 1
    	blt $t1, 7, loop1 #when a row has not completed, continue
    	li $t1, 0 #reset number of integers in a row
    	addi $t0, $t0, 1
    	addi $a0, $a0, -668 #go to first element in next column
    	blt $t0, 24, loop1 #when a column has not completed, continue
    	jr $ra
    
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
#open file to be written to, using $a0.
#convert from int to string
	move $t1, $a1
	la $t2, conbuff2
	li $t0, 0 #count for columns
	li $t7, 0 #count for integers
	
conback: 
	lw $t3, 0($t1) #read integer from newbuff
	addi $t7, $t7, 1
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	bgt $t7, 168, returnb #if the int come to the end
	blt $t3, 10, moveone #one digits
	li $t4, 49 #first digit is 1
	sb $t4, 0($t2)
	addi $t2, $t2, 1
	addi $t3, $t3, -10 #second digit
	addi $t3, $t3, 48
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	blt $t0, 7, continue #when number of integers is not 7, continue
	li $t3, 10 #one column finished, go to new column
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	li $t0, 0 #reset number of integers in a row
	j conback	
	
moveone:
	addi $t3, $t3, 48
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	blt $t0, 7, continue #when number of integers is not 7, continue
	li $t3, 10 #one column finished, go to new column
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	li $t0, 0 #reset number of integers in a row
	j conback
	
continue:
	li $t3, 32 #print a space
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	j conback
#open file
returnb:
	li $v0, 13
	li $t0, 0
	blt $v0, $t0, errorexist
	la $a0, output
	la $a1, 1
	syscall
	move $s0, $v0
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
	la $a1, conbuff2
	li $a2, 2048
	syscall	
	
#close the file (make sure to check for errors)
	li $v0, 16
	move $a0, $t2
	syscall	
	
	jr $ra
