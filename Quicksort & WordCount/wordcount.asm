#studentName: Suzy Liu

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line 
str1: .asciiz "Word count\nEnter the text segment:\n"
str2: .asciiz "\nEnter the search word:\n"
str3: .asciiz "\nThe word '"
str4: .asciiz "' occured "
str5: .asciiz " time(s)."
str6: .asciiz "\npress 'e' to enter another segment of text or 'q' to quit.\n"
sentence: .space 2048
word: .space 2048


	.text
	.globl main

main:	# all subroutines you create must come below "main"
	li $t8, 0 #count times of entering echo
	li $t9, 1 #count display times
	la $t7, word #address of entered word
	la $t6, sentence #address of entered sentence
	lui $t0, 0xffff
	la $a1, str1
    display1:
	lb $t1, 0($a1) #displays the first string on mmio, enter the sentence
	addi $a1, $a1, 1
	beq $t1, 0, echo #let user enter
	sw $t1, 12($t0)
	j display1	
	
    display:
	addi $t9, $t9, 1 #increment display times
	beq $t9, 2, display2 #enter the word
	beq $t9, 3, display3 #count words and finish program
	
    display2:
	lui $t0, 0xffff
	la $a1, str2
    dis2:
	lb $t1, 0($a1) #displays the str2 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, echo
	sw $t1, 12($t0)
	j dis2
	
    display3:
    	lui $t0, 0xffff
	la $a1, str3
    dis3:
	lb $t1, 0($a1) #displays the str3 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, displayword
	sw $t1, 12($t0)
	j dis3
    displayword:
    	la $t7, word #display the word searched
    displayword1:
    	lb $t1, 0($t7)
    	addi $t7, $t7, 1 #increment
    	beq $t1, 10, displaynext #after word searched displayed, display next
    	sw $t1, 12($t0)
	j displayword1
    displaynext:
    	la $a1, str4 
    displaynext1:
    	lb $t1, 0($a1) #displays the str4 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, search1 #count times of word displayed on the screen
	sw $t1, 12($t0)
	j displaynext1
    search1:
    	la $a0, sentence 
    	la $a1, word
    	li $t3, 0 #count word display times
    search2:
    	lb $t4, 0($a0) #load character of sentence
    	lb $t5, 0($a1) #load character of word
    	beq $t5, 10, check #when word finish check if word in sentence finish as well
    	beq $t4, 0, displaynumber #when sentence finish
    	beq $t4, $t5, goon #when character of word and sentence are the same, continue
    	addi $a0, $a0, 1 #character of word and sentence does not match
    	la $a1, word #start word again
    	j search2
    goon:
    	addi $a0, $a0, 1
    	addi $a1, $a1, 1
    	j search2
    check: 
    	blt $t4, 48, count #word in sentence finished
    	addi $a0, $a0, 1 #word in sentence does not finish
    	la $a1, word #start word again
    	j search2
    count:
    	addi $t3, $t3, 1 #increment word display times
    	beq $t4, 0, displaynumber #when sentence finish
    	addi $a0, $a0, 1
    	la $a1, word #start word again
    	j search2
    displaynumber:
    	li $s0, 10 #set s0 to 10
    	div $t3, $s0 #see if it's two digits
    	mflo $t4 #10th
    	mfhi $t5 #one digit
    	beqz $t4, one #the number is one digit
    	addi $a0, $t4, 48 #make it an integer
    	jal Write
    	addi $a0, $t5, 48 #make it an integer
    	jal Write
    	j fin
    one:
    	addi $a0, $t5, 48 #make it an integer
    	jal Write
	j fin	
    fin:
    	la $a1, str5
    fin1:
    	lb $t1, 0($a1) #displays the str5 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, clear1
	sw $t1, 12($t0)
	j fin1
    clear1:
    	la $a2, sentence #load address of array
    clear11:
    	lb $t2, 0($a2) #load byte
    	beq $t2, 0, clear2 #if its null, then array has re-initialized
    	#re-initialize array
    	sb $0, 0($a2)
    	addi $a2, $a2, 1
    	j clear11
    clear2:
    	la $a2, word #load address of array
    clear22:
    	lb $t2, 0($a2) #load byte
    	beq $t2, 0, fin2 #if its null, then array has re-initialized
    	#re-initialize array
    	sb $0, 0($a2)
    	addi $a2, $a2, 1
    	j clear22
    fin2:
    	la $a1, str6
    fin22:
    	lb $t1, 0($a1) #displays the str5 on mmio
	addi $a1, $a1, 1
	beq $t1, 0, echo
	sw $t1, 12($t0)
	j fin22  			
echo:	
	addi $t8, $t8, 1 #increment echo entering time
echo1:
	jal Read		# reading and writing using MMIO
	add $a0,$v0,$zero	# in an infinite loop
	jal Write
	j echo1

Read:  	lui $t0, 0xffff 	#ffff0000
Loop1:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1
	lw $v0, 4($t0) 		#data	
	j save
    save: 
	beq $t8, 1, savesentence #first enter echo, input is sentence
	beq $t8, 2, saveword #second time enter echo, input is searched word
	beq $t8, 3, finish #third time enter echo, rerun or quit
    savesentence: 
	sb $v0, 0($t6) #save entered sentence into t6
	addi $t6, $t6, 1
	j continue
    saveword:
	sb $v0, 0($t7) #save entered word into t7
	addi $t7, $t7, 1
	j continue
    finish:
	beq $v0, 101, main #press 'e'
	beq $v0, 113, end #press 'q'
    end: 
	li $v0,10		# exit
	syscall
	
continue:
	beq $v0, 10, display 
	jr $ra

Write:  lui $t0, 0xffff 	#ffff0000
Loop2: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	sw $a0, 12($t0) 	#data	
	jr $ra
