; GC+ by Aurelio Mannara


; MIT License
; 
; Copyright (c) 2016 Aurelio Mannara
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

#include "p18F25K22.inc"

; CONFIG1H
  CONFIG  FOSC = INTIO67        ; Oscillator Selection bits (Internal oscillator block)
  CONFIG  PLLCFG = ON           ; 4X PLL Enable (Oscillator multiplied by 4)
  CONFIG  PRICLKEN = OFF        ; Primary clock enable bit (Primary clock can be disabled by software)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRTEN = OFF          ; Power-up Timer Enable bit (Power up timer disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 190            ; Brown Out Reset Voltage bits (VBOR set to 1.90 V nominal)

; CONFIG2H
  CONFIG  WDTEN = SWON          ; Watchdog Timer Enable bits (WDT is controlled by SWDTEN bit of the WDTCON register)
  CONFIG  WDTPS = 1024          ; Watchdog Timer Postscale Select bits (1:1024)

; CONFIG3H
  CONFIG  CCP2MX = PORTB3       ; CCP2 MUX bit (CCP2 input/output is multiplexed with RB3)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<5:0> pins are configured as analog input channels on Reset)
  CONFIG  CCP3MX = PORTB5       ; P3A/CCP3 Mux bit (P3A/CCP3 input/output is multiplexed with RB5)
  CONFIG  HFOFST = ON           ; HFINTOSC Fast Start-up (HFINTOSC output and ready status are not delayed by the oscillator stable status)
  CONFIG  T3CMX = PORTC0        ; Timer3 Clock input mux bit (T3CKI is on RC0)
  CONFIG  P2BMX = PORTB5        ; ECCP2 B output mux bit (P2B is on RB5)
  CONFIG  MCLRE = EXTMCLR       ; MCLR Pin Enable bit (MCLR pin enabled, RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled if MCLRE is also 1)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = ON             ; Code Protection Block 0 (Block 0 (000800-001FFFh) code-protected)
  CONFIG  CP1 = ON             ; Code Protection Block 1 (Block 1 (002000-003FFFh) code-protected)
  CONFIG  CP2 = ON             ; Code Protection Block 2 (Block 2 (004000-005FFFh) code-protected)
  CONFIG  CP3 = ON             ; Code Protection Block 3 (Block 3 (006000-007FFFh) code-protected)

