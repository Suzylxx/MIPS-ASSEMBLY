#name: Suzy Liu
#studentID: 260761416

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "cropped.pgm"	#used as output
buffer:   .align 2
.space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
x1: .word 1
x2: .word 2
y1: .word 3
y2: .word 4
headerbuff: .space 2048  #stores header
#any extra .data you specify MUST be after this line 
conbuff: .space 2048
conbuff2: .align 2 
.space 2048
error:    .asciiz "There is an error."

	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile


    #load the appropriate values into the appropriate registers/stack positions
    #appropriate stack positions outlined in function*
    	addi $sp, $sp, -24
    	la $t0, buffer
    	sw $t0, 16($sp)
    	la $t1, newbuff
    	sw $t1, 20($sp)
	jal crop
	addi $sp, $sp, 24

	la $a0, output		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	#add what ever else you may need to make this work.
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
	addi $t3, $t3, 1 #increment
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


crop:
#a0=x1
#a1=x2
#a2=y1
#a3=y2
#16($sp)=buffer
#20($sp)=newbuffer that will be made
#Remember to store ALL variables to the stack as you normally would,
#before starting the routine.
#Try to understand the math before coding!
#There are more than 4 arguments, so use the stack accordingly.
	#move $t0, 16($sp) #move pointer of buffer into t0
	#move $t1, 20($sp) #move pointer of newbuff into t1
	la $a0, x1 #load address of x1, x2, y1, y2 into registers
	la $a1, x2
	la $a2, y1
	la $a3, y2
	lw $s0, ($a0) #load word of x1, x2, y1, y2
	lw $s1, ($a1)
	lw $s2, ($a2)
	lw $s3, ($a3)
	mul $t2, $s2, 4 # y1*24*4
	mul $t2, $t2, 24
	mul $s4, $s0, 4 # x1*4
	add $t2, $t2, $s4 #get position of start coordinates
	
	
	
	lw $t0, 16($sp) #load stack pointer of buffer into to
	lw $t1, 20($sp) #load stack pointer of newbuff into t1
	sub $t4, $s1, $s0 #get number of columns
	addi $s6, $t4, 1 
	sub $t5, $s3, $s2 #get number of rows
	addi $s7, $t5, 1
	li $t6, 0 #count columns
	li $t7, 0 #count rows
	add $t0, $t0, $t2 #starting at x1, y1
    loop:
	lw $t8, 0($t0)
	sw $t8, 0($t1) 
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	addi $t6, $t6, 1
	blt $t6, $s6, loop #when theres s6 elements move to next row
	li $t6, 0 #reset columns
	addi $t7, $t7, 1 #increments rows
	mul $t9, $s6, -4 #address of next row t0+96-4*col
	addi $t9, $t9, 96
	add $t0, $t0, $t9
	blt $t7, $s7, loop #when theres s7 elemtns move to next column
	jr $ra


writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
#open file to be written to, using $a0.
#convert from int to string
 	 	
convert2:
	move $t1, $a1 #newbuff
	la $t2, conbuff2
	mul $t0, $s6, $s7 #total number of elements
	li $t7, 0 #count for integers
	li $s3, 10
	
conback: 
	lw $t3, 0($t1) #read integer from newbuff
	addi $t7, $t7, 1
	addi $t1, $t1, 4
	bgt $t7, $t0, returnb #if the int come to the end
	blt $t3, 10, moveone #one digits
	div $t3, $s3
	mfhi $t4 #unit digit
	mflo $t5 #tenth digit
	addi $t5, $t5, 48
	sb $t5, 0($t2)
	addi $t2, $t2, 1
	addi $t4, $t4, 48
	sb $t4, 0($t2)
	addi $t2, $t2, 1
	j continue	
	
moveone:
	addi $t3, $t3, 48 #when there is only one digit
	sb $t3, 0($t2)
	addi $t2, $t2, 1 #increment
	j continue
	
continue:
	div $t7, $s6 #check if one row has finished
	mfhi $t8 
	beq $t8, 0, nextline #if the row has finished, go to next line
	li $t3, 32 #the row not finished, add space
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	j conback
	
nextline:
	li $t3, 10 #add new line
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
	
writeheader:
	li $t3, 0 #count number of bytes in header
    	la $a2, headerbuff
    	la $t5, 0($a2)
    	li $t7, 80 #P
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	li $t7, 50 #2
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	li $t7, 10 #new line
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
#check for number of width   	
    checkcol:
    	move $t1, $s6 #width
    	bgt $t1, 9, twodigitw #if columns are two digits go to twodigit
    	addi $t1, $t1, 48 #column
    	sb $t1, 0($t5)
    	addi $t5, $t5, 1
    	addi $t3, $t3, 1
    	j height
    	
    twodigitw:
    	li $t0, 10 
    	div $t1, $t0 #get each digit
    	mflo $t1 #tenth digit
    	mfhi $t2 #unit digit
    	addi $t1, $t1, 48
    	sb $t1, 0($t5)
    	addi $t3, $t3, 1 #increment
    	addi $t5, $t5, 1
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1 #increment
    	addi $t5, $t5, 1
    	j height
#check for number of height   	
     height:
    	li $t7, 32 #space
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	move $t2, $s7 #height
    	bgt $t2, 9 twodigith #if height has two digits
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	j goon
    
    twodigith:
    	li $t0, 10
    	div $t2, $t0 #get each digit
    	mflo $t1 #tenth digit
    	mfhi $t2 #unit digit
    	addi $t1, $t1, 48
    	sb $t1, 0($t5)
    	addi $t3, $t3, 1 #increment
    	addi $t5, $t5, 1
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1 #increment
    	addi $t5, $t5, 1
    	j goon
    		
    goon:
    	li $t7, 10 #newline
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	li $t7, 49 #1
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	li $t7, 53 #5
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	li $t7, 10 #newline
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1   	
   	
#write the content stored at the address in $a1.
	li $v0, 15
	blt $v0, $t0, errorexist
	move $a0, $s0
	la $a1, headerbuff
	la $a2, ($t3)
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


