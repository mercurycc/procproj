	;/* r0: current element address */
	;/* r3: current insertion point */
	;/* r1: current max */
	;/* r2: current element / temp */
	
	mov  r0 0x80
	mov  r3 [r0]
	
:start
	mov  r0 0x80
	add  r0 r3
	mov  r2 0x80
				; Test if r0 reaches the head
	beq  r0 r2 :done_sort
	mov  r1 [r0]
	add  r0 1
:loop
	sub  r0 1
	mov  r2 0x80
				; Test if r0 reaches the head
	beq  r0 r2 :found_max
	mov  r2 [r0]
	blt  r1 r2 :update_max
	beq  r0 r0 :loop
:update_max
	mov  r1 r2
	mov  r2 r0
				; Save max address
	mov  r0 0x60
	mov  [r0] r2
	mov  r0 r2
	beq  r0 r0 :loop
:found_max
				; Swap max and insert point and update pointers
	add  r0 r3
	mov  r2 [r0]
				; Load current insert to r2
	mov  [r0] r1
				; Store current max to current insert
	mov  r0 0x60
	mov  [r0] r2
				; Store current element to current max address
	sub  r3 1
				; Update current insert
	beq  r0 r0 :start
	
:done_sort
	mov	r0 255
	mov	r1 1
	mov	[r0] r1
	
:current_max_addr
	db 0
	
:data
	db 64
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

