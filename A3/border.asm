#name: Suzy Liu
#studentID: 260761416

.data

#Must use accurate file path.
#file paths in MARS are relative to the mars.jar file.
# if you put mars.jar in the same folder as test2.txt and your.asm, input: should work.
input:	.asciiz "test1.txt"
output:	.asciiz "borded.pgm"	#used as output

borderwidth: .word 2    #specifies border width
buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048
headerbuff: .space 2048  #stores header

#any extra data you specify MUST be after this line
conbuff: .space 2048
conbuff2: .align 2 
.space 2048
error:    .asciiz "There is an error." 


	.text
	.globl main

main:	la $a0,input		#readfile takes $a0 as input
	jal readfile
	

	la $a0,buffer		#$a1 will specify the "2D array" we will be flipping
	la $a1,newbuff		#$a2 will specify the buffer that will hold the flipped array.
	la $a2,borderwidth
	jal bord

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
	addi $t3, $t3, 1
	j convert

movenexts:
	sw $t0, 0($t4) #store the value in buffer
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	j convert		

return:	
	jr $ra	


bord:
#a0=buffer
#a1=newbuff
#a2=borderwidth
#Can assume 24 by 7 as input
#Try to understand the math before coding!
#EXAMPLE: if borderwidth=2, 24 by 7 becomes 28 by 11.

	la $t2, 0($a0) #buffer
        lw $t0, 0($a2) #borderwidth
	mul $t0, $t0, 2 #get border width
	addi $s1, $t0, 24 #save new width into a saved regisdter
	addi $s2, $t0, 7 #save new height into a saved register
	
	lw $t0, 0($a2) #borderwidth
    next:
    	move $t1, $s1 #reset number of width
	addi $t0, $t0, -1
	blt $t0, $0, original #upper border finished, go to the place where contains original image
	j upborder
    upborder:	
	li $t5, 15 #load value of white border
	sw $t5, 0($a1)	
	addi $a1, $a1, 4
	addi $t1, $t1, -1
	ble $t1, 0, next #one row has finished, go to next row
	j upborder #one row has not finished, continue
    original:
	addi $t4, $0, -1 #row
    origin:	
	addi $t3, $0, 0	#column
	addi $t4, $t4, 1 #row
	bgt $t4, 6, lowborder #the part contains original image finished, go to lowere border
	lw $t9, 0($a2) #border width 
	j leftb
    leftb:#left border of part contains original image	
	li $t5, 15 
	sw $t5, 0($a1)
	addi $a1, $a1, 4
	addi $t9, $t9, -1
	ble $t9, 0, index #left border of one row finished, go to original image
	j leftb
    getwidth:
    	lw $t9, 0($a2)		# border width = right margin size
    rightb:
	li $t5, 15 #white border
	sw $t5, 0($a1)
	addi $a1, $a1, 4
	addi $t9, $t9, -1
	ble $t9, $0, origin #right border of one row finished, go to next row
	j rightb
    index:	
	mul $t5, $t4, 24 #get position
	add $t5, $t5, $t3
	bgt $t3, 23, getwidth #original image part finished, go to right border
	la $t2, 0($a0) #buffer
	j getposition
    getposition:	
	beq $t5, $0, gotoposition #go to the original image and store
	addi $t2, $t2, 4
	addi $t5, $t5 -1
	j getposition
    gotoposition: #store the original image
	lw $t6, 0($t2)
	sw $t6, 0($a1)
	addi $a1, $a1, 4
	addi $t3, $t3, 1
	j index #go to the next element
    lowborder:
    	lw $t7, 0($a2) #load value or width or border
    next2:	
	move $t1, $s1 #reset number of width
	addi $t7, $t7, -1
	blt $t7, $0, end #lower border finished, return
	j low
    low:	
	addi $t5, $0, 15 #add lower border
	sw $t5, 0($a1)
	addi $a1, $a1, 4
	addi $t1, $t1, -1
	ble $t1, $0, next2 #one row finished, go to next row
	j low

end: jr $ra
    
writefile:
#slightly different from Q1.
#use as many arguments as you would like to get this to work.
#make sure the header matches the new dimensions!
#open file to be written to, using $a0.
#convert from int to string
 	 	
convert2:
	move $t1, $a1 #newbuff
	la $t2, conbuff2
	mul $t0, $s1, $s2 #total number of elements
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
	addi $t3, $t3, 48
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	j continue
	
continue:
	div $t7, $s1 #check if one row has finished
	mfhi $t8
	beq $t8, 0, nextline
	li $t3, 32
	sb $t3, 0($t2)
	addi $t2, $t2, 1
	j conback
	
nextline:
	li $t3, 10
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
    	
    checkcol:
    	move $t1, $s1 #width
    	bgt $t1, 9, twodigitw #if columns are two digits go to twodigit
    	addi $t1, $t1, 48 #column
    	sb $t1, 0($t5)
    	addi $t5, $t5, 1
    	addi $t3, $t3, 1
    	j height
    	
    twodigitw:
    	li $t0, 10
    	div $t1, $t0
    	mflo $t1 #tenth digit
    	mfhi $t2 #unit digit
    	addi $t1, $t1, 48
    	sb $t1, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	j height
    	
     height:
    	li $t7, 32
    	sb $t7, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	move $t2, $s2 #height
    	bgt $t2, 9 twodigith
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	j goon
    
    twodigith:
    	li $t0, 10
    	div $t2, $t0
    	mflo $t1 #tenth digit
    	mfhi $t2 #unit digit
    	addi $t1, $t1, 48
    	sb $t1, 0($t5)
    	addi $t3, $t3, 1
    	addi $t5, $t5, 1
    	addi $t2, $t2, 48
    	sb $t2, 0($t5)
    	addi $t3, $t3, 1
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

