.globl sine

.section .data
var:
.align	8
.space 104

var2:
.align 8
.space 104

var3:
.align 8
.space 104

var4:
.align 8
.space 104

mult:
.align 8
.space 204


.section .text

# Sine
#   Params
#	a1 -- input buffer will contain string with the argument
#	a2 -- output string buffer for the string result
sine:

# READ INPUT in VAR

# load first 8 symbole from input to a3
# used regs: a1, a2, a3, s3
	ld	a3, 0(a1)

# s3 -- var
# used regs: a1, a2, a3, s3
	la	s3, var
	
# add first digit to s3
# used regs: a1, a2, a3, s3
	andi	a4, a3, 0x0f
	sb	a4, 0(s3)	

# right move on 2 bytes (16 bites)
# used regs: a1, a2, a3, s3
	srl	a3, a3, 16
	
	li	s11, 10

# loop1 
# for (s4 = 1; s4 != 7 (= s6); s4++)
# 	var[s4] = a3 & 0xf
#	a3 << 2 bytes
	li	s4, 1
	li	s6, 7
loop1:	
	beq	s4, s6, end_loop1
	
	andi	s5, a3, 0xf
	bge	s5, s11, end_read

	add	s7, s3, s4
	sb	s5, 0(s7)
	srl	a3, a3, 8
	addi	s4, s4, 1
	j 	loop1

end_loop1:
	ld	a6, 0(s3)

# loop2
# for (s8 = 7; s8 != 95 (= s9); s8+=8) 
#	for (s4 = s8; s4 != s8+8 (= s6); s4++)
#		copy_loop1
	li	s8, 7
	li	s9, 95
	addi	a7, a1, 8
loop2:
	beq	s8, s9, end_loop2
	mv	s4, s8
	addi	s6, s4, 8
	ld	a3, 0(a7)
copy_loop1:
	beq	s5, a3, end_copy_loop1
	
	andi	s5, a3, 0xf
	bge	s5, s11, end_read
	add	s7, s3, s4
	sb	s5, 0(s7)
	srl	a3, a3, 8
	addi	s4, s4, 1
	j	copy_loop1
	
end_copy_loop1:
	addi	s8, s8, 8
	addi	a7, a7, 8
	j	loop2
end_loop2:

	li	s8, 95
	li	s9, 100
copy2_loop1:
	beq	s5, a3, end_copy2_loop1
	
	andi	s5, a3, 0xf
	bge	s5, s11, end_read
	add	s7, s3, s4
	sb	s5, 0(s7)
	srl	a3, a3, 8
	addi	s4, s4, 1
	j	copy2_loop1
end_copy2_loop1:
end_read:
	




# CALCULATIONS
	mv	t0, ra

	la	a3, var
	la	a4, var2
	call	copy

	la	a5, var
	call	mult_double

	li	a6, 5
	call	fact

	la	a3, var
	mv	a4, a7
	
	mv	ra, t0



# WRITE FROM VAR TO OUTPUT
	la	a5, var
	lb	s4, 0(a5)
	ori	s4, s4, 0x30
	sb	s4, 0(a2)
	li	s4, '.'
	sb	s4, 1(a2)

	mv	a4, a2
	addi	a4, a4, 2
	addi	a5, a5, 1
	li	a6, 2
	li	a7, 100


# for ()
loop3:
	beq	a6, a7, end_loop3

	lb	s4, 0(a5)
	ori	s4, s4, 0x30
	sb	s4, 0(a4)
	
	addi	a4, a4, 1
	addi	a5, a5, 1
	addi	a6, a6, 1
	j	loop3
end_loop3:
	

end:
	ret

	


# a3 - var1
# a4 - var2
# a5 - sum
sum:
# i = 100 // s5
# do 
# 	i++
#	s1 = a3[i]
#	s2 = a4[i]
#	s3 = s1 + s2
#	s3 = s3 + s4
#	s4 = 0
#	if (s3 > 9)
#		s4 = 1
#		s3 = s3 - 10
#	a5[i] = s3
#	
# while i != 0
	li	s5, 100
	li	s4, 0
	li	s9, 10
	li	s10, 0
