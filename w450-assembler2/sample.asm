; This file is a valid sample of assembly codes, identical to addArray.data

@00 ; // code

mov r2 0;       //	mvi	r2,#0	;sum=0
mov r3 0;       //	mvi	r3,#0	;zero
mov r0 0x80;    //	mvi	r0,#N;	 ptr=N
mov r1 [r0];    //	mv	r1,[r0]	;ctr

beq r1 r3 :done //	beq	r1,r3,done
:loop
	add r0 1;       //loop:	addi	r0,#1	;ptr++
	add r2 [r0];    //	add	r2,[r0]	;sum+=[ptr]
	sub r1 1;       //	subi	r1,#1	;ctr--
	blt r3 r1 :loop;//	blt	r3,r1,loop
:done
mov r0 0x80;    //done:	mvi	r0,#N	;ptr=N
mov [r0] r2;    //	mv	[r0],r2	;[ptr]=sum

;/* halt */
mov r0 255;     //	mvi	r0,#255	;halt flag
mov r1 1;       //	mvi	r1,#1	;true
mov [r0] r1;    //	mv	[r0],r1	;halt

@80 ;    // data
db 10;   //N:	10
db 1 2;  //	1,2
db 3 4;  //	3,4
db 5 6;  //	5,6
db 7 8;  //	7,8
db 9 10; //	9,10

@FF ; // halt flag
db 0; //halt:	false
