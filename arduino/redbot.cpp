/***********************************************************************
 * Exp3_Turning -- RedBot Experiment 3
 * 
 * Explore turning with the RedBot by controlling the Right and Left motors
 * separately.
 * 
 * Hardware setup:
 * This code requires only the most basic setup: the motors must be
 * connected, and the board must be receiving power from the battery pack.
 * 
 * 23 Sept 2013 N. Seidle/M. Hord
 * 04 Oct 2014 B. Huang
 ***********************************************************************/
#include <Arduino.h>
#include <RedBot.h>  // This line "includes" the library into your sketch.

RedBotMotors motors; // Instantiate the motor control object.

// Create a couple of constants for our pins.
const int buzzerPin = 9;
const int buttonPin = 12;

void action();

void forward() {
  motors.rightMotor(150);
  motors.leftMotor(-150);
  delay(1200);
  motors.brake();
  delay(900);
}

void backward() {
  motors.rightMotor(-150);
  motors.leftMotor(150);
  delay(1200);
  motors.brake();
  delay(900);
}

void left() {
  motors.leftMotor(100);    // Left motor CCW at 80
  motors.rightMotor(100);   // Right motor CW at 200
  delay(800);
  motors.brake();
  delay(900);
}

void right() {
  motors.leftMotor(-100);  // Left motor CCW at 200
  motors.rightMotor(-100);   // Right motor CW at 80
  delay(800);
  motors.brake();
  delay(900);
}


void spin() {
  motors.leftMotor(-200);  // Left motor CCW at 200
  motors.rightMotor(-200);   // Right motor CW at 80
  delay(1800);
  motors.brake();
  delay(900);
}


void shake() {
  int pa = 200;
  for (int i=0; i<10; i++) {
    motors.leftMotor(pa);
    motors.rightMotor(pa);
    delay(100);
    pa *= -1;
  }
  motors.brake();
  delay(900);
}


void wiggle() {
  for (int i=0; i<5; i++) {
    motors.leftMotor(-200);  // Left motor CCW at 200
    motors.rightMotor(80);   // Right motor CW at 80
    delay(200);
    motors.leftMotor(-80);  // Left motor CCW at 200
    motors.rightMotor(200);   // Right motor CW at 80
    delay(200);
  }
  motors.brake();
  delay(900);
}


void beep() {
    tone(buzzerPin, 1000);   // Play a 1kHz tone on the pin number held in
    delay(125);   // Wait for 125ms. 
    noTone(buzzerPin);   // Stop playing the tone.

    tone(buzzerPin, 2000);  // Play a 2kHz tone on the buzzer pin
    delay(500);   // delay for 1000 ms (1 second)
    noTone(buzzerPin);       // Stop playing the tone.
}


void sing() {
  tone(buzzerPin, 1000); delay(125); noTone(buzzerPin);
  tone(buzzerPin, 2000); delay(300); noTone(buzzerPin);
  delay(100);
  tone(buzzerPin, 2000); delay(125); noTone(buzzerPin);
  tone(buzzerPin, 1000); delay(300); noTone(buzzerPin);
  delay(100);
  tone(buzzerPin, 1000); delay(125); noTone(buzzerPin);
  tone(buzzerPin, 2000); delay(300); noTone(buzzerPin);
  delay(100);
}

#include "hook.cpp"

void setup()
{
  pinMode(buttonPin, INPUT_PULLUP); // configures the button as an INPUT
  pinMode(buzzerPin, OUTPUT);  // configures the buzzerPin as an OUTPUT
  tone(buzzerPin, 2000); delay(300); noTone(buzzerPin);
  delay(100);
}


void loop()
{ 
  if ( digitalRead(buttonPin) == LOW ) // if the button is pushed (LOW)
  { 
    action();
  }
  else  // otherwise, do this.
  { 
  }
}
