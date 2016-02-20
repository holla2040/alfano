TARGET                  = engraverSpindle
MCU                     = atmega328p
#MCU                    = atmega1280
#MCU                    = atmega2560
DEVICE_FILE				= ttyUSB0
#DEVICE_FILE 	        = ttyACM0

CONSOLE_BAUDRATE    	= 9600
AVRDUDE_ARD_BAUDRATE    = 57600
#AVRDUDE_ARD_BAUDRATE   = 115200

ARDUINO_DIR             = /opt/arduino
AVR_TOOLS_PATH          = /usr/bin
AVRDUDE_ARD_PROGRAMMER  = stk500v1
AVRDUDE                 = /opt/arduino/hardware/tools/avrdude
                                            
F_CPU                   = 16000000
ARDUINO_PORT            = /dev/$(DEVICE_FILE)
                                            
ARDUINO_LIBS            = Wire Wire/utility
                                            
include ./Arduino.mk

con:
	rm -rf /var/lock/LCK..$(DEVICE_FILE)
	microcom -p $(ARDUINO_PORT) -s $(CONSOLE_BAUDRATE)

run: all
	/home/holla/arduino-1.6.5/hardware/tools/avr/bin/avrdude -C/home/holla/arduino-1.6.5/hardware/tools/avr/etc/avrdude.conf -v -V -patmega328p -carduino -P/dev/ttyUSB0 -b57600 -D -Uflash:w:build-cli/engraverSpindle.hex:i
