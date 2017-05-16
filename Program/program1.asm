;James Logan Piercefield
;CSC 4320 - Computer Architecture - Program 1
;Date: 3/25/2017
;Last Updated: 3/26/2017
.MODEL small ; smallest segmented memory model (one DS, CS, ES)
.stack 1024  ; use a stack size of 1024 bytes 

CR 	EQU	0Dh		; \r
LF      EQU	0Ah		; \n
TERM 	EQU     24h             ; $ string terminator

.DATA
message		BYTE "Enter a number between 0 and 100 (Celsius): ", TERM, 0
buff        db 4          ; 3 Chars + Enter
inputLength db 0          ; number of read characters
buffer      db 4 DUP('$') ; actual buffer

.CODE
ascii_to_byte PROC FAR 
	mov SI, 0
_BEGIN:
	mov AL, BYTE PTR [buffer + SI]
	cmp AL, TERM
	je _DONE
	sub AL, 30h
	mov BYTE PTR [buffer + SI], AL
	inc SI
	jmp _BEGIN
_DONE:
	iret
ascii_to_byte ENDP

byte_to_ascii PROC FAR
	mov SI, 0
	mov CL, 10
	mov AL, BYTE PTR [buffer + SI]
_b2a:
	sub AH, AH
	div CL
	add AH, 30h
	mov BYTE PTR [buffer + SI], AH
	inc SI
	cmp AL, 0
	jne _b2a
_fin:
	mov BYTE PTR [buffer + SI], TERM
	iret
byte_to_ascii ENDP

start:
	cli                         ; disable interrupts
	mov 		AX, @DATA       ; get location of data segment
	mov 		DS, AX          ; put it in data segment register
	xor 		AX, AX          ; zero ax
	mov 		ES, AX          ; zero es
	sti                         ; enable interrupts

	mov DX, OFFSET message ;display
	mov AH, 9h             ;INT 21 - AH = 09h DOS - PRINT STRING
	int 21h		           ;display 

	mov AH, 0Ah           ;INT 21 - AH = 0Ah DOS - BUFFERED KEYBOARD INPUT
	mov DX, offset buff   ;DS:DX = address of buffer
	int 21h

	mov SI, offset inputLength ;Num Chars entered
	mov CL, [SI]               ;Move length to CL
	mov CH, 0                  ;Clear CH to use CX
	inc CX                     ;To reach last char
	add SI, CX                 ;SI to last char
	mov AL, '$'                ;AL to '$'
	mov [SI], AL               ;Replace last char with '$'

	mov AH, 06h            ;New Line
	mov DL, LF             ;New Line
	int 21h                ;New Line

	mov AH, 9h             ;INT 21 - AH = 09h DOS - PRINT STRING
	mov DX, offset buffer  ;Must End with '$' 
	int 21h

	call ascii_to_byte     ;Converts Ascii chars in buffer to integers
	
	mov AH, 06h            ;New Line
	mov DL, LF             ;New Line
	int 21h                ;New Line

	SUB AH, AH
	mov DL, 0;-added ln
	SUB BX, BX ; - add ln
	mov SI, 3
_compute:
	cmp SI, 0
	je _p2Comp
	dec SI
	mov AL, BYTE PTR [buffer + SI]
	cmp AL, TERM
	je _compute
	cmp DL, 0
	je _x0
	cmp DL, 1
	je _x10
	cmp DL, 2
	je _x100	
_x0:
	add BX, AX
	inc DL
	jmp _compute
_x10:
	mov CL, 10
	mul CL
	add BX, AX
	inc DL
	jmp _compute
_x100:	;Will not be greater than 100 - Program Specifications
	mov BX, 100
_p2Comp:
	mov AX, BX
	mov CL, 9
	mul CL
	mov CL, 5
	div CL
	add AL, 32
	mov BYTE PTR [buffer + SI], AL

	call byte_to_ascii
	mov SI, 3
_out: ;In reverse order due to remainders in b_to_a
	dec SI
	mov DL, BYTE PTR [buffer + SI]
	cmp DL, TERM
	je _out
	mov AH, 06h
	int 21h
	cmp SI, 0
	jne _out
quit:
	mov   AX, 4C00h ; exit with error code 0
	int   21h
end start 