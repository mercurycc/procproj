:print_init
	mov r0 0x80
	mov r3 [r0]
	add r3 r0
	add r3 1
:print_loop
	add r0 1
	beq r0 r3 :print_end
	mov r1 [r0]
	mov r2 r0
	mov r0 254
	mov [r0] r1
	mov r0 r2
	beq r0 r0 :print_loop
:print_end
	db 0