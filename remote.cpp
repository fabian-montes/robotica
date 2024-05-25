/*
  Informacion
  Proyecto: minisumo control remoto
  Autor:    Fabian Marquez Montes
  Fecha:    Mayo 2024

  Hardware: L293D

  Microcontrolador: ESP WROOM 32
  Compilador: Espressif

  Recursos
  https://github.com/espressif/arduino-esp32/blob/master/libraries/WebServer/src/WebServer.h
  https://github.com/espressif/arduino-esp32/blob/master/libraries/WiFi/examples/WiFiAccessPoint/WiFiAccessPoint.ino
  https://github.com/espressif/arduino-esp32/blob/master/cores/esp32/Client.h
  https://www.upesy.com/blogs/tutorials/esp32-pinout-reference-gpio-pins-ultimate-guide#
*/

// no modificar orden de librerias
#include <WiFi.h>
#include <WiFiClient.h>
#include <WebServer.h>
#include <ESPmDNS.h>

const char *ssid = "";
const char *password = "";

WebServer server(80);

#define LED 23
#define MA1 26
#define MA2 27
#define MB1 32

void handleRoot() {
    const char *webpage = R"====(<!doctypehtml><meta content="width=device-width,initial-scale=1,user-scalable=0"name=viewport><style>body{margin:0;padding:0;width:100%;height:100vh;display:flex;justify-content:space-around;align-items:center}input[type=button]{color:#fff;background-color:#dc143c;border:5px solid #000;text-transform:uppercase;aspect-ratio:1;width:25%;border-radius:50%;font-size:1.8em}input[type=button]:active{background-color:red}p{text-transform:uppercase;text-align:center;display:none;color:#fff}@media (max-width:450px){p{display:block}input[type=button]{display:none}body{background-color:#000}}</style><p>Gira el dispositivo para continuar</p><input id=move type=button value=Avanzar> <input id=spin type=button value=Girar><script>function sendMsg(msg) {
        const Http = new XMLHttpRequest();
        Http.open('GET', msg);
        Http.send();
        
        Http.onreadystatechange = (e) => {
            console.log(Http.status);
            //console.log(msg);
            //console.log(Http.ResponseText);
        }
    }

    document.querySelectorAll('input').forEach((button) => {
        button.addEventListener('mouseup', () => {
            sendMsg('stop');
        });
        button.addEventListener('touchend', () => {
            sendMsg('stop');
        });
        button.addEventListener('mousedown', () => {
            sendMsg(button.id);
        });
        button.addEventListener('touchstart', () => {
            sendMsg(button.id);
        });
    });</script>)====";

    server.send(200, "text/html", webpage);
}
void stop() {
    Serial.println("stop...");
    digitalWrite(MA1, LOW);
    digitalWrite(MA2, LOW);
    digitalWrite(MB1, LOW);
    server.send(200, "text/plain", "stop");
}
void move() {
    Serial.println("move...");
    digitalWrite(MA2, LOW);
    digitalWrite(MA1, HIGH);
    digitalWrite(MB1, HIGH);
    server.send(200, "text/plain", "move");
}
void spin() {
    Serial.println("spin..");
    digitalWrite(MA1, LOW);
    digitalWrite(MA2, HIGH);
    digitalWrite(MB1, HIGH);  
    server.send(200, "text/plain", "spin");
}

void setup(void) {
    pinMode(LED, OUTPUT);
    pinMode(MA1, OUTPUT);
    pinMode(MA2, OUTPUT);
    pinMode(MB1, OUTPUT);

    digitalWrite(LED, LOW);
    digitalWrite(MA1, LOW);
    digitalWrite(MA2, LOW);
    digitalWrite(MB1, LOW);  

    Serial.begin(115200);
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    Serial.println("");

    // esperar conexion
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.print("Connected to ");
    Serial.println(ssid);
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());

    if (MDNS.begin("esp32")) {
    Serial.println("MDNS responder started");
    }

    server.on("/", handleRoot);
    server.on("/move", move);
    server.on("/stop", stop);
    server.on("/spin", spin);

    server.begin();
    Serial.println("HTTP server started");
}

void loop(void) {
    server.handleClient();
    delay(2); // permitir que el cpu realice otras tareas
}