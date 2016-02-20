#include <PCD8544.h>

static PCD8544 lcd(9, 8, 7, 6, 5);

#define VERSION "0.1"
#define BANNERDELAY 200

#define MOTORENABLE     4
#define MOTORSTEP       2
#define MOTORDIRECTION  3
#define STEPDELAY       5000

#define SWITCHLEFT    10
#define SWITCHMIDDLE  11
#define SWITCHRIGHT   12

#define DEGREESPERSTEP 1.8

#define DIAL  A0

int direction;

#define INTERVALDISPLAY 500
uint32_t timeoutDisplay;

int16_t stepCount;

#define INTERVALMOTOR 500
uint32_t timeoutMotor;


//enum {FONT7,FONT16,FONTLARGENUMBERS,TIMES24};

void setup() {
    Serial.begin(9600);
    pinMode(MOTORENABLE,OUTPUT);
    pinMode(MOTORSTEP,OUTPUT);
    pinMode(MOTORDIRECTION,OUTPUT);

    pinMode(SWITCHLEFT,INPUT);
    pinMode(SWITCHMIDDLE,INPUT);
    pinMode(SWITCHRIGHT,INPUT);

    pinMode(DIAL,INPUT);

    // add pullups
    digitalWrite(SWITCHLEFT,HIGH);
    digitalWrite(SWITCHMIDDLE,HIGH);
    digitalWrite(SWITCHRIGHT,HIGH);

    lcd.begin(84, 48);
    lcd.fontSelect(FONT16);
    lcd.setCursor(5, 0);
    lcd.print("Engraver");
    lcd.setCursor(12,2);
    lcd.print("Spindle");
    lcd.fontSelect(FONT7);
    lcd.setCursor(7, 4);
    lcd.print("Designed for");
    lcd.setCursor(14, 5);
    lcd.print("Josh Kline");
    delay(BANNERDELAY);
    lcd.fontSelect(FONT7);
    lcd.setCursor(7, 4);
    lcd.print("  Firmware  ");
    lcd.setCursor(12, 5);
    lcd.print("Version ");
    lcd.print(VERSION);
    delay(BANNERDELAY);

    direction = 0;

    digitalWrite(MOTORENABLE,LOW);
    digitalWrite(MOTORDIRECTION,direction);

    timeoutDisplay = 0;
    timeoutMotor = 0;
    stepCount = 0;

    lcd.clear();
}

int dialRead() {
  return map(analogRead(DIAL),0,1023,0,200);
}

float dialScale() {
  return dialRead() * DEGREESPERSTEP;
}


void spin(uint16_t steps) {
    for (uint16_t i = 0;i < steps;i++) {
      digitalWrite(MOTORSTEP,LOW);
      delayMicroseconds(STEPDELAY);
      digitalWrite(MOTORSTEP,HIGH);
      delayMicroseconds(STEPDELAY);
    }
    stepCount += (direction?-steps:steps);
}

float position() {
  return stepCount * DEGREESPERSTEP;
}

void loop() {
    byte r;    

    if (millis() > timeoutDisplay) {
      lcd.fontSelect(FONTLARGENUMBERS);
      lcd.setCursor(0, 0);
      lcd.print(position(),1);
      lcd.fontSelect(TIMES24);
      lcd.print("  ");

      lcd.setCursor(0, 3);
      lcd.print(dialScale(),1);
      lcd.fontSelect(TIMES24);
      lcd.print(" ");

      lcd.setCursor(50, 4);
      lcd.fontSelect(FONT7);
      lcd.print(direction?"right":"left ");

      timeoutDisplay = millis() + INTERVALDISPLAY;
    }

/*
    if (millis() > timeoutMotor) {
      timeoutMotor = millis() + INTERVALMOTOR;
    }
*/

    if (digitalRead(SWITCHMIDDLE) == LOW) {
      stepCount = 0;
      digitalWrite(MOTORENABLE,HIGH);
      while (digitalRead(SWITCHMIDDLE) == LOW) {};
      digitalWrite(MOTORENABLE,LOW);
    }
      
    if (digitalRead(SWITCHRIGHT) == LOW) {
      direction = 1;
      digitalWrite(MOTORDIRECTION,direction);
      spin(dialRead());
      delay(10);
      while (digitalRead(SWITCHRIGHT) == LOW) {};
    }

    if (digitalRead(SWITCHLEFT) == LOW) {
      direction = 0;
      digitalWrite(MOTORDIRECTION,direction);
      spin(dialRead());
      delay(10);
      while (digitalRead(SWITCHLEFT) == LOW) {};
    }
       
}
