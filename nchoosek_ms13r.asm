# Miroslav Sanader
# Assignment 7 — n choose k: this program explores the n choose k function,
#		 which is defined as n!/(k!)(n-k)!. The problem will be broken
#		 down into three parts: n!, k!, n-k!. In addition, error checking
#		 is implemented for the following: 
#		 - If n is negative
#		 - If k is negative
#		 - If n is greater than 30
#		 - If k is greater than n


#########################################
#               Main Func               #
#                                       #
#            Registers Used:            #
#          ------------------           #
#         $a0 = the value n             #
#         $a1 = the value k             #
#	  $s1 = max bounds check        #
#	  $s2 = minimum value check     #
#	  $v0 = syscall param           #
#########################################


    .data
n_Negative: .asciiz "n is negative.\nError."

k_Negative: .asciiz "k is negative.\nError. "

k_greater: .asciiz "k is greater than n.\nError. "

n_tooLarge: .asciiz "n is greater than 30.\nError. "

    .text
    .globl main
main:
    li $a0, 6			# $a0 is now n
    li $a1, 3			# $a1 is now k
    li $s1, 30			# Checking for outside of bounds in n choose k
    li $s2, 1			# Loads 1 in for minimum value of the factorial
    jal n_choose_k

end: li $v0, 10
    syscall



#########################################
#            n choose k Func            #
#                                       #
#            Registers Used:            #
#          ------------------           #
#         $a0 = the value n             #
#         $a1 = the value k             #
#	  $s1 = max bounds check        #
#	  $s2 = minimum value check     #
#	  $t0 = stores n (int)          #
#	  $t1 = stores k (int)          # 
#	  $f0 = stores n (double)       #  
#	  $f2 = stores k (double)       #  
#	  $f4 = stores n - k (double)   #  
#	  $f20 = stores 1 (double)      # 
#	  $f12 = storing n choose k     #   
#	  $v0 = syscall param           #
#########################################

# The following function is the implementation of the n choose k 
# formula. It contains three loops, each of which computes the factorial
# for one of the following: 
#	- n!
#	- k!
#	- (n - k)!
#
# It then calculates the total and stores it into the $f12 register to print 

n_choose_k:
    bgt $a0, $s1, N_TOOLARGE			# If n > 30
    blt $a0, $0, N_NEGATIVE			# If n < 0
    blt $a1, $0, K_NEGATIVE			# If k < 0
    bgt $a1, $a0, K_GREATER			# If k > n
    addi $t0, $a0, 0				# Stores n
    addi $t1, $a1, 0				# Stores k
    sub $t3, $t0, $t1				# Stores n-k
    mtc1 $s2, $f20				# Moves the minimal 1 to $f20
    cvt.d.w $f20, $f20				# Converts 1 to a double (1.0000000…0)
CONVERT_REGISTERS:
    mtc1 $t0, $f0				# Moves $t0 to floating point register
    cvt.d.w $f0, $f0				# Converts $f0 to a float
    mtc1 $t1, $f2				# Moves $t0 to floating point register
    cvt.d.w $f2, $f2				# Converts $f0 to a float
    mtc1 $t3, $f4				# Moves n-k to floating point register
    cvt.d.w $f4, $f4				# Converts n-k to a floating point

get_N:
    mov.d $f10, $f0				# Copies n to another register
loop_NUM:
    sub.d $f10, $f10, $f20			# Decrements n by 1
    mul.d $f0, $f0, $f10			# Multiplies n by n-1
    addi $t0, $t0, -1				# Decrement integer counter
    bgt $t0, $s2, loop_NUM

get_K:
     mov.d $f16, $f2				# Copies n to another register
loop_K:
    sub.d $f16, $f16, $f20			# Decrements n by 1
    mul.d $f2, $f2, $f16			# Multiplies n by n-1
    addi $t1, $t1, -1
    bgt $t1, $s2, loop_K

get_NMINUSK:
     mov.d $f14, $f4				# Copies n to another register
loop_NMINUSK:
    sub.d $f14, $f14, $f20			# Decrements n by 1
    mul.d $f4, $f4, $f14			# Multiplies n by n-1
    addi $t3, $t3, -1				# Decrements the copy of n-k
    bgt $t3, $s2, loop_NMINUSK
GET_FINAL:
    mul.d $f12, $f2, $f4			# $f12 = (k!)(n-k)!
    div.d $f12, $f0, $f12			# $f12 = n/(k!)(n-k)!
    li $v0, 3
    syscall					# Print value in $f12 (equivalent of $a0)
    j exit_func
N_TOOLARGE:					# Prints out if n is too large
    li $v0, 4
    la $a0, n_tooLarge
    syscall
    j exit_func
N_NEGATIVE:					# Prints out if n is negative
    li $v0, 4
    la $a0, n_Negative
    syscall
    j exit_func
K_NEGATIVE:					# Prints out if k is negative
    li $v0, 4
    la $a0, k_Negative
    syscall
    j exit_func
K_GREATER:					# Prints out if k is greater than n
    li $v0, 4
    la $a0, k_greater
    syscall
exit_func:
    jr $ra
