; Begin reserved section: do not change ANYTHING in reserved section!
; The ONLY exception to this is that you MAY change the .FILL values for
; Option, Value1 and Value2. This makes it easy to initialize the values in the
; program, so that you do not need to continually re-enter them. This
; makes debugging easier as you need only change your code and re-assemble.
; Your test value(s) will already be set.
;------------------------------------------------------------------------------
; Author: Fritz Sieker
;
; Description: Tests the implementation of a simple string library and I/O
;

            .ORIG x3000
            BR Main
Functions
            .FILL Test_pack         ; (option 0)
            .FILL Test_unpack       ; (option 1)
            .FILL Test_printCC      ; (option 2)
            .FILL Test_strlen       ; (option 3)
            .FILL Test_strcpy       ; (option 4)
            .FILL Test_strcat       ; (option 5)
            .FILL Test_strcmp       ; (option 6)

; Parameters and return values for all functions
Option      .FILL 0                 ; which function to call
String1     .FILL x4000             ; default location of 1st string
String2     .FILL x4100             ; default location of 2nd string
Result      .BLKW 1                 ; space to store result
Value1      .FILL 0                 ; used for testing pack/unpack
Value2      .FILL 0                 ; used for testing pack/unpack
lowerMask   .FILL 0x00FF            ; mask for lower 8 bits
upperMask   .FILL 0xFF00            ; mask for upper 8 bits

Main        LEA R0,Functions        ; get base of jump table
            LD  R1,Option           ; get option to use, no error checking
            ADD R0,R0,R1            ; add index of array
            LDR R0,R0,#0            ; get address to test
            JMP R0                  ; execute test

Test_pack   
            LD R0,Value1            ; load first character
            LD R1,Value2            ; load second character
            JSR pack                ; pack characters
            ST R0,Result            ; save packed result
End_pack    HALT                    ; done - examine Result

Test_unpack 
            LD R0,Value1            ; value to unpack
            JSR unpack              ; test unpack
            ST R0,Value1            ; save upper 8 bits
            ST R1,Value2            ; save lower 8 bits
End_unpack  HALT                    ; done - examine Value1 and Value2

Test_printCC    
            LD R0,Value1            ; get the test value
            .ZERO R1                ; reset condition codes
            JSR printCC             ; print condition code
End_printCC HALT                    ; done - examine output

Test_strlen 
            LD R0,String1           ; load string pointer
            GETS                    ; get string
            LD R0,String1           ; load string pointer
            JSR strlen              ; calculate length
            ST R0,Result            ; save result
End_strlen  HALT                    ; done - examine memory[Result]

Test_strcpy 
            LD R0,String1           ; load string pointer
            GETS                    ; get string
            LD R0,String2           ; R0 is dest
            LD R1,String1           ; R1 is src
            JSR strcpy              ; copy string
            PUTS                    ; print result of strcpy
            NEWLN                   ; add newline
End_strcpy  HALT                    ; done - examine output

Test_strcat 
            LD R0,String1           ; load first pointer
            GETS                    ; get first string
            LD R0,String2           ; load second pointer
            GETS                    ; get second string
            LD R0,String1           ; dest is first string
            LD R1,String2           ; src is second string
            JSR strcat              ; concatenate string
            PUTS                    ; print result of strcat
            NEWLN                   ; add newline
End_strcat  HALT                    ; done - examine output

Test_strcmp 
            LD R0,String1           ; load first pointer
            GETS                    ; get first string
            LD R0,String2           ; load second pointer
            GETS                    ; get second string
            LD R0,String1           ; dest is first string
            LD R1,String2           ; src is second string
            JSR strcmp              ; compare strings
            JSR printCC             ; print result of strcmp
End_strcmp  HALT                    ; done - examine output

;------------------------------------------------------------------------------
; End of reserved section
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; on entry R0 contains first value, R1 contains second value
; on exit  R0 = (R0 << 8) | (R1 & 0xFF)

pack        
	AND R2, R2, #0
	ADD R2, R2, #8			; loading R2 as a counter
lshift	ADD R0, R0, R0			; left shifting R0 until R2 = 0
	ADD R2, R2, #-1
	BRp lshift			; now (R0 << 8) in order to get
					; (0xFF00)
	AND R2, R2, #0
	LD R2, lowerMask
	AND R1, R2, R1			; anding R1 with the lowermask
					; in order to get (0x00FF)
	ADD R0, R1, R0			
      		RET

;------------------------------------------------------------------------------
; on entry R0 contains a value
; on exit  (see instructions)

