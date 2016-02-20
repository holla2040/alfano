#include "WProgram.h"
#include <PCD8544.h>

static PCD8544 lcd(9, 8, 7, 6, 5);

#define VERSION "0.1"
#define BANNERDELAY 2000

#define MOTORENABLE     4
#define MOTORSTEP       2
#define MOTORDIRECTION  3
#define STEPDELAY       250

#define SWITCHLEFT    10
#define SWITCHMIDDLE  11
#define SWITCHRIGHT   12

#define STEPSPERDEGREE 4.4444444

#define DIAL  A0

int direction;
int divisions;
unsigned int stepsPerDivision;

#define INTERVALDISPLAY 500
uint32_t timeoutDisplay;

int16_t stepCount;

int8_t tick;

#define INTERVALMOTOR 500
uint32_t timeoutIdle;

#define TIMEOUTIDLE 600000L


//enum {FONT7,FONT16,FONTLARGENUMBERS,TIMES24};

void divisionsSet();
void idleKick();

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
    lcd.setCursor(17, 0);
    lcd.print("Alfano");
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

    digitalWrite(MOTORENABLE,HIGH);
    digitalWrite(MOTORDIRECTION,direction);

    timeoutDisplay = 0;
    stepCount = 0;

    lcd.clear();
    divisions = 1;
    divisionsSet();

    timeoutIdle = TIMEOUTIDLE;
}

int dialRead() {
  return map(analogRead(DIAL),0,1023,1,60);
}

void spin(uint16_t steps) {
    for (uint16_t i = 0;i < steps;i++) {
      digitalWrite(MOTORSTEP,LOW);
      delayMicroseconds(STEPDELAY);
      digitalWrite(MOTORSTEP,HIGH);
      delayMicroseconds(STEPDELAY);
    }
    stepCount += (direction?-steps:steps);
    idleKick();
}

void divisionsUpdate() {
    lcd.fontSelect(TIMES24);
    lcd.setCursor(0, 3);
    lcd.print(divisions);
    lcd.print("  ");
}

void idleKick() {
    timeoutIdle = millis() + TIMEOUTIDLE;
}

void tickCheck() {
  if (abs(tick) == divisions) { 
    tick = 0;
  }
}


void loop() {
    byte r;    
    uint32_t t;

    if (millis() > timeoutDisplay) {
      divisionsUpdate();

      lcd.fontSelect(FONTLARGENUMBERS);
      lcd.setCursor(0, 0);
      lcd.print(tick);
      lcd.fontSelect(TIMES24);
      lcd.print("/");
      lcd.fontSelect(FONTLARGENUMBERS);
      lcd.print(divisions - abs(tick));
      lcd.fontSelect(TIMES24);
      lcd.print("  ");

      timeoutDisplay = millis() + INTERVALDISPLAY;
    }

    if (digitalRead(SWITCHLEFT) == LOW) {
      direction = 0;
      digitalWrite(MOTORDIRECTION,direction);
      spin(stepsPerDivision);
      tick--;
      t = millis() + 1000;
      while (digitalRead(SWITCHLEFT) == LOW) {
        if (millis() > t) {
          spin(stepsPerDivision);
          tick--;
        }
      };
      if (millis() > t) {
        tick = tick % divisions;
        lcd.clear();
      }
      delay(100);
      tickCheck();
    }

    if (digitalRead(SWITCHMIDDLE) == LOW) {
      stepCount = 0;
      tick = 0;
      digitalWrite(MOTORENABLE,LOW);
      while (digitalRead(SWITCHMIDDLE) == LOW) {
        divisionsSet();
      };
      digitalWrite(MOTORENABLE,HIGH);
      idleKick();
      delay(100);
    }
      
    if (digitalRead(SWITCHRIGHT) == LOW) {
      direction = 1;
      digitalWrite(MOTORDIRECTION,direction);
      spin(stepsPerDivision);
      tick++;
      t = millis() + 1000;
      while (digitalRead(SWITCHRIGHT) == LOW) {
        if (millis() > t) {
          spin(stepsPerDivision);
          tick++;
        }
      };
      if (millis() > t) {
        tick = tick % divisions;
        lcd.clear();
      }
      delay(100);
      tickCheck();
    }


    if (millis() > timeoutIdle) {
      digitalWrite(MOTORENABLE,LOW);
    }
       
}

void divisionsSet() {
    divisions = dialRead();
    if (divisions < 1) { 
      divisions = 1;
    }
    stepsPerDivision = STEPSPERDEGREE * 360 / divisions;

    divisionsUpdate();
}