; CONFIG5H
  CONFIG  CPB = ON             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) code-protected)
  CONFIG  CPD = OFF            ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = ON             ; Write Protection Block 0 (Block 0 (000800-001FFFh) write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection Block 1 (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection Block 2 (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection Block 3 (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = ON             ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) write-protected)
  CONFIG  WRTB = ON             ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = ON            ; Table Read Protection Block 0 (Block 0 (000800-001FFFh) protected from table reads executed in other blocks)
  CONFIG  EBTR1 = ON            ; Table Read Protection Block 1 (Block 1 (002000-003FFFh) protected from table reads executed in other blocks)
  CONFIG  EBTR2 = ON            ; Table Read Protection Block 2 (Block 2 (004000-005FFFh) protected from table reads executed in other blocks)
  CONFIG  EBTR3 = ON            ; Table Read Protection Block 3 (Block 3 (006000-007FFFh) protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = ON            ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) protected from table reads executed in other blocks)

;Some global variables
bitCounter equ 0x00
tempCmdByte equ 0x01
cmdReceived equ 0x02
cmdLength equ 0x03
charToSendUart1 equ 0x04
dataLength equ 0x05
bitCounterTX equ 0x06
curByte equ 0x07
waitLoopCounter equ 0x08
curADInput equ 0x09
f_divhi equ 0x0A
f_divlo equ 0x0B
lutCounter equ 0x0C
invertAxes equ 0x0D
deadZoneSize equ 0x0E
rumbleDutyCycle equ 0x0F
 
;0x10-0x1F received commands
;0x20-0x22 0x00 answer
;0x23-0x24 buttons current state
buttonsCurState0 equ 0x23
buttonsCurState1 equ 0x24
;0x25-0x26 buttons prev state
buttonsPrevState0 equ 0x25
buttonsPrevState1 equ 0x26
;0x27-0x2C buttons timers
buttonsTimerA equ 0x27
buttonsTimerB equ 0x28
buttonsTimerX equ 0x29
buttonsTimerY equ 0x2A
buttonsTimerZ equ 0x2B
buttonsTimerS equ 0x2C
;0x2D-0x2E mixed buttons state
buttonsMixState0 equ 0x2D
buttonsMixState1 equ 0x2E
;0x30-0x37 0x40 answer
;0x38-0x3D buttons timers
buttonsTimerRT equ 0x38
buttonsTimerLT equ 0x39
buttonsTimerDU equ 0x3A
buttonsTimerDD equ 0x3B
buttonsTimerDR equ 0x3C
buttonsTimerDL equ 0x3D
;0x3E flagsSettings
flagsSettings equ 0x3E
;0x3F analog mode
analogMode equ 0x3F
;0x40-0x4F 0x41-0x42 answer
;0x50-0x55 AD inputs
;0x56-0x5B AD origins

;0x100-0x1FF SX LUT
;0x200-0x2FF SY LUT
;0x300-0x3FF CX LUT
;0x400-0x4FF CY LUT

;Global constant values
firmMajVer equ 1
firmMinVer equ 1
boardMajVer equ 1
boardMinVer equ 0
 
    ;EEPROM default values
    org 0xF00000
    de 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x18, 0x00


    org 0x00
    goto start
    
    org 0x08 ;High-priority interrupts
    goto isrHighHandler
    
    org 0x18 ;Low-priority interrupts
    goto isrLowHandler

    org 0x20
isrHighHandler
    btfss INTCON3, 1 ;If INT2 flag isn't set just return
    retfie 1 ;Return from interrupt and restore W, STATUS and BSR registers
    ;If we got here, then INT2 flag is set
    
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    bcf INTCON, 2 ;Clear TMR0 flag
    
    ;Check cmdLength
    movf cmdLength, 0, 0 ;WREG = cmdLength
    addlw 0xF1 ;241 = 255 - 14
    addlw 0x0F ;(14 - 0) + 1
    bnc endIsrHighHandler

    ;movlw 0x0E
    ;subfwb cmdLength, 1, 0 ;W = 14 - cmdLength
    ;btfss STATUS, 0 ;Test if cmdLength > 14
    ;bra endIsrHighHandler
    
    ;Wait few cycles => Wait for ~1.25us since the falling edge
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    ;Check if bitCounter is 8
    movf bitCounter, 0, 0 ;Move bitCounter to W. Use Access Bank
    sublw 8 ;WREG = WREG - 8
    bnz readIsrBit
    
    ;If we got here then we have received a byte
    clrf bitCounter, 0 ;Use Access Bank
    movff tempCmdByte, POSTINC0
    clrf tempCmdByte, 0 ;Use Access Bank
    incf cmdLength, 1, 0 ;Use Access Bank
    
readIsrBit
    
    ;Read the data from RB2 and store it in the tempCmdByte
    rlncf tempCmdByte, 1, 0 ;Use Access Bank
    btfsc PORTB, 2 ;Test RB2. Skip if clear
    bsf tempCmdByte, 0, 0 ;Set the LSB of tempCmdByte if RB2 is set
    incf bitCounter, 1, 0 ;Use Access Bank
    
    
endIsrHighHandler
    bcf INTCON3, 1 ;Clear INT2 flag
    retfie 1 ;Return from interrupt and restore W, STATUS and BSR registers
    
isrLowHandler
    btfsc INTCON, 2 ;Test if the TMR0 overflow occurred
    bra isrTMR0Handler
    
    ;btfsc PIR1, 6 ;Test if AD conversion has happened
    ;bra isrADCHandler
    
    retfie 1 ;Return from interrupt and restore W, STATUS and BSR registers

isrTMR0Handler
    tstfsz cmdLength, 0 ;Skip if cmdLength == 0
    bra isrTMR0CmdReceived
    bra isrTMR0SkipCmdReceived
isrTMR0CmdReceived
    bsf cmdReceived, 0, 0 ;Use Access Bank
    
isrTMR0SkipCmdReceived
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    bcf INTCON, 2 ;Clear TMR0 flag
    retfie 1 ;Return from interrupt and restore W, STATUS and BSR registers
    
    org 0x100
start
    movlb 0xF ; Set BSR for banked SFRs
    bcf INTCON, 7 ;Disable global high interrupts
    bcf WDTCON, 0 ;Make sure that the WDT is disabled
    
    ;Configure oscillator
    movlw 0x74
    movwf OSCCON
    movlw 0x00
    movwf OSCCON2
    movlw 0x40
    movwf OSCTUNE
    ;bsf OSCTUNE, 6 ;OSCTUNE.PLLEN = 1
    
    
    ;Clear the first chunk of memory
    movlw 0x5b
    lfsr FSR0, 0x000
    clrf INDF0
clearMemoryLoop
    movwf FSR0L
    clrf INDF0
    decf WREG
    bnz clearMemoryLoop
    
    
    ;clrf LATB
    ;movlw 0x00
    ;movwf ANSELB
    ;bsf TRISB, 2
    ;bcf LATB, 2
    
    ;Clear global variables to be safe
    clrf tempCmdByte, 0 ;Use Access Bank
    clrf bitCounter, 0 ;Use Access Bank
    clrf cmdReceived, 0 ;Use Access Bank
    clrf cmdLength, 0 ;Use Access Bank
    
    lfsr FSR0, 0x10 ;FSR0 at the beginning of Bank 1
    
    ;CMD 0x00 answer
    lfsr FSR1, 0x20 ;FSR1 at 0x20
    movlw 0x09
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    movlw 0x03
    movwf POSTINC1
    
    ;CMD 0x41-0x42 answer
    lfsr FSR1, 0x40 ;FSR1 at 0x40
    movlw 0x00
    movwf POSTINC1
    movlw 0x80
    movwf POSTINC1
    movlw 0x80
    movwf POSTINC1
    movlw 0x80
    movwf POSTINC1
    movlw 0x80
    movwf POSTINC1
    movlw 0x80
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    
    ;Configuring analog inputs
    movlw 0x0F
    movwf ANSELA
    movlw 0x00
    movwf ANSELB
    movlw 0x18
    movwf ANSELC
    
    ;Setting inputs
    movlw 0xFF
    movwf TRISA
    movlw 0x07
    movwf TRISB
    movlw 0xFF
    movwf TRISC
    
    ;Set ADC
    movlw 0x09
    movwf ADCON0
    movlw 0x00
    movwf ADCON1
    movlw 0x3E
    ;movlw 0x08
    movwf ADCON2
    
    bcf PIR1, 6 ;ADIF = 0
    bcf PIE1, 6 ;ADIE = 0
    bcf IPR1, 6 ;ADIP low priority
    
    call buildOrigins

    ;Check if the board is booted in safe mode
    ;Hold X+Y+Z for safe mode
    bsf flagsSettings, 0, 0 ;Enable safe mode
    btfsc PORTA, 7 ;Skip if X is pressed
    bcf flagsSettings, 0, 0 ;Disable safe mode
    btfsc PORTA, 6 ;Skip if Y is pressed
    bcf flagsSettings, 0, 0 ;Disable safe mode
    btfsc PORTC, 0 ;Skip if Z is pressed
    bcf flagsSettings, 0, 0 ;Disable safe mode
    
    ;If X+Y+A are pressed on boot then reset the ranges to default
    btfsc PORTA, 6
    bra lutStart
    btfsc PORTA, 7
    bra lutStart
    btfsc PORTA, 4 ;A
    bra lutStart
    
    
    ;SXmax
    movlw 0x00
    movwf EEADR
    movlw 0xFF
    movwf EEDATA
    call EEPROMWrite
    
    
    ;SXmin
    movlw 0x01
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite
    
    ;SYmax
    movlw 0x02
    movwf EEADR
    movlw 0xFF
    movwf EEDATA
    call EEPROMWrite
    
    ;SYmin
    movlw 0x03
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite
    
    ;CXmax
    movlw 0x04
    movwf EEADR
    movlw 0xFF
    movwf EEDATA
    call EEPROMWrite
    
    ;CXmin
    movlw 0x05
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite
    
    ;CYmax
    movlw 0x06
    movwf EEADR
    movlw 0xFF
    movwf EEDATA
    call EEPROMWrite
    
    ;CYmin
    movlw 0x07
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite
    
    ;Invert axes
    movlw 0x08
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite
    
    ;Dead Zone Size
    movlw 0x09
    movwf EEADR
    movlw 0x18
    movwf EEDATA
    call EEPROMWrite
    
    ;Rumble Duty Cycle
    movlw 0x0A
    movwf EEADR
    movlw 0x00
    movwf EEDATA
    call EEPROMWrite

    ;Call customEEPROMSettings if not in safe mode
    btfss flagsSettings, 0, 0
    call customEEPROMSettings
    
    
lutStart
    ;EEDATA will hold range min
    ;tempCmdByte used as temp var for range
    
    movlw 0x09 ;Dead Zone Size
    movwf EEADR
    call EEPROMRead
    movff EEDATA, deadZoneSize
    
    movlw 0x0A ;Rumble Duty Cycle
    movwf EEADR
    call EEPROMRead
    movff EEDATA, rumbleDutyCycle
    
    movlw 0x08 ;Invert SX?
    movwf EEADR
    call EEPROMRead
    movlw 0x00
    movwf invertAxes, 0 ;Use Access Bank
    btfsc EEDATA, 0 ;SX invertAxis bit
    bsf invertAxes, 0, 0
    
    
    movlw 0x00
    movwf EEADR
    lfsr FSR2, 0x100 ;SX
    call lutBuild
    
    movlw 0x08 ;Invert SY?
    movwf EEADR
    call EEPROMRead
    movlw 0x00
    movwf invertAxes, 0 ;Use Access Bank
    btfsc EEDATA, 1 ;SY invertAxis bit
    bsf invertAxes, 0, 0
    
    movlw 0x02
    movwf EEADR
    lfsr FSR2, 0x200 ;SY
    call lutBuild
    
    movlw 0x08 ;Invert CX?
    movwf EEADR
    call EEPROMRead
    movlw 0x00
    movwf invertAxes, 0 ;Use Access Bank
    btfsc EEDATA, 2 ;CX invertAxis bit
    bsf invertAxes, 0, 0
    
    movlw 0x04
    movwf EEADR
    lfsr FSR2, 0x300 ;CX
    call lutBuild
    
    movlw 0x08 ;Invert CY?
    movwf EEADR
    call EEPROMRead
    movlw 0x00
    movwf invertAxes, 0 ;Use Access Bank
    btfsc EEDATA, 3 ;CY invertAxis bit
    bsf invertAxes, 0, 0
    
    movlw 0x06
    movwf EEADR
    lfsr FSR2, 0x400 ;CY
    call lutBuild
    
    
    ;Setup PWM for rumble
    bsf TRISB, 3 ;Disable rumble output (CCP2)
    bcf CCPTMRS0, 3 ;Use Timer2 for CCP2
    bcf CCPTMRS0, 4
    ;3.90 kHz
    movlw 0xFF
    movwf PR2
    movlw 0x0F ;PWM mode
    movwf CCP2CON
    setf CCPR2L ;Disable rumble
    bcf PIR2, 1
    movlw 0x07 ;1:16 prescaler
    movwf T2CON
    bcf TRISB, 3 ;Enable rumble output
    
    
    ;Setup Timer 4 for debouncing (1ms timer)
    movlw 0x40
    movwf PR4
    bcf PIE5, 0 ;Timer 4 interrupt disable
    bcf PIR5, 0 ;Clear TMR4IF
    movlw 0x7F
    movwf T4CON
    
    ;Default values for buttons
    ;The GC expect active high buttons
    clrf buttonsCurState0, 0 ;Access bank
    clrf buttonsCurState1, 0 ;Access bank
    clrf buttonsPrevState0, 0 ;Access bank
    clrf buttonsPrevState1, 0 ;Access bank
    ;Default values for buttons timers
    clrf buttonsTimerA, 0 ;Access bank
    clrf buttonsTimerB, 0 ;Access bank
    clrf buttonsTimerX, 0 ;Access bank
    clrf buttonsTimerY, 0 ;Access bank
    clrf buttonsTimerZ, 0 ;Access bank
    clrf buttonsTimerS, 0 ;Access bank
    clrf buttonsTimerRT, 0 ;Access bank
    clrf buttonsTimerLT, 0 ;Access bank
    clrf buttonsTimerDU, 0 ;Access bank
    clrf buttonsTimerDD, 0 ;Access bank
    clrf buttonsTimerDR, 0 ;Access bank
    clrf buttonsTimerDL, 0 ;Access bank

    ;Enable pull-up on data line
    bsf WPUB, 2
    bcf INTCON2, 7

    ;Call customInit if not in safe mode
    btfss flagsSettings, 0, 0
    call customInit
    
    ;Configure INT2 interrupt
    bcf INTCON3, 1 ;Clear INT2 flag
    bcf INTCON2, 4 ;INT2 on falling edge
    bsf INTCON3, 4 ;Enable INT2
    bsf INTCON3, 7 ;INT2 high priority
    
    bsf RCON, 7 ;Enable priority levels on interrupts
    
    movlw 0x48 ;TMR0 disabled. 8bit. 1:1 (16us). Fosc/4
    movwf T0CON
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    movlw 0x00
    movwf TMR0H ;Not used, but meh
    bcf INTCON, 2 ;TMR0IF = 0
    bsf INTCON, 5 ;TMR0IE = 1
    bcf INTCON2, 2 ;TMR0 low priority
    
    bsf T0CON, 7 ;Enable TMR0
    bsf INTCON, 6 ;Enable global low interrupts
    bsf INTCON, 7 ;Enable global high interrupts
    
    bsf ADCON0, 1
    
    bsf WDTCON, 0 ;Enable WDT

    btfss flagsSettings, 0, 0
    goto customLoopCode
    
mainLoop
    ;Clear WDT only if X, Y and Start are not pressed together
    ; => Clear WDT if at least one of the X, Y, Start is not pressed
    
    btfsc PORTA, 7 ;X
    clrwdt
    btfsc PORTA, 6 ;Y
    clrwdt
    btfsc PORTC, 1 ;Start
    clrwdt

    btfsc cmdReceived, 0, 0
    call handleCmd

    call readButtonsAndDebounce
    
    btfss ADCON0, 1 ;Check if the ADC is done
    call getADC
    
    goto mainLoop
    
readButtonsAndDebounce
    btfss PIR5, 0 ;If TMR4IF isn't set return
    return
    
    bcf PIR5, 0; TMR4IF = 0
    
    ;Increase timers
    incf buttonsTimerA, 1, 0 ;Access bank
    incf buttonsTimerB, 1, 0 ;Access bank
    incf buttonsTimerX, 1, 0 ;Access bank
    incf buttonsTimerY, 1, 0 ;Access bank
    incf buttonsTimerZ, 1, 0 ;Access bank
    incf buttonsTimerS, 1, 0 ;Access bank
    incf buttonsTimerRT, 1, 0 ;Access bank
    incf buttonsTimerLT, 1, 0 ;Access bank
    incf buttonsTimerDU, 1, 0 ;Access bank
    incf buttonsTimerDD, 1, 0 ;Access bank
    incf buttonsTimerDR, 1, 0 ;Access bank
    incf buttonsTimerDL, 1, 0 ;Access bank
    
    
    movlw 0x00
    btfss PORTC, 1 ;Start
    bsf WREG, 4
    btfss PORTA, 6 ;Y
    bsf WREG, 3
    btfss PORTA, 7 ;X
    bsf WREG, 2
    btfss PORTA, 5 ;B
    bsf WREG, 1
    btfss PORTA, 4 ;A
    bsf WREG, 0
    xorwf buttonsPrevState0, 1, 0 ;buttonsPrevState0 = WREG ^ buttonsPrevState0
    movff buttonsPrevState0, buttonsMixState0
    movwf buttonsPrevState0 ;buttonsPrevState0 = WREG
    
    movlw 0x00
    btfss PORTC, 5 ;LT
    bsf WREG, 6
    btfss PORTC, 2 ;RT
    bsf WREG, 5
    btfss PORTC, 0 ;Z
    bsf WREG, 4
    btfss PORTC, 6 ;DU
    bsf WREG, 3
    btfss PORTC, 7 ;DD
    bsf WREG, 2
    btfss PORTB, 0 ;DR
    bsf WREG, 1
    btfss PORTB, 1 ;DL
    bsf WREG, 0
    xorwf buttonsPrevState1, 1, 0 ;buttonsPrevState1 = WREG ^ buttonsPrevState1
    movff buttonsPrevState1, buttonsMixState1
    movwf buttonsPrevState1 ;buttonsPrevState1 = WREG
    bsf buttonsCurState1, 7, 0 ;MSB always high
    
    ;Reset timer if the button has changed state
    btfsc buttonsMixState0, 0
    clrf buttonsTimerA, 0 ;Access bank
    btfsc buttonsMixState0, 1
    clrf buttonsTimerB, 0 ;Access bank
    btfsc buttonsMixState0, 2
    clrf buttonsTimerX, 0 ;Access bank
    btfsc buttonsMixState0, 3
    clrf buttonsTimerY, 0 ;Access bank
    btfsc buttonsMixState0, 4
    clrf buttonsTimerS, 0 ;Access bank
    
    btfsc buttonsMixState1, 0
    clrf buttonsTimerDL, 0 ;Access bank
    btfsc buttonsMixState1, 1
    clrf buttonsTimerDR, 0 ;Access bank
    btfsc buttonsMixState1, 2
    clrf buttonsTimerDD, 0 ;Access bank
    btfsc buttonsMixState1, 3
    clrf buttonsTimerDU, 0 ;Access bank
    btfsc buttonsMixState1, 4
    clrf buttonsTimerZ, 0 ;Access bank
    btfsc buttonsMixState1, 5
    clrf buttonsTimerRT, 0 ;Access bank
    btfsc buttonsMixState1, 6
    clrf buttonsTimerLT, 0 ;Access bank
    
    
    ;Update the state of buttons (we check if bit 3 is set => The timer reached 8
    btfss buttonsTimerA, 3, 0
    bra endTimerA
    decf buttonsTimerA, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 0, 0
    btfss PORTA, 4 ;A
    bsf buttonsCurState0, 0, 0
endTimerA
    
    btfss buttonsTimerB, 3, 0
    bra endTimerB
    decf buttonsTimerB, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 1, 0
    btfss PORTA, 5 ;B
    bsf buttonsCurState0, 1, 0
endTimerB
    
    btfss buttonsTimerX, 3, 0
    bra endTimerX
    decf buttonsTimerX, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 2, 0
    btfss PORTA, 7 ;X
    bsf buttonsCurState0, 2, 0
endTimerX
    
    btfss buttonsTimerY, 3, 0
    bra endTimerY
    decf buttonsTimerY, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 3, 0
    btfss PORTA, 6 ;Y
    bsf buttonsCurState0, 3, 0
endTimerY
    
    btfss buttonsTimerS, 3, 0
    bra endTimerS
    decf buttonsTimerS, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 4, 0
    btfss PORTC, 1 ;S
    bsf buttonsCurState0, 4, 0
endTimerS
    
    btfss buttonsTimerDL, 3, 0
    bra endTimerDL
    decf buttonsTimerDL, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 0, 0
    btfss PORTB, 1 ;DL
    bsf buttonsCurState1, 0, 0
endTimerDL
    
    btfss buttonsTimerDR, 3, 0
    bra endTimerDR
    decf buttonsTimerDR, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 1, 0
    btfss PORTB, 0 ;DR
    bsf buttonsCurState1, 1, 0
endTimerDR
    
    btfss buttonsTimerDD, 3, 0
    bra endTimerDD
    decf buttonsTimerDD, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 2, 0
    btfss PORTC, 7 ;DD
    bsf buttonsCurState1, 2, 0
endTimerDD
    
    btfss buttonsTimerDU, 3, 0
    bra endTimerDU
    decf buttonsTimerDU, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 3, 0
    btfss PORTC, 6 ;DU
    bsf buttonsCurState1, 3, 0
endTimerDU
    
    btfss buttonsTimerZ, 3, 0
    bra endTimerZ
    decf buttonsTimerZ, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 4, 0
    btfss PORTC, 0 ;Z
    bsf buttonsCurState1, 4, 0
endTimerZ
    
    btfss buttonsTimerRT, 3, 0
    bra endTimerRT
    decf buttonsTimerRT, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 5, 0
    btfss PORTC, 2 ;RT
    bsf buttonsCurState1, 5, 0
endTimerRT
    
    btfss buttonsTimerLT, 3, 0
    bra endTimerLT
    decf buttonsTimerLT, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 6, 0
    btfss PORTC, 5 ;LT
    bsf buttonsCurState1, 6, 0
endTimerLT
    
    return ;readButtonsAndDebounce

lutBuild
    ;Build LUT table
    bcf INTCON, GIE ; Disable Interrupts
    bcf EECON1, EEPGD ; Point to DATA memory
    bcf EECON1, CFGS ; Access EEPROM
    bsf EECON1, RD ; EEPROM Read
    movff EEDATA, WREG ; W = EEDATA
    
    incf EEADR, 1
    bcf EECON1, EEPGD ; Point to DATA memory
    bcf EECON1, CFGS ; Access EEPROM
    bsf EECON1, RD ; EEPROM Read
    ;Now EEDATA holds the range min value
    
    subfwb EEDATA, 0, 1 ;W = rangeMax - rangeMin
    movwf tempCmdByte, 0
    
    
    movlw 0x00
lutLoop
    movff WREG, lutCounter
    btfsc invertAxes, 0
    sublw 0xFF
    movff WREG, FSR2L
    movff lutCounter, WREG
    subfwb EEDATA, 0, 1 ;W = stick - rangeMin
    btfss STATUS, 0 ;Test if stick > rangeMin
    movlw 0x00
    movff WREG, f_divhi
    movff tempCmdByte, WREG ;W = rangeMax - rangeMin
    clrf f_divlo
    call Div
    movff f_divlo, WREG
    btfsc STATUS, 0 ;Test if stick < rangeMax
    movlw 0xFF
    movwf INDF2
    
    ;Increase dead zone
    ;movff INDF2, WREG
    btfss WREG, 7
    sublw 0x80 ;If WREG < 0x80 => WREG = 0x80 - WREG
    andlw 0x7F
    bz lutSkipDeadZone
    ;sublw 0x18 ;+/-24 dead zone
    subwf deadZoneSize, 0, 0 ;WREG = deadZoneSize - WREG
    movff INDF2, WREG
    btfss STATUS, 4
    movlw 0x80
    movwf INDF2
lutSkipDeadZone
    
    movff lutCounter, WREG
    incf WREG
    bnc lutLoop
    
    clrf tempCmdByte, 0 ;Use Access Bank
    return ;lutBuild
    
handleCmdTest
    bcf INTCON, 7 ;Disable global interrupts
    bcf cmdReceived, 0, 0
    lfsr FSR1, 0x10
    movff cmdLength, dataLength
    
    call sendData
    lfsr FSR0, 0x10 ;FSR0 at 0x10
    bra handleCmdEnd
    

handleCmd
    bcf INTCON, 7 ;Disable global interrupts
    bcf cmdReceived, 0, 0
    lfsr FSR0, 0x10 ;FSR0 at 0x10

    movlw 0x00 ;Acknowledge
    subwf INDF0, 0, 1
    bnz skipCmd0x00
    goto cmd0x00
skipCmd0x00

    ;Main ones must be checked ASAP
    movlw 0x40 ;Controller status
    subwf INDF0, 0, 1
    bnz skipCmd0x40
    goto cmd0x40
skipCmd0x40

    movlw 0x41 ;Origins
    subwf INDF0, 0, 1
    bnz skipCmd0x41
    goto cmd0x41
skipCmd0x41

    movlw 0x42 ;Origins
    subwf INDF0, 0, 1
    bnz skipCmd0x42
    goto cmd0x41 ;Same answer as 0x41
skipCmd0x42

    movlw 0x1F ;Read ranges+invert
    subwf INDF0, 0, 1
    bnz skipCmd0x1F
    goto cmd0x1F
skipCmd0x1F

    movlw 0x20 ;Write ranges+invert
    subwf INDF0, 0, 1
    bnz skipCmd0x20
    goto cmd0x20
skipCmd0x20

    movlw 0x21 ;Write DZ
    subwf INDF0, 0, 1
    bnz skipCmd0x21
    goto cmd0x21
skipCmd0x21

    movlw 0x22 ;Read DZ
    subwf INDF0, 0, 1
    bnz skipCmd0x22
    goto cmd0x22
skipCmd0x22

    movlw 0x23 ;Write Rumble
    subwf INDF0, 0, 1
    bnz skipCmd0x23
    goto cmd0x23
skipCmd0x23

    movlw 0x24 ;Read Rumble
    subwf INDF0, 0, 1
    bnz skipCmd0x24
    goto cmd0x24
skipCmd0x24

    movlw 0x25 ;Update mode
    subwf INDF0, 0, 1
    bnz skipCmd0x25
    goto cmd0x25
skipCmd0x25

    movlw 0x30 ;Get firmware version
    subwf INDF0, 0, 1
    bnz skipCmd0x30
    goto cmd0x30
skipCmd0x30

    movlw 0x31 ;Get board version
    subwf INDF0, 0, 1
    bnz skipCmd0x31
    goto cmd0x31
skipCmd0x31

    bra handleCmdEnd

    
cmd0x00
    lfsr FSR1, 0x20 ;FSR1 at 0x20
    movlw 0x03
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
    
cmd0x41
    lfsr FSR1, 0x40 ;FSR1 at 0x40
    movlw 0x0A
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
    
cmd0x21 ;Write Dead Zone Size
    movff POSTINC0, WREG ;Dummy read
    
    ;Dead Zone Size
    movlw 0x09
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset
    
cmd0x22 ;Read Dead Zone Size
    lfsr FSR1, deadZoneSize
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
    
cmd0x23 ;Write Rumble
    movff POSTINC0, WREG ;Dummy read
    
    ;Rumble Duty Cycle
    movlw 0x0A
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset
    
cmd0x24 ;Read Rumble
    lfsr FSR1, rumbleDutyCycle
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
    
cmd0x25 ;Update mode
    ;Send no error (0x00)
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x00
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    goto updateMode

cmd0x30
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x01
    movff WREG, POSTINC1
    movlw 0x00
    movff WREG, POSTINC1
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x02
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd

cmd0x31
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw boardMajVer
    movff WREG, POSTINC1
    movlw boardMinVer
    movff WREG, POSTINC1
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x02
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
   
cmd0x40
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    addwf POSTINC0, 0, 1 ;Dummy read
    addwf POSTINC0, 0, 1 ;Dummy read
    btfss INDF0, 0
    ;bcf LATB, 3 ;Disable rumble
    setf CCPR2L
    btfsc INDF0, 0
    movff rumbleDutyCycle, CCPR2L
    ;bsf LATB, 3 ;Enable rumble
    
    movff buttonsCurState0, POSTINC1
    movff buttonsCurState1, POSTINC1
    
    movff 0x50, POSTINC1 ;SX
    movff 0x51, POSTINC1 ;SY
    movff 0x52, POSTINC1 ;CX
    movff 0x53, POSTINC1 ;CY
    movff 0x55, POSTINC1 ;L
    movff 0x54, POSTINC1 ;R
    
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x08
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd

cmd0x1F ;Read ranges+invert
    lfsr FSR1, 0x38

    movlw 0x08
cmd0x1FReadLoop
    movwf EEADR
    call EEPROMRead
    movff EEDATA, POSTDEC1
    decf WREG
    bnn cmd0x1FReadLoop ;If WREG became negative stop looping

    lfsr FSR1, 0x30
    movlw 0x09
    movwf dataLength, 0
    call sendData
    bra handleCmdEnd
    
cmd0x20 ;Write ranges+invert
    movff POSTINC0, WREG ;Dummy read
    
    ;SXmax
    movlw 0x00
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SXmin
    movlw 0x01
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SYmax
    movlw 0x02
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SYmin
    movlw 0x03
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CXmax
    movlw 0x04
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CXmin
    movlw 0x05
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CYmax
    movlw 0x06
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CYmin
    movlw 0x07
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;Invert axes
    movlw 0x08
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset

calibrateADC
    subwf ADRESH, 0
    bc gtCalibrateADC ;If stick > origin go to gtCalibrateADC
    addlw 0x80
    btfss STATUS, 0
    clrf WREG
    return
gtCalibrateADC
    addlw 0x80
    btfsc STATUS, 0
    setf WREG
    return
    
calibrateADCTrigger
    subwf ADRESH, 0
    bc gtCalibrateADCTrigger ;If trigger > origin go to gtCalibrateADCTrigger
    addlw 0x00
    btfss STATUS, 0
    clrf WREG
    return
gtCalibrateADCTrigger
    addlw 0x00
    btfsc STATUS, 0
    setf WREG
    return
    
getADC
    incf curADInput, 1, 0
    movff curADInput, WREG
    decf WREG, 0
    bz getADC0
    decf WREG, 0
    bz getADC1
    decf WREG, 0
    bz getADC2
    decf WREG, 0
    bz getADC3
    decf WREG, 0
    bz getADC4
    decf WREG, 0
    bz getADC5
    return
    
getADC0
    lfsr FSR2, 0x100 ;SX
    movff 0x56, WREG
    call calibrateADC
    movff WREG, FSR2L
    movff INDF2, 0x50
    
    movlw 0x0D
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC1
    lfsr FSR2, 0x200 ;SY
    movff 0x57, WREG
    call calibrateADC
    movff WREG, FSR2L
    movff INDF2, 0x51
    movlw 0x01
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC2
    lfsr FSR2, 0x300 ;CX
    movff 0x58, WREG
    call calibrateADC
    movff WREG, FSR2L
    movff INDF2, 0x52
    movlw 0x05
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC3
    lfsr FSR2, 0x400 ;CY
    movff 0x59, WREG
    call calibrateADC
    movff WREG, FSR2L
    movff INDF2, 0x53
    movlw 0x3D
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC4
    movff 0x5a, WREG
    call calibrateADCTrigger
    movff WREG, 0x54 ;R
    movlw 0x41
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC5
    movff 0x5b, WREG
    call calibrateADCTrigger
    movff WREG, 0x55 ;L
    movlw 0x09
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    ;bcf ADStatus, 0, 0
    return
    
buildOrigins
    movlw 0x09
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop0
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop0
    movff ADRESH, 0x56 ;SX
    
    movlw 0x0D
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop1
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop1
    movff ADRESH, 0x57 ;SY
    
    movlw 0x01
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop2
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop2
    movff ADRESH, 0x58 ;CX
    
    movlw 0x05
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop3
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop3
    movff ADRESH, 0x59 ;CY
    
    movlw 0x3D
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop4
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop4
    movff ADRESH, 0x5a ;R
    
    movlw 0x41
    movwf ADCON0
    bsf ADCON0, 1
originsWaitLoop5
    btfsc ADCON0, 1 ;Check if the ADC is done
    bra originsWaitLoop5
    movff ADRESH, 0x5b ;L
    
    return
    
    
    org 0x900
handleCmdEnd
    bcf INTCON, 7 ;Disable global interrupts
    lfsr FSR0, 0x10 ;FSR0 at 0x10
    bsf TRISB, 2 ;Setting RB2 as input will put it high (through the pull-up resistor)
    bcf INTCON3, 1 ;Clear INT2 flag
    clrf tempCmdByte, 0 ;Use Access Bank
    clrf bitCounter, 0 ;Use Access Bank
    clrf cmdReceived, 0 ;Use Access Bank
    clrf cmdLength, 0 ;Use Access Bank
    
    movlw 0x48 ;TMR0 disabled. 8bit. 1:1 (16us). Fosc/4
    movwf T0CON
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    bcf INTCON, 2 ;TMR0IF = 0
    bsf T0CON, 7 ;Enable TMR0
    bsf INTCON, 7 ;Enable global interrupts
    return
    
    org 0xA00
sendData
    bcf INTCON, 7 ;Disable global interrupts
    
    bsf TRISB, 2
    bcf LATB, 2
    
sendDataLoop
    movlw 0x08
    movwf bitCounterTX, 0
    movf dataLength, 0, 0 ;Move dataLength to W. Use Access Bank
    bz sendDataEnd
    movff POSTINC1, curByte ;Move POSTINC1 to curByte
    ;movwf curByte, 0
    
sendDataBitLoop
    rlcf curByte, 1, 0
    bc sendDataHighBit
    ;If we got here then a low bit must be send
    nop ;This is used to syncronize with high bits
    bcf TRISB, 2 ;Setting RB0 as output will put it low
    
    ;Wait 47 cycles
    movlw 0x0E
    movwf waitLoopCounter, 0
waitLoop1 ;This will wait 44 cycles
    nop
    decf waitLoopCounter, 1, 0
    bnz waitLoop1
    nop ;This will add a 4th cycle to the last loop
    nop
    
    bsf TRISB, 2 ;Setting RB0 as input will put it high (through the pull-up resistor)
    nop
    
    bra sendDataBitLoopEnd
sendDataHighBit
    bcf TRISB, 2 ;Setting RB0 as output will put it low
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    bsf TRISB, 2 ;Setting RB0 as input will put it high (through the pull-up resistor)
    
    ;Wait 34 cycles
    movlw 0x09
    movwf waitLoopCounter, 0
waitLoop2 ;This will wait 32 cycles
    nop
    decf waitLoopCounter, 1, 0
    bnz waitLoop2
    nop
    
    
sendDataBitLoopEnd
    decf bitCounterTX, 1, 0
    bz sendDataByteLoopReady
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    bra sendDataBitLoop
    
sendDataByteLoopReady
    decf dataLength, 1, 0
    bra sendDataLoop
    
sendDataEnd
    nop
    nop
    ;Send a stop bit
    bcf TRISB, 2 ;Setting RB2 as output will put it low
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    
    bsf TRISB, 2 ;Setting RB2 as input will put it high (through the pull-up resistor)
    bcf INTCON3, 1 ;Clear INT2 flag
    clrf tempCmdByte, 0 ;Use Access Bank
    clrf bitCounter, 0 ;Use Access Bank
    clrf cmdReceived, 0 ;Use Access Bank
    clrf cmdLength, 0 ;Use Access Bank
    bcf INTCON, 2 ;TMR0IF = 0
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    
    bsf INTCON, 7 ;Enable global interrupts
    return



;-[ Div ]--------------------------------------------------------------
; Call w/: Number in f_divhi:f_divlo, divisor in W.
; Returns: Quotient in f_divlo, remainder in f_divhi. W preserved.
;          Carry set if error. Z if divide by zero, NZ if divide overflow.
; Notes:   Works by left shifted subtraction.
;          Size = 29, Speed(w/ call&ret) = 7 cycles if div by zero
;          Speed = 94 minimum, 129 maximum cycles
    org 0xB00
Div
    addlw 0          ; w+=0 (to test for div by zero)
    bsf STATUS, 0    ; set carry in case of error
    btfsc STATUS, 2  ; if zero
     return          ;   return (error C,Z)

    call DivSkipHiShift
    
    call DivCode
    call DivCode
    call DivCode
    call DivCode
    call DivCode
    call DivCode
    call DivCode
    call DivCode

    rlcf f_divlo, 1, 0 ; C << lo << C

    ; If the first subtract didn't underflow, and the carry was shifted
    ; into the quotient, then it will be shifted back off the end by this
    ; last RLCF. This will automatically raise carry to indicate an error.
    ; The divide will be accurate to quotients of 9-bits, but past that
    ; the quotient and remainder will be bogus and carry will be set.

    bcf STATUS, 2 ; NZ (in case of overflow error)
    return        ; we are done!

DivCode
    rlcf f_divlo, 1, 0    ; C << lo << C
    rlcf f_divhi, 1, 0    ; C << hi << C
    btfss STATUS, 0   ; if Carry
     goto DivSkipHiShift ;
    subwf f_divhi, 1, 0  ;   hi-=w
    bsf STATUS, 0     ;   ignore carry
    return            ;   done
                      ; endif
DivSkipHiShift
    subwf f_divhi, 1, 0 ; hi-=w
    btfsc STATUS, 0     ; if carry set
     return             ;   done
    addwf f_divhi, 1, 0 ; hi+=w
    bcf STATUS, 0       ; clear carry
    return              ; done

    org 0xC00
EEPROMWrite
    bcf EECON1, EEPGD ;DATA memory
    bcf EECON1, CFGS ; Access EEPROM
    bsf EECON1, WREN ; Enable writes
    bcf INTCON, GIE ; Disable Interrupts
    movlw 55h ;
    movwf EECON2 ; Write 55h
    movlw 0AAh ;
    movwf EECON2 ; Write 0AAh
    ;bcf PIR2, EEIF
    bsf EECON1, WR ; Set WR bit to begin write
EEPROMWaitWrite
    btfss PIR2, EEIF
    bra EEPROMWaitWrite
    bcf PIR2, EEIF
    bcf EECON1, WREN ; Disable writes on write complete (EEIF set)
    
    return
    
    org 0xD00
EEPROMRead
    movwf EEADR ; Data Memory Address to read
    bcf INTCON, GIE ; Disable Interrupts
    bcf EECON1, EEPGD ; Point to DATA memory
    bcf EECON1, CFGS ; Access EEPROM
    bsf EECON1, RD ; EEPROM Read
    return

    org 0x1000
updateMode
    bcf WDTCON, 0 ;Disable WDT during update process

    call handleUpdateCmdEnd ;This will re-enable cmds reception

updateLoop
    btfsc cmdReceived, 0, 0
    call handleUpdateCmd

    bra updateLoop

handleUpdateCmd
    bcf INTCON, 7 ;Disable global interrupts
    bcf cmdReceived, 0, 0
    lfsr FSR0, 0x10 ;FSR0 at 0x10
    
    movlw 0x10 ;Reset FSR2
    subwf INDF0, 0, 1
    bz updateCmd0x10
    movlw 0x11 ;Store 8 bytes
    subwf INDF0, 0, 1
    bz updateCmd0x11
    movlw 0x12 ;Write 64 bytes block to flash
    subwf INDF0, 0, 1
    bz updateCmd0x12

    movlw 0x13 ;End update process
    subwf INDF0, 0, 1
    bnz skipCmd0x13
    goto updateCmd0x13
skipCmd0x13

    bra handleUpdateCmdEnd

    
updateCmd0x10
    lfsr FSR2, 0x100 ;Reset FSR2 to 0x100
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x00
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleUpdateCmdEnd
    
updateCmd0x11
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    lfsr FSR0, 0x11 ;Data starts at 0x11
    movlw 0x00
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    addwf POSTINC0, 0
    comf WREG, 0
    incf WREG, 0
    subwf INDF0, 0
    bz updateCmd0x11CopyData
    ;Send wrong checksum error (0x01)
    movlw 0x01
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleUpdateCmdEnd

updateCmd0x11CopyData
    lfsr FSR0, 0x11 ;Data starts at 0x11
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2
    movff POSTINC0, POSTINC2

    ;Send no error (0x00)
    movlw 0x00
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleUpdateCmdEnd
    
updateCmd0x12
    lfsr FSR1, 0x30 ;FSR1 at 0x30

    ;Check high-byte address range
    lfsr FSR0, 0x11 ;Address starts at 0x11
    
    ;Check range (0x20 <= WREG <= 0x60)
    movff INDF0, WREG
    addlw 0x9F ;255 - 0x60
    addlw 0x41 ;(0x60 - 0x20) + 1
    bc updateCmd0x12AddressOK ;If in the range the carry is set

    ;Send wrong address error (0x02)
    movlw 0x02
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleUpdateCmdEnd
    
updateCmd0x12AddressOK
    ;Erase block
    lfsr FSR0, 0x11 ;Address starts at 0x11
    movlw 0x00
    movff WREG, TBLPTRU
    movff POSTINC0, TBLPTRH
    movff INDF0, TBLPTRL
    bsf EECON1, EEPGD
    bcf EECON1, CFGS
    bsf EECON1, WREN
    bsf EECON1, FREE
    movlw 0x55
    movwf EECON2
    movlw 0xAA
    movwf EECON2
    bsf EECON1, WR
updateCmd0x12WaitErase
    btfsc EECON1, WR
    bra updateCmd0x12WaitErase

    tblrd*-

    ;Write block
    ;lfsr FSR0, 0x11 ;Address starts at 0x11
    ;movlw 0x00
    ;movff WREG, TBLPTRU
    ;movff POSTINC0, TBLPTRH
    ;movff INDF0, TBLPTRL
    lfsr FSR2, 0x100 ;Reset FSR2 to 0x200
    movlw 0x40
updateCmd0x12WriteLoop
    movff POSTINC2, TABLAT
    tblwt+*
    decfsz WREG
    bra updateCmd0x12WriteLoop
    bsf EECON1, EEPGD
    bcf EECON1, CFGS
    bsf EECON1, WREN
    movlw 0x55
    movwf EECON2
    movlw 0xAA
    movwf EECON2
    bsf EECON1, WR
updateCmd0x12WaitWrite
    btfsc EECON1, WR
    bra updateCmd0x12WaitWrite
    bcf EECON1, WREN

    ;Send no error (0x00)
    movlw 0x00
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    bra handleUpdateCmdEnd
    
updateCmd0x13
    call customEEPROMSettings
    reset

handleUpdateCmdEnd
    bcf INTCON, 7 ;Disable global interrupts
    lfsr FSR0, 0x10 ;FSR0 at 0x10
    bsf TRISB, 2 ;Setting RB2 as input will put it high (through the pull-up resistor)
    bcf INTCON3, 1 ;Clear INT2 flag
    clrf tempCmdByte, 0 ;Use Access Bank
    clrf bitCounter, 0 ;Use Access Bank
    clrf cmdReceived, 0 ;Use Access Bank
    clrf cmdLength, 0 ;Use Access Bank
    
    movlw 0x48 ;TMR0 disabled. 8bit. 1:1 (16us). Fosc/4
    movwf T0CON
    movlw 0x80 ;Starts from 128 => Wait only 8us
    movwf TMR0L
    bcf INTCON, 2 ;TMR0IF = 0
    bsf T0CON, 7 ;Enable TMR0
    bsf INTCON, 7 ;Enable global interrupts
    return
    
    org 0x2000 ;Custom init
customInit
    movlw 0x7F
    movwf T4CON
    
    ;Enable pull-up on data line
    bsf WPUB, 2
    bcf INTCON2, 7

    ;CMD 0x00 answer
    lfsr FSR1, 0x20 ;FSR1 at 0x20
    movlw 0x09
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    movlw 0x00
    movwf POSTINC1
    return

    org 0x3000 ;Custom EEPROM default settings
customEEPROMSettings
    return

    org 0x4000 ;Custom loop
customLoopCode
    ;Clear WDT only if X, Y and Start are not pressed together
    ; => Clear WDT if at least one of the X, Y, Start is not pressed
    
    btfsc PORTA, 7 ;X
    clrwdt
    btfsc PORTA, 6 ;Y
    clrwdt
    btfsc PORTC, 1 ;Start
    clrwdt

    btfsc cmdReceived, 0, 0
    call handleCmdCustom

    call readButtonsAndDebounceCustom
    
    btfss ADCON0, 1 ;Check if the ADC is done
    call getADCCustom
    
    goto customLoopCode

handleCmdCustom
    bcf INTCON, 7 ;Disable global interrupts
    bcf cmdReceived, 0, 0
    lfsr FSR0, 0x10 ;FSR0 at 0x10

    movlw 0x00 ;Acknowledge
    subwf INDF0, 0, 1
    bnz skipCmd0x00Custom
    goto cmd0x00Custom
skipCmd0x00Custom

    movlw 0xFF ;Acknowledge
    subwf INDF0, 0, 1
    bnz skipCmd0xFFCustom
    goto cmd0x00Custom
skipCmd0xFFCustom

    ;Main ones must be checked ASAP
    movlw 0x40 ;Controller status
    subwf INDF0, 0, 1
    bnz skipCmd0x40Custom
    goto cmd0x40Custom
skipCmd0x40Custom

    movlw 0x41 ;Origins
    subwf INDF0, 0, 1
    bnz skipCmd0x41Custom
    goto cmd0x41Custom
skipCmd0x41Custom

    movlw 0x42 ;Origins
    subwf INDF0, 0, 1
    bnz skipCmd0x42Custom
    goto cmd0x41Custom ;Same answer as 0x41
skipCmd0x42Custom

    movlw 0x1F ;Read ranges+invert
    subwf INDF0, 0, 1
    bnz skipCmd0x1FCustom
    goto cmd0x1FCustom
skipCmd0x1FCustom

    movlw 0x20 ;Write ranges+invert
    subwf INDF0, 0, 1
    bnz skipCmd0x20Custom
    goto cmd0x20Custom
skipCmd0x20Custom

    movlw 0x21 ;Write DZ
    subwf INDF0, 0, 1
    bnz skipCmd0x21Custom
    goto cmd0x21Custom
skipCmd0x21Custom

    movlw 0x22 ;Read DZ
    subwf INDF0, 0, 1
    bnz skipCmd0x22Custom
    goto cmd0x22Custom
skipCmd0x22Custom

    movlw 0x23 ;Write Rumble
    subwf INDF0, 0, 1
    bnz skipCmd0x23Custom
    goto cmd0x23Custom
skipCmd0x23Custom

    movlw 0x24 ;Read Rumble
    subwf INDF0, 0, 1
    bnz skipCmd0x24Custom
    goto cmd0x24Custom
skipCmd0x24Custom

    movlw 0x25 ;Update mode
    subwf INDF0, 0, 1
    bnz skipCmd0x25Custom
    goto cmd0x25Custom
skipCmd0x25Custom

    movlw 0x30 ;Get firmware version
    subwf INDF0, 0, 1
    bnz skipCmd0x30Custom
    goto cmd0x30Custom
skipCmd0x30Custom

    movlw 0x31 ;Get board version
    subwf INDF0, 0, 1
    bnz skipCmd0x31Custom
    goto cmd0x31Custom
skipCmd0x31Custom

    call handleCmdEnd
    return
    
cmd0x00Custom
    lfsr FSR1, 0x20 ;FSR1 at 0x20
    movlw 0x03
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
    
cmd0x41Custom
    lfsr FSR1, 0x40 ;FSR1 at 0x40
    movlw 0x0A
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
    
cmd0x21Custom ;Write Dead Zone Size
    movff POSTINC0, WREG ;Dummy read
    
    ;Dead Zone Size
    movlw 0x09
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset
    
cmd0x22Custom ;Read Dead Zone Size
    lfsr FSR1, deadZoneSize
    movlw 0x01
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
    
cmd0x23Custom ;Write Rumble
    movff POSTINC0, WREG ;Dummy read
    
    ;Rumble Duty Cycle
    movlw 0x0A
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset
    
cmd0x24Custom ;Read Rumble
    lfsr FSR1, rumbleDutyCycle
    movlw 0x01
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
    
cmd0x25Custom ;Update mode
    ;Send no error (0x00)
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x00
    movff WREG, INDF1
    movlw 0x01
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    goto updateMode

cmd0x30Custom
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw firmMajVer
    movff WREG, POSTINC1
    movlw firmMinVer
    movff WREG, POSTINC1
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x02
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return

cmd0x31Custom
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw boardMajVer
    movff WREG, POSTINC1
    movlw boardMinVer
    movff WREG, POSTINC1
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x02
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
   
cmd0x40Custom
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    addwf POSTINC0, 0, 1 ;Dummy read
    movff POSTINC0, analogMode ;Read analogMode from 2nd byte
    btfss INDF0, 0 ;Third byte carries info about the rumble
    ;bcf LATB, 3 ;Disable rumble
    setf CCPR2L
    btfsc INDF0, 0
    movff rumbleDutyCycle, CCPR2L
    ;bsf LATB, 3 ;Enable rumble

    movlw 0x00
    btfss PORTC, 1 ;Start
    bsf WREG, 4
    btfss PORTA, 6 ;Y
    bsf WREG, 3
    btfss PORTA, 7 ;X
    bsf WREG, 2
    btfss PORTA, 5 ;B
    bsf WREG, 1
    btfss PORTA, 4 ;A
    bsf WREG, 0

    ;Buttons swap test
    ;movff buttonsCurState0, WREG
    ;andlw 0xF3 ;Set X and Y to 0
    ;btfsc buttonsCurState0, 3, 0 ;If Yin = 1
    ;bsf WREG, 2 ;Xout = 1
    ;btfsc buttonsCurState0, 2, 0 ;If Xin = 1
    ;bsf WREG, 3 ;Yout = 1
    
    movff buttonsCurState0, POSTINC1
    movff buttonsCurState1, POSTINC1
    
    movff 0x50, POSTINC1 ;SX
    movff 0x51, POSTINC1 ;SY
    movff 0x52, POSTINC1 ;CX
    movff 0x53, POSTINC1 ;CY
    movff 0x55, POSTINC1 ;L
    movff 0x54, POSTINC1 ;R
    
    lfsr FSR1, 0x30 ;FSR1 at 0x30
    movlw 0x08
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return

cmd0x1FCustom ;Read ranges+invert
    lfsr FSR1, 0x38

    movlw 0x08
cmd0x1FReadLoopCustom
    movwf EEADR
    call EEPROMRead
    movff EEDATA, POSTDEC1
    decf WREG
    bnn cmd0x1FReadLoopCustom ;If WREG became negative stop looping

    lfsr FSR1, 0x30
    movlw 0x09
    movwf dataLength, 0
    call sendData
    call handleCmdEnd
    return
    
cmd0x20Custom ;Write ranges+invert
    movff POSTINC0, WREG ;Dummy read
    
    ;SXmax
    movlw 0x00
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SXmin
    movlw 0x01
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SYmax
    movlw 0x02
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;SYmin
    movlw 0x03
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CXmax
    movlw 0x04
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CXmin
    movlw 0x05
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CYmax
    movlw 0x06
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;CYmin
    movlw 0x07
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    ;Invert axes
    movlw 0x08
    movwf EEADR
    movff POSTINC0, EEDATA
    call EEPROMWrite
    
    call handleCmdEnd
    
    reset

calibrateADCCustom
    subwf ADRESH, 0
    bc gtCalibrateADCCustom ;If stick > origin go to gtCalibrateADCCustom
    addlw 0x80
    btfss STATUS, 0
    clrf WREG
    return
gtCalibrateADCCustom
    addlw 0x80
    btfsc STATUS, 0
    setf WREG
    return
    
calibrateADCTriggerCustom
    subwf ADRESH, 0
    bc gtCalibrateADCTriggerCustom ;If trigger > origin go to gtCalibrateADCTriggerCustom
    addlw 0x00
    btfss STATUS, 0
    clrf WREG
    return
gtCalibrateADCTriggerCustom
    addlw 0x00
    btfsc STATUS, 0
    setf WREG
    return
    
getADCCustom
    incf curADInput, 1, 0
    movff curADInput, WREG
    decf WREG, 0
    bz getADC0Custom
    decf WREG, 0
    bz getADC1Custom
    decf WREG, 0
    bz getADC2Custom
    decf WREG, 0
    bz getADC3Custom
    decf WREG, 0
    bz getADC4Custom
    decf WREG, 0
    bz getADC5Custom
    return
    
getADC0Custom
    lfsr FSR2, 0x100 ;SX
    movff 0x56, WREG
    call calibrateADCCustom
    movff WREG, FSR2L
    movff INDF2, 0x50
    
    movlw 0x0D
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC1Custom
    lfsr FSR2, 0x200 ;SY
    movff 0x57, WREG
    call calibrateADCCustom
    movff WREG, FSR2L
    movff INDF2, 0x51
    movlw 0x01
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC2Custom
    lfsr FSR2, 0x300 ;CX
    movff 0x58, WREG
    call calibrateADCCustom
    movff WREG, FSR2L
    movff INDF2, 0x52
    movlw 0x05
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC3Custom
    lfsr FSR2, 0x400 ;CY
    movff 0x59, WREG
    call calibrateADCCustom
    movff WREG, FSR2L
    movff INDF2, 0x53
    movlw 0x3D
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC4Custom
    movff 0x5a, WREG
    call calibrateADCTriggerCustom
    movff WREG, 0x54 ;R
    movlw 0x41
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    return
    
getADC5Custom
    movff 0x5b, WREG
    call calibrateADCTriggerCustom
    movff WREG, 0x55 ;L
    movlw 0x09
    movwf ADCON0
    bcf PIR1, 6 ;ADIF = 0
    bsf ADCON0, 1
    ;bcf ADStatus, 0, 0
    return

readButtonsAndDebounceCustom
    btfss PIR5, 0 ;If TMR4IF isn't set return
    return
    
    bcf PIR5, 0; TMR4IF = 0
    
    ;Increase timers
    incf buttonsTimerA, 1, 0 ;Access bank
    incf buttonsTimerB, 1, 0 ;Access bank
    incf buttonsTimerX, 1, 0 ;Access bank
    incf buttonsTimerY, 1, 0 ;Access bank
    incf buttonsTimerZ, 1, 0 ;Access bank
    incf buttonsTimerS, 1, 0 ;Access bank
    incf buttonsTimerRT, 1, 0 ;Access bank
    incf buttonsTimerLT, 1, 0 ;Access bank
    incf buttonsTimerDU, 1, 0 ;Access bank
    incf buttonsTimerDD, 1, 0 ;Access bank
    incf buttonsTimerDR, 1, 0 ;Access bank
    incf buttonsTimerDL, 1, 0 ;Access bank
    
    
    movlw 0x00
    btfss PORTC, 1 ;Start
    bsf WREG, 4
    btfss PORTA, 6 ;Y
    bsf WREG, 3
    btfss PORTA, 7 ;X
    bsf WREG, 2
    btfss PORTA, 5 ;B
    bsf WREG, 1
    btfss PORTA, 4 ;A
    bsf WREG, 0
    xorwf buttonsPrevState0, 1, 0 ;buttonsPrevState0 = WREG ^ buttonsPrevState0
    movff buttonsPrevState0, buttonsMixState0
    movwf buttonsPrevState0 ;buttonsPrevState0 = WREG
    
    movlw 0x00
    btfss PORTC, 5 ;LT
    bsf WREG, 6
    btfss PORTC, 2 ;RT
    bsf WREG, 5
    btfss PORTC, 0 ;Z
    bsf WREG, 4
    btfss PORTC, 6 ;DU
    bsf WREG, 3
    btfss PORTC, 7 ;DD
    bsf WREG, 2
    btfss PORTB, 0 ;DR
    bsf WREG, 1
    btfss PORTB, 1 ;DL
    bsf WREG, 0
    xorwf buttonsPrevState1, 1, 0 ;buttonsPrevState1 = WREG ^ buttonsPrevState1
    movff buttonsPrevState1, buttonsMixState1
    movwf buttonsPrevState1 ;buttonsPrevState1 = WREG
    bsf buttonsCurState1, 7, 0 ;MSB always high
    
    ;Reset timer if the button has changed state
    btfsc buttonsMixState0, 0
    clrf buttonsTimerA, 0 ;Access bank
    btfsc buttonsMixState0, 1
    clrf buttonsTimerB, 0 ;Access bank
    btfsc buttonsMixState0, 2
    clrf buttonsTimerX, 0 ;Access bank
    btfsc buttonsMixState0, 3
    clrf buttonsTimerY, 0 ;Access bank
    btfsc buttonsMixState0, 4
    clrf buttonsTimerS, 0 ;Access bank
    
    btfsc buttonsMixState1, 0
    clrf buttonsTimerDL, 0 ;Access bank
    btfsc buttonsMixState1, 1
    clrf buttonsTimerDR, 0 ;Access bank
    btfsc buttonsMixState1, 2
    clrf buttonsTimerDD, 0 ;Access bank
    btfsc buttonsMixState1, 3
    clrf buttonsTimerDU, 0 ;Access bank
    btfsc buttonsMixState1, 4
    clrf buttonsTimerZ, 0 ;Access bank
    btfsc buttonsMixState1, 5
    clrf buttonsTimerRT, 0 ;Access bank
    btfsc buttonsMixState1, 6
    clrf buttonsTimerLT, 0 ;Access bank
    
    
    ;Update the state of buttons (we check if bit 3 is set => The timer reached 8
    btfss buttonsTimerA, 3, 0
    bra endTimerACustom
    decf buttonsTimerA, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 0, 0
    btfss PORTA, 4 ;A
    bsf buttonsCurState0, 0, 0
endTimerACustom
    
    btfss buttonsTimerB, 3, 0
    bra endTimerBCustom
    decf buttonsTimerB, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 1, 0
    btfss PORTA, 5 ;B
    bsf buttonsCurState0, 1, 0
endTimerBCustom
    
    btfss buttonsTimerX, 3, 0
    bra endTimerXCustom
    decf buttonsTimerX, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 2, 0
    btfss PORTA, 7 ;X
    bsf buttonsCurState0, 2, 0
endTimerXCustom
    
    btfss buttonsTimerY, 3, 0
    bra endTimerYCustom
    decf buttonsTimerY, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 3, 0
    btfss PORTA, 6 ;Y
    bsf buttonsCurState0, 3, 0
endTimerYCustom
    
    btfss buttonsTimerS, 3, 0
    bra endTimerSCustom
    decf buttonsTimerS, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState0, 4, 0
    btfss PORTC, 1 ;S
    bsf buttonsCurState0, 4, 0
endTimerSCustom
    
    btfss buttonsTimerDL, 3, 0
    bra endTimerDLCustom
    decf buttonsTimerDL, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 0, 0
    btfss PORTB, 1 ;DL
    bsf buttonsCurState1, 0, 0
endTimerDLCustom
    
    btfss buttonsTimerDR, 3, 0
    bra endTimerDRCustom
    decf buttonsTimerDR, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 1, 0
    btfss PORTB, 0 ;DR
    bsf buttonsCurState1, 1, 0
endTimerDRCustom
    
    btfss buttonsTimerDD, 3, 0
    bra endTimerDDCustom
    decf buttonsTimerDD, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 2, 0
    btfss PORTC, 7 ;DD
    bsf buttonsCurState1, 2, 0
endTimerDDCustom
    
    btfss buttonsTimerDU, 3, 0
    bra endTimerDUCustom
    decf buttonsTimerDU, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 3, 0
    btfss PORTC, 6 ;DU
    bsf buttonsCurState1, 3, 0
endTimerDUCustom
    
    btfss buttonsTimerZ, 3, 0
    bra endTimerZCustom
    decf buttonsTimerZ, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 4, 0
    btfss PORTC, 0 ;Z
    bsf buttonsCurState1, 4, 0
endTimerZCustom
    
    btfss buttonsTimerRT, 3, 0
    bra endTimerRTCustom
    decf buttonsTimerRT, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 5, 0
    btfss PORTC, 2 ;RT
    bsf buttonsCurState1, 5, 0
endTimerRTCustom
    
    btfss buttonsTimerLT, 3, 0
    bra endTimerLTCustom
    decf buttonsTimerLT, 1, 0 ;buttonsTimer = 7
    bcf buttonsCurState1, 6, 0
    btfss PORTC, 5 ;LT
    bsf buttonsCurState1, 6, 0
endTimerLTCustom
    
    return ;readButtonsAndDebounceCustom


    end
