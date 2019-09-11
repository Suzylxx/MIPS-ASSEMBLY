	.data
    in1: .asciiz "Please enter the value of a"
    in2: .asciiz "Please enter the value of b"
    in3: .asciiz "Please enter the value of c"
    none: .asciiz "No solution"

.text
.globl main

main:
    li $v0, 4 #let the user enter the value of a
    la $a0, in1
    syscall
    li $v0, 5 #get a from user
    syscall
    move $t0, $v0 #store value of a in t0
    li $v0, 4 #let the user enter the value of b
    la $a0, in2
    syscall
    li $v0, 5 #get a from user
    syscall
    move $t1, $v0 #store value of a in t1
    li $v0, 4 #let the user enter the value of c
    la $a0, in3
    syscall
    li $v0, 5 #get a from user
    syscall
    move $t2, $v0 #store value of a in t2
    la $t3, none #load no solution into t3
    rem $t4, $t0, $t1 # get a mod b
    li $t5, 1 # this is value of x, set to 1
    li $t7, 0 #this is for checking whether there is solution
    j while
  
while: 
    bgt $t5, $t2, nosolution #when x is greater than c, no solution
    mul $t6, $t5, $t5 #get square of x
    blt $t6, $t4, addmore #when x square is smaller than remainder
    beq $t6, $t4, solution #when x square is equal to remainder
    bgt $t6, $t4, addremainder #when x square is greater than remainder
    
addmore:
    beq $t5, $t2, ifsolution #check if there is solution
    addi $t5, $t5, 1
    j while

addremainder:
    add $t4, $t4, $t1
    j while

solution:
    li $t7, 1 #when there is solution change value of t7 to 1
    li $v0, 1 #print out the solution
    la $a0, ($t5)
    syscall
    li $v0, 11
    la $a0, 32
    syscall
    beq $t5, $t2, end
    addi $t5, $t5, 1
    add $t4, $t4, $t1
    j while

ifsolution:
    beq $t7, 1, end
    j nosolution
      
nosolution:
    li $v0, 4
    la $a0,none
    syscall #print no solution
    j end
   
end:
    li $v0, 10 #end of the program
    syscall
    
    