loop_sum:
	addi	s5, s5, -1
	
	add	s6, a3, s5
	lb	s1, 0(s6)
	
	add	s6, a4, s5
	lb	s2, 0(s6)

	add	s3, s1, s2
	add	s3, s3, s4	
	li 	s4, 0
	
	blt	s3, s9, skip_step_sum
	
		li	s4, 1	
		addi	s3, s3, -10

skip_step_sum:
	add	s6, a5, s5
	sb	s3, 0(s6)

	bne	s5, s10, loop_sum

	ret


# a3 - var1
# a4 - var2
# a5 - res
mult_double:
# la 	a6, mult
# i = 100 // s1
# do
# 	i--
#	s2 = a4[i]
#	j = 100 // s8
#	do
#		j--
#		s3 = a3[j]
#		s4 = s3 * s2
#		s4 = s4 + s5
#		s5 = 0
#		if s4 > 9
#			s5 = s4 / 10
#			s9 = s4 % 10
#
#			s4 = s9
#		s6[j+i] = s4
#	
#	while j != 0
# while i != 0
#

	li	s11, 0
	la	a6, mult
	li	s1, 100
	li	s5, 0
	li	s10, 10
loop_mult1:
	addi	s1, s1, -1
	add	s7, a4, s1
	lb	s2, 0(s7)
	li	s8, 100

	li	a7, 0
	loop_mult2:
		addi	s8, s8, -1
		add	s7, a3, s8 
		lb	s3, 0(s7)
		
		li	s4, 0
		mv	s9, s2
		small_loop:
			beq	s9, s11, end_small_loop
			addi	s9, s9, -1
			add	s4, s4, s3
			j	small_loop	
		end_small_loop:
		
		add	s4, s4, s5
		li	s5, 0
		small_mult_loop2:
			blt	s4, s10, skip_step_mult
			sub	s4, s4, s10
			addi	s5, s5, 1
			j	small_mult_loop2
		skip_step_mult:
		
		add	s7, a6, s8
		add	s7, s7, s1
		lb	s9, 0(s7)
		add	s9, s9, a7
		add	s9, s9, s4
		li	a7, 0
		lll:
			blt	s9, s10, end_small_mult_loop4
			sub	s9, s9, s10
			addi	a7, a7, 1
			j	lll
		end_small_mult_loop4:

		sb	s9, 0(s7)
	
	bne	s8, s11, loop_mult2
	beqz	a7, skip1
		add	s7, a6, s8
		addi	s7, s7, -1
		add	s7, s7, s1
		sb	a7, 0(s7)
	skip1:

bne	s1, s11, loop_mult1	

li	s1, 0
li	s2, 100
final_loop_mult:
	add	s3, a6, s1
	lb	s4, 0(s3)
	add	s3, a5, s1
	sb	s4, 0(s3)
	addi	s1, s1, 1	
	bne s1, s2, final_loop_mult

ret


# a3 - to clear
clear:
li	s1, 0
li	s2, 0
li	s3, 100
clear_loop:
add	s4, a3, s1
sb	s2, 0(s4)
addi	s1, s1, 1
bne	s1, s3, clear_loop
ret

# a3 - from
# a4 - to
copy:
li	s1, 0
li	s2, 100
copy_loop:
add	s4, a3, s1
lb	s3, 0(s4)
add	s4, a4, s1
sb	s3, 0(s4)
addi	s1, s1, 1
bne	s1, s2, copy_loop
ret

# a6 - number
# a7 - result (factorial)
fact:
li	a7, 1
mv	s1, a6
fact_loop:
beqz	s1, end_fact
#mult	a7, a7, s1
mv	s2, s1
li	s3, 0
fact_mult:
beqz	s2, end_fact_mult
add	s3, s3, a7
addi	s2, s2, -1
j	fact_mult
end_fact_mult:
mv	a7, s3
addi	s1, s1, -1
j	fact_loop

end_fact:
ret

# a3 - address of double number for divide
# a4 - number
div:




