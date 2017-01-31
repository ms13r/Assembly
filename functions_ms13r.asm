#Miroslav Sanader -- 23/11/2015
#Assignment 7 -- CDA 3100
#functions.asm -- a simple program designed to test if a larger integer is twice
#                 the amount of the smaller integer (n>2x), as well as to see the
#                 amount of times that the integer is present within an integer array.


#########################################
#               Main Func               #
#                                       #
#            Registers Used:            #
#          ------------------           #
#         $a0 = start of array          #
#         $a1 = number to find          #
#	  $a2 = size of array	        #
#	  $v0 = syscall param           #
#########################################


    .data 
Num:    .word 1, 2, 3, 4, 5, 6 

    .text
    .globl main
main:
    la $a0, Num				# Store starting address of array
    li $a1, 1				# Number to find
    li $a2, 6				# Store size of array in $a2
    jal find

END_MAIN: li $v0, 10			# Loads exit command
    syscall				# Exits main





#########################################
#               Find Func               #
#                                       #
#            Registers Used:            #
#          ------------------           #
#         $a0 = start of array          #
#         $a1 = number to find          #
#	  $a2 = number of elements      #
#	  $t4 = index counter           #
#         $v0 = match check             #
#########################################

# This function indexes through the array and looks for which of 
# the two numbers is smaller, then determines if the smaller number
# is less than half of the larger number; in other words, it compares
# the number at the index to the given number, determines which is larger,
# and then determines if it is twice the size of the smaller number

find:
    addi $sp, $sp, -4			# Pushes the stack pointer
    sw $ra, 0($sp)			# Pushes $ra onto the stack
    addi $t4, $0, 0			# Begins the counter
    addi $a0, $a0, -4			# Pushes the address to an index right before beginning of array

find_LOOP:
    addi $t4, $t4, 1 			# Increments the counter
    addi $a0, $a0, 4			# Increments the index (forces the array to Num[0] initially)
    add $t6, $a0, 0			# Stores original $a0
    add $t7, $0, $a1			# Stores original $a1
    jal match
    beq $v0, $0, NOT_MATCH		# Is not a match, $v0 = 0
    lw $a0, 0($a0)
    syscall				# Print the value
    add $a0, $0, $t6			# Restores original $a0
    add $a1, $0, $t7			# Restores original $a1
NOT_MATCH:
    beq $t4, $a2, end_find		# If the counter is 0, finish the function
    j find_LOOP				# Keep decrementing the counter 
end_find:
    lw $ra, 0($sp)			# Reset the stack pointer to main
    addi $sp, $sp, 4			# Push stack pointer back to top
    jr $ra				# Jump back to caller




#########################################
#              Match Func               #
#                                       #
#            Registers Used:            #
#          ------------------           #
#          $a0 = argument 1             #
#          $a1 = argument 2             #
#          $t0 = store address at [n]   #
#	   $t1 = store value at [n]     #
#	   $t2 = stores $t1 - t0        #
#	   $t3 = store 2(smaller #)     #
#          $v0 = store return           #
#########################################

# This function compares two numbers and determines if the two numbers
# are related by the following relation: the larger number is more than
# twice the size of the smaller number; in other words, the smaller number
# is greater than half the size of the larger number 

match:
    li $v0, 0				# Assume the numbers are equal and load 1 (true) into $v0
    lw $t0, 0($a0)			# Loads the address of Num[n] into $t0
    addi $t1, $a1, 0			# Loads $a1 into $t1
    bgt $t0, $t1, FIRST_GREATER		# $t0 > $t1
    bgt $t1, $t0, SECOND_GREATER	# $t1 > $t0
    j END
FIRST_GREATER:
    sll $t1, $t1, 1			# $t1 * 2
    bgt $t1, $t0, IS_OVER2X		# If 2(x) > n
    j END
SECOND_GREATER:
    sll $t0, $t0, 1			# $t0 * 2
    bgt $t0, $t1, IS_OVER2X		# If 2(x) > n
    j END
IS_OVER2X:
    li $v0, 1
END:
    jr $ra				# Jump back to caller