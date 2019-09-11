#studentName: Suzy Liu

# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
#any any data you need be after this line 
array: .space 2048 #entered array
convert:	.space 2048 #convert to integer
convertback:  .space 2048 #convert sorted array back into char
str1: .asciiz "Welcome to QuickSort\n"
str2: .asciiz "\nThe sorted array is: "
str3: .asciiz "\nThe array is re-initialized\n"


	.text
	.globl main

main:	# all subroutines you create must come below "main"
	la $t9, array #address of entered numbers
	lui $t0, 0xffff
	la $a1, str1
	
    display1:
	lb $t1, 0($a1) #displays the first string on mmio, enter the list of numbers
	addi $a1, $a1, 1
	beq $t1, 0, echo #let user enter
	sw $t1, 12($t0)
	j display1
	
echo:	
	jal Read		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	jal Write
	j echo

Read:  	lui $t0, 0xffff 	#ffff0000
Loop1:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1
	lw $v0, 4($t0) 		#data	
	j save
save: 
    	beq $v0, 99, clear #press 'c'
    	beq $v0, 115, convert1 #press 's'
    	beq $v0, 113, quit #press 'q'
    	beq $v0, 32, savespace
    	sb $v0, 0($t9) #save entered number as char into array
    	addi $t9, $t9, 1
    	j continue
    savespace:
    	sb $v0, 0($t9) #save space into array
    	addi $t9, $t9, 1
    	j continue
clear:
    	la $t9, array #load address of array
    clear1:
    	lb $t8, 0($t9) #load byte
    	beq $t8, 0, clear2 #if its null, then array has re-initialized
    	li $t8, 0 #re-initialize array
    	sb $t8, 0($t9)
    	addi $t9, $t9, 1
    	j clear1
    clear2:
    	li $t1, -1 #count number of integers
    	la $t9, convert #load address of array
    clear22:
    	lw $t8, 0($t9) #load byte
    	bgt $t1, $t4, clear3 #if its null, then array has re-initialized
    	li $t8, 0 #re-initialize array
    	sw $t8, 0($t9)
    	addi $t1, $t1, 1
    	addi $t9, $t9, 4
    	j clear22
    clear3:
    	la $t9, convertback #load address of array
    clear33:
    	lb $t8, 0($t9) #load byte
    	beq $t8, 0, again #if its null, then array has re-initialized
    	li $t8, 0 #re-initialize array
    	sb $t8, 0($t9)
    	addi $t9, $t9, 1
    	j clear33
    again:
    	la $t9, array #load address of re-initialized array
    	lui $t0, 0xffff
	la $a1, str3
    display3:
	lb $t1, 0($a1) #displays str3 on mmio, enter new list of numbers
	addi $a1, $a1, 1
	beq $t1, 0, echo #let user enter
	sw $t1, 12($t0)
	j display3	
convert1: #convert to integers
	li $s0, 32 #save space
    	sb $s0, 0($t9) #save space into array
    	addi $t9, $t9, 1
    	la $a1, array
    	la $a2, convert
    	li $t4, -1 #count number of entered integers
    convert2:
    	lb $t2, 0($a1)
    	beqz $t2, sorting #when the array all convert to integer, start sorting
    	beq $t2, 32, next #when there is a space
    	addi $t2, $t2, -48 #convert to integer
    	addi $a1, $a1, 1 #check next char
    	lb $t3, 0($a1) 
    	blt $t3, 48, onedigit #the integer is one digit
    	mul $t2, $t2, 10
    	addi $t3, $t3, -48
    	add $t2, $t2, $t3 #t2 = 10*t2 +t3
    	sw $t2, 0($a2) #store two digits integer in convert array
    	addi $t4, $t4, 1 #increment number of entered integers
    	addi $a1, $a1, 1 #increment
    	addi $a2, $a2, 4
    	j convert2
    onedigit:
    	sw $t2, 0($a2) #store one digit integer in convert array
    	addi $t4, $t4, 1 #increment number of entered integers
    	addi $a1, $a1, 1 #increment
    	addi $a2, $a2, 4
    	j convert2
    next:
    	addi $a1, $a1, 1 #increment
    	j convert2
#use algorithm with last element as pivot
#quickSort(arr[], low, high){
#    if (low < high){
#        pi = partition(arr, low, high);
#        quickSort(arr, low, pi - 1);  // Before pi
#        quickSort(arr, pi + 1, high); // After pi}}
#a0 = low; a1 = high
sorting:
	move $s7, $t4 #save number of entered integers in s7, will use when print sorted array
	li $a0, 0 #a0=low
    	addi $a1, $t4, 0 #a1=high
	jal sort
	j display2 #print str2 and sorted array
