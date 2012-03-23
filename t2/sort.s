	/* r0: current element address */
	/* r3: current insertion point */
	/* r1: current max */
	/* r2: current element / temp */
	
	mvi  r0, #data
	mv   r3, [r0]
	
start:	mvi  r0, #data
	add  r0, r3
	mvi  r2, #data		; Test if r0 reaches the head
	beq  r0, r2, done_sort
	mv   r1, [r0]
	addi r0, #1
loop:	subi r0, #1
	mvi  r2, #data          ; Test if r0 reaches the head
	beq  r0, r2, found_max
	mv   r2, [r0]
	blt  r1, r2, update_max
	beq  r0, r0, loop
update_max:
	mv   r1, r2
	mv   r2, r0		; Save max address
	mvi  r0, #current_max_addr
	mv   [r0], r2
	mv   r0, r2
	beq  r0, r0, loop
found_max:			; Swap max and insert point, and update pointers
	add  r0, r3
	mv   r2, [r0]		; Load current insert to r2
	mv   [r0], r1		; Store current max to current insert
	mvi  r0, #current_max_addr
	mv   [r0], r2		; Store current element to current max address
	subi r3, #1		; Update current insert
	beq  r0, r0, start
done_sort:
	
	
	@60
current_max_addr:
	db 0
	
	@80
data:	db 64
	db 34
	db 217
	db 182
	db 192
	db 112
	db 207
	db 76
	db 162
	db 0
	db 231
	db 227
	db 245
	db 185
	db 89
	db 6
	db 137
	db 188
	db 18
	db 210
	db 212
	db 224
	db 74
	db 135
	db 179
	db 124
	db 152
	db 44
	db 239
	db 29
	db 85
	db 226
	db 85
	db 197
	db 61
	db 40
	db 99
	db 158
	db 31
	db 79
	db 14
	db 214
	db 40
	db 47
	db 245
	db 187
	db 157
	db 76
	db 118
	db 249
	db 51
	db 92
	db 53
	db 247
	db 45
	db 230
	db 112
	db 19
	db 160
	db 116
	db 32
	db 18
	db 42
	db 234
	db 195

	@FF  // Halt