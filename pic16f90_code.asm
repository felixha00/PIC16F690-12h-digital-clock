;
;   FELIX HA 5242018 MR.WILL       
;                                          
;
 
    __config 3ffch & 3ff7h
 
; DECLARE REGISTERS
 
PCL EQU 02H
PORTA EQU 05H
PORTB EQU 06H
PORTC EQU 07H
TRISA EQU 85H
TRISB EQU 86H
TRISC EQU 87H
STATUS EQU 03H
ANSEL  EQU 11EH
ANSELH EQU 11FH
delay1 EQU 20H ; sets delay variable to the free bit in bank 0
delay2 EQU 21H
OMIN EQU 22H ; ones-minute
OMIN1 EQU 26H
TMIN EQU 23H ; tens-minute
TMIN1 EQU 27H
OHR EQU 24H ; ones-hour
OHR1 EQU 28H
THR EQU 25H
THR1 EQU 29H ; tens-hour
delay3 EQU 30H
delay4 EQU 31H
COUNTER equ 32h
DUMMY EQU 33H
OHR2 EQU 34H
OHR2A EQU 36H
ZEROFLAG EQU 35H   
   
    CLRF    OHR2
    CLRF    OHR2A
    CLRF    OMIN
    CLRF    THR
    CLRF    OHR
    CLRF    TMIN
    CALL    SETOHRto1
   
 
 
    BCF     STATUS, 06H ; BANK 1
    BSF     STATUS, 05H    
    CLRF    TRISC                   ; makes PORTC all output which allows PORTC to light up segmments
    CLRF    TRISA                   ; makes PORTA output to light up each 7-segment display  
    MOVLW   B'11111111'
    CLRF    TRISB                   ;makes TRISB input, to turn off the program
    BCF     STATUS, 05H ; BANK2
    BSF     STATUS, 06H        
    CLRF    ANSEL  
    CLRF    ANSELH
    CLRF    STATUS  ; clear status 
    CLRF    COUNTER ; COUNTER FOR LOOP
    CLRF    DUMMY
 
 
           
; Start main loop ...........................................
 
 
 
 
 
SETOMIN
 
        MOVLW   D'10'
        MOVWF   COUNTER
                                            ; clears ones-minutes
        CALL DISPLAY
        MOVFW OMIN
        CALL LOOKUP             ; calls lookup
        MOVWF PORTC             ; moves lookup value into portc to light up the segments
        MOVLW B'11101111'       ; B'11101111'lights up the first (reversed) 7-seg-display (ones-minutes)  
        MOVWF PORTA
        CALL setdelay
        INCF OMIN
        MOVFW OMIN
        MOVWF OMIN1             ; increases the value of ones-minute
        MOVLW b'00001010'       ; moves a literal of 10 into the working file register
        XORWF OMIN1             ; XORs CHECK 10 with OMIN, which increases every repeated step.
        BTFSS STATUS, 2         ; checks if the zero flag is 1, if true, skip next line
        GOTO SETOMIN            ; if OMIN is not 10, then go back to increasing OMIN
        GOTO OMINis10           ; if OMIN is 10, goto OMINis10
 
SETTMIN
            INCF TMIN
            MOVFW TMIN
            MOVWF TMIN1             ; increases the value of ones-minute
            MOVLW b'00000110'       ; moves a literal of 6 into the working file register                                   ; moves the value of 10 into register CHECK 10
            XORWF TMIN1             ; XORs CHECK 10 with OMIN, which increases every repeated step.
            BTFSS STATUS, 2         ; calls a label to clear TMINs when it reaches 10                  
            GOTO SETOMIN           
            GOTO TMINis6   
           
SETOHOUR                       
            INCF OHR                ; increases the value of ones-minute
            INCF OHR2               ; OHR2 COUNTS UNTIL 12
            CALL DISPLAY
            MOVFW OHR
            MOVWF OHR1              ; OHR1 is a substitute variable for XORing                                                         
            MOVLW b'00001010'       ; moves a literal of 10 into working file register     
            XORWF OHR1              ; XORs CHECK 10 with OMIN, which increases every repeated step.      
            BTFSS STATUS, 2         ; checks if the zero flag is 1, if true, skip next line
            GOTO SETOMIN            ;
            GOTO OHRis10            ;
       
 
 
SETTHOUR    ; sets tens-hours  
            INCF THR    ; increases tens-hour by 1
            RETURN     
       
;          
           
