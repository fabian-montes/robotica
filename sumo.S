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

CONFIG FOSC = INTOSCIO, WDTE = OFF, PWRTE = ON, MCLRE = OFF, BOREN = OFF, LVP = OFF

; mapeado de pines
IR_RIGHT EQU 5
IR_LEFT EQU 6
TRIG EQU 7
ECHO EQU 8
IN1 EQU 1
IN2 EQU 2
IN3 EQU 3
IN4 EQU 4
LED EQU 1

; asignacion de memoria
FLAG_REG EQU 0x21

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
    GOTO LOOP

LOOP:
    GOTO $

END RESET_VECTOR