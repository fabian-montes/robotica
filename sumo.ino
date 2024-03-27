/*
Informacion
Proyecto: minisumo
Autor:    Fabian Marquez Montes
          Meyali Diaz Infante
Fecha:    26-03-2024
Hardware: 1 HC-SR04, 2 CNY70, 1 L293D

Microcontrolador: Atmega328p
Compilador: ARDUINO - IDE
*/

// asignacion de pines
const unsigned int LED_ESTADO = 2;
const unsigned int IN1 = 4;
const unsigned int IN2 = 5;
const unsigned int IN3 = 6;
const unsigned int IN4 = 7;
const unsigned int ECHO = 8;
const unsigned int TRIG = 9;

// constantes de control
const unsigned int THRES_IR = 500;
const unsigned int THRES_DIST = 30;

// declaracion de funciones
void rutinaCombate();
void avanzar();
void girar();
bool detectaOponente();
bool detectaFrontera();

void setup() {
  Serial.begin(9600);
  // asignacion de I/O
  pinMode(LED_ESTADO, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  digitalWrite(LED_ESTADO, HIGH);
}

void loop(){
  rutinaCombate();
  delay(500);
}

void rutinaCombate() {
  // si detecta oponente y no frontera -> avanzar
  if(detectaOponente() && !detectaFrontera()) avanzar();
  else girar();
}

bool detectaFrontera() {
  // lectura de sensor analogico [0, 1023]
  unsigned int LECTURA_IR_IZQUIERDO = analogRead(A0);
  unsigned int LECTURA_IR_DERECHO = analogRead(A1);
  return LECTURA_IR_IZQUIERDO < THRES_IR || LECTURA_IR_DERECHO < THRES_IR;
}

bool detectaOponente() {
  // enviar pulso de activacion
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  // d es la distancia en cm
  long d = pulseIn(ECHO, HIGH) / 59;
  return d < THRES_DIST; 
}

void girar() {
  // m1 avanza, m2 retorcede
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

void avanzar() {
  // ambos motores avanzan
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}