CHECKif13 ; CHECKS IF IT SAYS 13 HOURS
    MOVFW OHR2          ;
    MOVWF OHR2A
    MOVLW B'00001100'   ; moves literal of 12 into working register
    XORWF OHR2A         ; XOR the substitute variable of OHR2 (OHR2A)
    BTFSS STATUS, 2     ; checks if it is 0, which means that OHR2A is 12
    RETURN              ; returns back to the DISPLAY method, does not clear anything  
    GOTO CLEAR          ; goes to clear all the registers to repeat again
       
setdelay ; delay for the counter
    return
        MOVLW B'00001000' ;   255
        MOVWF delay1 ; MOVES 10 INTO DELAY1
        MOVWF delay2 ; MOVES 10 INTO DELAY 2
    delay
        decfsz delay1           ; decreases delay1 until it is 0
        goto delay              ; goes back to the delay method
        decfsz delay2
        goto delay
        return
 
setdelay1 ; DISPLAY LOOP DELAY
        MOVLW D'7' ;   255
        MOVWF delay3 ; MOVES 10 INTO DELAY1
        MOVWF delay4 ; MOVES 10 INTO DELAY 2
    wdelay
        decfsz delay3           ; decreases delay1 until it is 0
        goto wdelay             ; goes back to the delay label
        decfsz delay4
        goto wdelay
        return
 
TMINis6 ; tens-minute is six
        CLRF TMIN
        GOTO SETOHOUR
 
SETOHRto1 ;resets ones-hour
        MOVLW B'00000001'
        MOVWF OHR
        RETURN
 
OHRis10 ; ones-hour is 10
    CALL SETTHOUR
    CLRF OHR
    GOTO SETOMIN
 
OMINis10 ; ones minute is 10
    CLRF OMIN
    GOTO SETTMIN
 
 
 
DISPLAY
    BTFSS PORTB, H'07'
    CALL TURNOFF
    CALL CHECKif13          ; constantly checks if the value of THR and OMIN are 1 and 3
 
    ; ones-minutes loop display
    MOVFW OMIN
    CALL LOOKUP
    MOVWF PORTC
    MOVLW B'11101111'
    MOVWF PORTA
    CALL setdelay1
    ; tens-minutes loop display
    MOVFW TMIN
    CALL LOOKUP
    MOVWF PORTC
    MOVLW B'11111011'
    MOVWF PORTA
    CALL setdelay1
    ; ones-hour loop display
    MOVFW OHR
    CALL LOOKUP
    MOVWF PORTC    
    MOVLW B'11111101'
    MOVWF PORTA
    CALL setdelay1
    ; tens-hour loop display
    MOVFW THR
    CALL LOOKUP
    MOVWF PORTC
    MOVLW B'11111110'
    MOVWF PORTA
    CALL setdelay1
    decf    COUNTER
    BTFSC   COUNTER, H'07'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'06'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'05'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'04'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'03'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'02'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'01'
    BTFSS   DUMMY,  H'00'
    BTFSC   COUNTER, H'00'
    GOTO    DISPLAY
    RETURN
 
LOOKUP ADDWF PCL ; lookup table
    RETLW   B'01000000';Sets 0
    RETLW   B'01111001';Sets 1
    RETLW   B'00100100';Sets 2
    RETLW   B'00110000';Sets 3
    RETLW   B'00011001';Sets 4
    RETLW   B'00010010';Sets 5
    RETLW   B'00000010';Sets 6
    RETLW   B'01111000';Sets 7
    RETLW   B'00000000';Sets 8
    RETLW   B'00010000';Sets 9
    RETLW   B'01000000';Sets 0
    RETLW   B'01111001';Sets 1
    RETLW   B'00100100';Sets 2
       
   
CLEAR   ; CLEARS ALL THE VALUES FOR THE CLOCK
    CLRF    OHR2
    CLRF    OMIN
    CLRF    THR
    CLRF    OHR
    CLRF    TMIN
    CALL    SETOHRto1
    GOTO    SETOMIN
 
TURNOFF ; TURNS OFF THE DISPLAYS, RESETS THE VALUES
    MOVLW B'11111111'   ; moves 255 into WREG
    MOVWF PORTA         ; set PORTA all off (active low)
    MOVWF PORTC         ; set PORTC all off (active low)
    BTFSS PORTB, H'07'  ; checks if PORTB has been changed from low to high
    GOTO TURNOFF        ; if has not been turned on, keep resetting all the values
    GOTO CLEAR          ; it has been turned on, goto clear, and clear all the values in the clock
END