unpack  
	LD  R2, lowerMask
	AND R1, R0, R2
	ST  R1, Value2
	AND R1, R1, #0
	
	LD  R2, upperMask
	AND R0, R0, R2
	AND R2, R2, #0

	AND R3, R3, #0                  ; Clearing R3
        ADD R3, R3, #1                  ; R3 = mask1
        AND R4, R4, #0                  ; Clearing R4
        ADD R4, R4, #1                  ; R4 = mask2
	ADD R2, R2, #8
leShift
        ADD R3, R3, R3                  ; Left shifting R0 each loop
        ADD R2, R2, #-1                 ; R2 will = 0 after looping
        BRp leShift                     ; Branching until R2 = 0                	
checkBit
	AND R1, R0, R3                  ; Comparing bits param1 & src
        BRz nextBit                     ; If zero branch to nextBit
        ADD R0, R0, R4                  ; Adding bit to result   
nextBit
        ADD R4, R4, R4                  ; L shifting dest mask
        ADD R3, R3, R3                  ; L shifting src mask
        BRnp checkBit                   ; Branch to checkBit if R0
                                        ; is either neg or pos
                                        ; If zero, it means we have
                                        ; left shifted through the 
                                        ; entire dest mask
	
	LD R1, Value2
	LD R2, lowerMask
	AND R0, R2, R0
		RET

;------------------------------------------------------------------------------
; on entry R0 contains value
; on exit  (see instructions)

StringNEG   .STRINGZ "NEGATIVE\n"   ; output strings
StringZERO  .STRINGZ "ZERO\n"
StringPOS   .STRINGZ "POSITIVE\n"

printCC     
	ADD R3, R0, #0			; making a copy of R0
	BRz zero
	BRp pos
neg
	LEA R0, StringNEG
	BRnzp resul
zero
	LEA R0, StringZERO
	BRnzp resul
pos
	LEA R0, StringPOS
resul
	ADD R4, R7, #0
	PUTS
	ADD R7, R4, #0
	ADD R0, R3, #0
            RET

;------------------------------------------------------------------------------
; size_t strlen(char *s)
; on entry R0 points to string
; on exit  (see instructions)

strlen  
	ADD R1, R0, #0			; copy R0(pointer) into R1
	AND R0, R0, #0
loop
	LDR R2, R1, #0			; copying the ascii value into R2
	BRz end
	ADD R1, R1, #1			; incrementing the pointer
	ADD R0, R0, #1			; incrementing the count(length)
	BR loop				; loop to the next ascii value in str
end	
            RET

;------------------------------------------------------------------------------
; char *strcpy(char *dest, char *src)
; on entry R0 points to destination string, R1 points to source string
; on exit  (see instructions)

strcpy  
	ADD R3, R0, #0			; copying initial pointer into R3
looop
	LDR R2, R1, #0
	STR R2, R0, #0
	BRz endd
	ADD R1, R1, #1
	ADD R0, R0, #1
	BR looop
endd
	ADD R0, R3, #0	
            RET

;------------------------------------------------------------------------------
; char *strcat(char *dest, char *src)

; on exit  (see instructions)

strcat_RA   .BLKW 1                 ; space for return address
strcat_dest .BLKW 1                 ; space for dest
strcat_src  .BLKW 1                 ; space for src

strcat      
	ST R7,strcat_RA         ; save return address
        ST R0,strcat_dest       ; save dest
        ST R1,strcat_src        ; save src

        			; fill in your code, ~5 lines of code
                                ; HINT: call strlen and strcpy
	JSR strlen
	ADD R2, R2, R0
	LD R0, strcat_dest
	LD R1, strcat_src
	ADD R0, R0, R2
	JSR strcpy
	
        LD R0,strcat_dest       ; restore dest
        LD R7,strcat_RA         ; restore return address
	    RET

;------------------------------------------------------------------------------
; int strcmp(char *s1, char *s2)
; on entry R0 points to first string, R1 points to second string
; on exit  (see instructions)

strcmp      
loooop
	LDR R2, R0, #0		
	BRz nullt		; if null terminator branch
	LDR R3, R1, #0
	BRz nullt		; if null terminator branch
sub
	NOT R3, R3
	ADD R3, R3, #1
	ADD R4, R2, R3
	BRnp enddd
	ADD R0, R0, #1
	ADD R1, R1, #1
	BR loooop
nullt
	LDR R3, R1, #0
	NOT R3, R3
        ADD R3, R3, #1
        ADD R4, R2, R3
enddd
	ADD R0, R4, #0	



            RET

;------------------------------------------------------------------------------
            .END