sort:
	bge $a0, $a1, return #print sorted array when low>=high
	addi $sp, $sp, -16 #use stack to store return value, low and high
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	jal partition
	move $s0, $v0 #pivot
	sw $s0, 12($sp) #save pivot in stack as well
    sort1: #quicksort(array, low, pivot-1)
	addi $s0, $s0, -1 #pivot-1
	lw $a0, 4($sp) #low
	move $a1, $s0 #hi
	jal sort
    sort2: #quicksort(array, pivot+1, hi)
	lw $s0, 12($sp) #pivot
	addi $s0, $s0, 1 #pivot+1
	move $a0, $s0 #low
	lw $a1, 8($sp) #hi
	jal sort
	lw $ra, 0($sp) #return ra value
	addi $sp, $sp, 16 #close stack
    return:
	jr $ra
#partition (arr[], low, high){
#    pivot = arr[high];  
#    i = (low - 1)  // Index of smaller element
#    for (j = low; j < high; j++){
#        if (arr[j] < pivot){
#            i++;    // increment index of smaller element
#            swap arr[i] and arr[j]       }}
#    swap arr[i + 1] and arr[high])
#    return (i + 1)}
#s0 = low; s1 = hi; s2 = pivot; s3 = i; s4 = j
partition:
	addi $sp, $sp, -24 #create stack
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	la $t0, convert
	sll $t1, $a1, 2 #get position of pivot, a1 is high from sort
	add $t1, $t1, $t0
	lw $s2, ($t1) #get element at pivot s2 = pivot
	move $s0, $a0 #low
	move $s1, $a1 #high
	addi $s3, $s0, -1 #i=low-1
	move $s4, $s0 #j=low
    for:
	bge $s4, $s1, swap #j>=hi, for loop finished, swap(a, i+1, high)
	sll $t1, $s4, 2 #get position of j 
	add $t1, $t1, $t0
	lw $t3, ($t1) #get element at j, t3 = a[j] 
	bge $t3, $s2, increment #a[j]>=pivot, for loop again
	addi $s3, $s3, 1 #i++
	move $a0, $s3 #low update
	move $a1, $s4 #high update
	jal swap1 #swap(a, i, j)
	addi $s4, $s4, 1 #j++
	j for
    increment:
	addi $s4, $s4, 1 #j++
	j for
#used algotithm in A4 pdf
swap:
	addi $s3, $s3, 1 #i+1
	move $a0, $s3 #update low=i+1
	move $a1, $s1 #update hi=hi
	move $v0, $s3 #save returned value (i+1)
	jal swap1
	lw $ra, 0($sp) #reload all values saved in stack
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	jr $ra
    swap1:
	la $t0, convert #load adress of converted array
	sll $a0, $a0, 2 #get position of low
	add $t1, $t0, $a0 
	lw $t3, ($t1) #a[low]
	la $t2, convert #load adress of converted array
	sll $a1, $a1, 2 #get position of high
	add $t2, $t2, $a1
	lw $t4, ($t2) #a[high]
	sw $t4, ($t1) #a[high]=a[low]
	sw $t3, ($t2) #a[low]=a[high]
	jr $ra
display2:
    	lui $t0, 0xffff
	la $a1, str2
    dis2:
	lb $t1, 0($a1) #displays the str2 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, conback
	sw $t1, 12($t0)
	j dis2
conback:
    	la $a1, convert
    	la $a2, convertback
    	li $t1, -1 #count number of integers
    conback1:
    	lw $t2, 0($a1)
    	bge $t1, $s7, print
    	li $s0, 10
    	div $t2, $s0 #see if its one digit or two digits
    	mflo $t5 #10th
    	mfhi $t6 #one digit
    	beqz $t5, one #the number is one digit
    	addi $t5, $t5, 48 #first save 10th in convertback array
    	sb $t5, 0($a2)
    	addi $a2, $a2, 1
    	addi $t6, $t6, 48 #then save one digit in convertback array
    	sb $t6, 0($a2)
    	addi $a1, $a1, 4 #increment
    	addi $t1, $t1, 1
    	addi $a2, $a2, 1
    	li $t7, 32 #save space
    	sb $t7, 0($a2)
    	addi $a2, $a2, 1
    	j conback1
    one:
    	addi $t6, $t6, 48
    	sb $t6, 0($a2)
    	addi $a1, $a1, 4 #increment
    	addi $t1, $t1, 1
    	addi $a2, $a2, 1
    	addi $t7, $zero, 32 #save space
    	sb $t7, 0($a2)
    	addi $a2, $a2, 1
    	j conback1
print:
    	la $a1, convertback #print sorted array
    print1:
    	lb $t2, 0($a1)
    	addi $a1, $a1, 1 #increment
    	beqz $t2, changeline #finish printing sorted array
    	sw $t2, 12($t0)
    	j print1
    changeline:
    	li $t2, 10
    	sw $t2, 12($t0)
    	j echo
    quit:
    	li $v0,10		# exit
	syscall	
continue:
	jr $ra

Write:  lui $t0, 0xffff 	#ffff0000
Loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	sw $a0, 12($t0) 	#data	
	jr $ra
















