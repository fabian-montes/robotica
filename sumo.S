; Informacion
; Proyecto: minisumo
; Autor:    Fabian Marquez Montes
; Fecha:    27-03-2024
;
; Hardware: 1 HC-SR04, 2 CNY70, 1 L293D
;
; Microcontrolador: PIC16F628A
; Compilador: MPLAB XC8 C Compiler, V2.35
; pic-as -mcpu=16F628A -Wa,-a -Wl,-pMainFunc=0h -o outdir/out.hex sumo.S

PROCESSOR 16F628A
#include <xc.inc>

PSECT MainFunc, global, class=CODE, delta=2
global RESET_VECTOR

CONFIG FOSC = INTOSCIO, WDTE = OFF, PWRTE = OFF, MCLRE = OFF, BOREN = OFF, LVP = OFF

; mapeado de pines
; PORTA
IR_RIGHT EQU 0
IR_LEFT EQU 1

; PORTB
PUSH EQU 0
TRIG EQU 1
ECHO EQU 2
LED EQU 3
IN1 EQU 4
IN2 EQU 5
IN3 EQU 6
IN4 EQU 7

; asignacion de memoria
FLAG_REG EQU 0x21
AUX EQU 0x22

; definicion de bits
ACTIVE EQU 0
BORDER EQU 1
ENEMY EQU 2

; instruccion de reinicio
ORG 0x00
RESET_VECTOR:
    GOTO SETUP

ORG 0x04
INTERRUPT:
    RETFIE

SETUP:
    ; bank1
    BCF RP1
    BSF RP0

    MOVLW 0b00000000
    MOVWF TRISB
    MOVLW 0b00000000
    MOVWF TRISA

    ; bank0
    BCF RP1
    BCF RP0

    CLRF PORTA
    CLRF PORTB
    BSF PORTB, LED
    GOTO LOOP

LOOP:
    GOTO LOOP

END RESET_VECTOR