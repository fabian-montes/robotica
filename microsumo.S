; Informacion
; Proyecto: minisumo
; Autor:    Fabian Marquez Montes
; Fecha:    Marzo 2024
;
; Hardware: 4 PT333-3C/3B, 2 CNY70, 1 L293D
;
; Microcontrolador: PIC16F628A
; Compilador: MPLAB XC8 C Compiler, V2.35
; pic-as -mcpu=16F628A -Wa,-a -Wl,-pMainFunc=0h -o outdir/out.hex microsumo.S

PROCESSOR 16F628A
#include <xc.inc>

PSECT MainFunc, global, class=CODE, delta=2
global RESET_VECTOR

CONFIG FOSC = INTOSCIO, WDTE = OFF, PWRTE = OFF, MCLRE = OFF, BOREN = OFF, LVP = OFF

; mapeado de pines
#define IR_BACK BANKMASK(PORTA), 6
#define IR_LEFT BANKMASK(PORTA), 7

#define PUSH BANKMASK(PORTB), 0
#define IR_FRONT BANKMASK(PORTB), 1
#define IR_RIGHT BANKMASK(PORTB), 2
#define LED BANKMASK(PORTB), 3
#define IN1 BANKMASK(PORTB), 4
#define IN2 BANKMASK(PORTB), 5
#define IN3 BANKMASK(PORTB), 6
#define IN4 BANKMASK(PORTB), 7

; asignacion de memoria
FLAG_REG EQU 0x21
COUNTER EQU 0x22
AUX EQU 0x23

; definicion de bits
IS_ACTIVE EQU 0
BORDER EQU 1
ENEMY EQU 2

; instruccion de reinicio
ORG 0x00
RESET_VECTOR:
    GOTO SETUP

ORG 0x04
INTERRUPT:
    BTFSC PUSH
    GOTO $-1

    BTFSS FLAG_REG, IS_ACTIVE
    CALL ACTIVATE

    BTFSC FLAG_REG, IS_ACTIVE
    CALL DEACTIVATE

    ; negar is_active
    MOVLW 0x01
    XORWF FLAG_REG, 1

    BCF INTF
    RETFIE

DEACTIVATE:
    BSF LED
    CALL STOP
    RETURN

ACTIVATE:
    MOVLW 3 ; secs
    MOVWF COUNTER
ONE_SEC:
    BCF LED
    MOVLW 7
    CALL DELAY
    
    BSF LED
    MOVLW 3
    CALL DELAY
    DECFSZ COUNTER
    GOTO ONE_SEC

    BCF LED
    RETURN

SETUP:
    BCF RP1
    CLRF PORTB
    CLRF PORTA
    CLRF FLAG_REG
    
    BSF RP0 ; bank1
    CLRWDT
    BSF OSCF
    MOVLW 0b11000111 ; notRBPU INTEDG
    MOVWF OPTION_REG
    MOVLW 0b10010000 ; GIE, INTE
    MOVWF INTCON
    MOVLW 0b00000101
    MOVWF TRISB
    MOVLW 0b00000111
    MOVWF TRISA

    BCF RP0 ; bank0
    ; two common reference comparators with outputs CM<2:0>=110
    MOVLW 0b00000110
    MOVWF CMCON
    BSF LED
    GOTO LOOP

LOOP:
    BTFSS FLAG_REG, IS_ACTIVE
    GOTO LOOP ; si no esta activo

    ; revisar estado sensores
    CALL DETECTS_OPPONENT
    CALL DETECTS_BORDER

    ; toma de decisiones

    MOVLW 1
    CALL DELAY
    GOTO LOOP

FORWARD:
    BSF IN1
    BCF IN2
    BSF IN3
    BCF IN4
    RETURN

BACKWARD:
    BCF IN1
    BSF IN2
    BCF IN3
    BSF IN4
    RETURN

SPIN_LEFT:
    BSF IN1
    BCF IN2
    BCF IN3
    BSF IN4
    RETURN

SPIN_RIGHT:
    BCF IN1
    BSF IN2
    BSF IN3
    BCF IN4
    RETURN

STOP:
    BCF IN1
    BCF IN2
    BCF IN3
    BCF IN4
    RETURN

DETECTS_OPPONENT:

    RETURN

DETECTS_BORDER:
    BCF FLAG_REG, BORDER

    BTFSS C1OUT
    BSF FLAG_REG, BORDER

    BTFSS C2OUT
    BSF FLAG_REG, BORDER
    
    RETURN

DELAY:
    MOVWF AUX
    BSF RP0 ; bank1
    CLRWDT
    MOVLW 0b11000111
    MOVWF OPTION_REG
    BCF RP0 ; bank0
SUB_DELAY:
    CLRF TMR0
    BCF T0IF
    BTFSS T0IF
    GOTO $-1
    DECFSZ AUX
    GOTO SUB_DELAY

    BSF RP0 ; bank1
    CLRWDT
    MOVLW 0b11000011
    MOVWF OPTION_REG
    BCF RP0 ; bank0
    RETURN

END RESET_VECTOR