w450 Assembler

usage: w450 < input.file > output.file
if the file name are not supplied, it inputs fron stdin and outputs to stdout
 
Assembly codes recognized by the assembler:
 - The assembler do NOT recognize "addi","subi","movi" operations
 - Immediate operation can be done simply like: mov r2 0x80
 - Operand for 'move' is "mov" not "mv"
 - Numbers are taken like C/C++, i.e. 123,0xff,077. Binary numbers are NOT supported
 - Comments are followed by a SEMICOLN ';'
 - Labels are followed by ':' and the definations must be in a line by themselves
 - Pseudo Instruction:
     There is a pseudo instruction, db. It is used for define a byte.
 - Format:
       add/sub/mov destination source
           destination should be a register or [r0]
           source should be a register or [r0] or a number of immediate value
           e.g. add r2 0x1f; sub r2 r1; mov [r0] r3;
       beq/blt register1 register2 offset
           register1 and register2 must be registers
           offset should be a number or a label
           e.g. beq r1 r3 -5; blt r0 r2 :done;
       db numbers
           numbers can be one or more numbers
           e.g. db 0 1 02 0x80;

Copyright (c) 2011, Victor Ding
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of Victor Ding nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
