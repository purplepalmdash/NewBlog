---
layout: post
title: "Arduino Performance"
date: 2014-10-29 10:43
comments: true
categories: embedded
---
### Program Storage
Classical Blink program:    

```c
/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.

  Most Arduinos have an on-board LED you can control. On the Uno and
  Leonardo, it is attached to digital pin 13. If you're unsure what
  pin the on-board LED is connected to on your Arduino model, check
  the documentation at http://arduino.cc

  This example code is in the public domain.

  modified 8 May 2014
  by Scott Fitzgerald
 */


// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin 13 as an output.
  pinMode(13, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);              // wait for a second
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);              // wait for a second
}

```
Compilation size:     

```
Binary sketch size: 1,082 bytes (of a 32,256 byte maximum)

```
Comment the pinMode(13, OUTPUT), then the compilation size would be:    

```
Binary sketch size: 948 bytes (of a 32,256 byte maximum)

```
Since PB5 is the output pin for 13, One command for replacing pinMode():    

```
void setup() {
  // initialize digital pin 13 as an output.
  //pinMode(13, OUTPUT);
  bitSet(DDRB, 5);
}

```
Further:    

```
void loop() {
  //digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  bitSet(PINB, 5);
  delay(1000);              // wait for a second
  //digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  bitSet(PINB, 5);
  delay(1000);              // wait for a second
}
Binary sketch size: 680 bytes (of a 32,256 byte maximum)

```
Use bitSet() for reverse the bit, then the size will greatly reduced.    

Further reduction will consider replace the delay(1000) with an empty for() loop, which is listed as following:    

```
  //delay(1000);              // wait for a second
  for (int i=0; i<32000; i++);

```
The binary size is:     

```
Binary sketch size: 478 bytes (of a 32,256 byte maximum)

```
We could add following declaration:    

```
  for (volatile int i=0; i<32000; i++);

```
### Serial Communication
Origin serial communication source code:    

``` c
void setup()
{
  Serial.begin(9600);
  Serial.println("Hello World!");
}

void loop()
{
  // Do Nothing.
}

```
Size is:    

```
Binary sketch size: 2,034 bytes (of a 32,256 byte maximum)

```
Remove all of the functionality, then the size is:    

```
Binary sketch size: 472 bytes (of a 32,256 byte maximum)

```

Directly manuplate the serial port hardware:    

``` c
#define BAUD_RATE 9600
#define BAUD_RATE_DIVISOR (F_CPU/16/BAUD_RATE -1 )

void usart_putc(char c)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
}

void setup()
{
  //Serial.begin(9600);
  //Serial.println("Hello World!");
  UCSR0A = 0;
  UCSR0B = 1<<TXEN0;
  UCSR0C = 1<<UCSZ01 | 1<<UCSZ00;
  UBRR0 = BAUD_RATE_DIVISOR;
  usart_putc('!');
    usart_putc('m');
}

void loop()
{
  // Do Nothing.
}

```
Now the size is:    

```
Binary sketch size: 528 bytes (of a 32,256 byte maximum)

```
Add one function for output sentence:    

```
#define BAUD_RATE 9600
#define BAUD_RATE_DIVISOR (F_CPU/16/BAUD_RATE -1 )

void usart_putc(char c)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
}

void usart_puts(char *s)
{
  while(*s)
  {
    usart_putc(*s);
    s++;
  }
}

void setup()
{
  //Serial.begin(9600);
  //Serial.println("Hello World!");
  UCSR0A = 0;
  UCSR0B = 1<<TXEN0;
  UCSR0C = 1<<UCSZ01 | 1<<UCSZ00;
  UBRR0 = BAUD_RATE_DIVISOR;
  usart_puts("Hello, World!\n");
  //usart_putc('!');
  //usart_putc('m');
}

void loop()
{
  // Do Nothing.
}

```
The size changes to:    

```
Binary sketch size: 542 bytes (of a 32,256 byte maximum)

```
Add version for output integers:    

```
#define BAUD_RATE 9600
#define BAUD_RATE_DIVISOR (F_CPU/16/BAUD_RATE -1 )

void usart_putc(char c)
{
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
}

void usart_puts(char *s)
{
  while(*s)
  {
    usart_putc(*s);
    s++;
  }
}

void usart_puti(long i)
{
  char s[25];
  itoa(i, s, 10);
  usart_puts(s);
}

void setup()
{
  //Serial.begin(9600);
  //Serial.println("Hello World!");
  UCSR0A = 0;
  UCSR0B = 1<<TXEN0;
  UCSR0C = 1<<UCSZ01 | 1<<UCSZ00;
  UBRR0 = BAUD_RATE_DIVISOR;
  usart_puts("Hello, World!\n");
  usart_puti(1000);
  //usart_putc('!');
  //usart_putc('m');
}

void loop()
{
  // Do Nothing.
}

```
Because we called itoa(), so in this version the size will greatly improved to:   

```
Binary sketch size: 782 bytes (of a 32,256 byte maximum)

```

### SRAM
Edit the preference of Arduino, under the `/root/.arduino/preference.txt`:    

```
build.verbose=true

```
Then build and you will see the tmp file.   

Install following packages on Archlinux:    

```
$ sudo pacman -S avr-gcc
$ sudo pacman -S avr-gdb avrdude simavr avr-libc

```
Then you can use avr-size to view the generated elf file size:    

```
$ avr-size /tmp/build7485065177781002113.tmp/BareMinimum.cpp.elf
   text    data     bss     dec     hex filename
    472       0       9     481     1e1 /tmp/build7485065177781002113.tmp/BareMinimum.cpp.elf

```
Or more detailed:   

```
$ avr-size -C --mcu=atmega328p /tmp/build7485065177781002113.tmp/BareMinimum.cpp.elf
AVR Memory Usage
----------------
Device: atmega328p

Program:     472 bytes (1.4% Full)
(.text + .data + .bootloader)

Data:          9 bytes (0.4% Full)
(.data + .bss + .noinit)

```
Add  some definition of global variables:    

```
char c;
char msg[]="This is a message";
void setup() {
  // put your setup code here, to run once:
  c = msg[0];

```
Check the size:    

```
$ avr-size -C --mcu=atmega328p /tmp/build7485065177781002113.tmp/BareMinimum.cpp.elf
AVR Memory Usage
----------------
Device: atmega328p

Program:     498 bytes (1.5% Full)
(.text + .data + .bootloader)

Data:         28 bytes (1.4% Full)
(.data + .bss + .noinit)

```


### Use pgmspace
If we use pgmspace, then the source code would be:   

```
/*
 PROGMEM string demo
 How to store a table of strings in program memory (flash), 
 and retrieve them.

 Information summarized from:
 http://www.nongnu.org/avr-libc/user-manual/pgmspace.html

 Setting up a table (array) of strings in program memory is slightly complicated, but
 here is a good template to follow. 

 Setting up the strings is a two-step process. First define the strings.

*/

#include <avr/pgmspace.h>
prog_char string_0[] PROGMEM = "String 0";   // "String 0" etc are strings to store - change to suit.
prog_char string_1[] PROGMEM = "String 1";
prog_char string_2[] PROGMEM = "String 2";
prog_char string_3[] PROGMEM = "String 3";
prog_char string_4[] PROGMEM = "String 4";
prog_char string_5[] PROGMEM = "String 5";


// Then set up a table to refer to your strings.

PROGMEM const char *string_table[] = 	   // change "string_table" name to suit
{   
  string_0,
  string_1,
  string_2,
  string_3,
  string_4,
  string_5 };

char buffer[30];    // make sure this is large enough for the largest string it must hold

void setup()			  
{
  Serial.begin(9600);
}


void loop()			  
{
  /* Using the string table in program memory requires the use of special functions to retrieve the data.
     The strcpy_P function copies a string from program space to a string in RAM ("buffer"). 
     Make sure your receiving string in RAM  is large enough to hold whatever
     you are retrieving from program space. */


  for (int i = 0; i < 6; i++)
  {
    strcpy_P(buffer, (char*)pgm_read_word(&(string_table[i]))); // Necessary casts and dereferencing, just copy. 
    Serial.println( buffer );
    delay( 500 );
  }
}

```
Check the size:    

```
$ avr-size -C --mcu=atmega328p /tmp/build7485065177781002113.tmp/sketch_oct29b.cpp.elf
AVR Memory Usage
----------------
Device: atmega328p

Program:    2324 bytes (7.1% Full)
(.text + .data + .bootloader)

Data:        225 bytes (11.0% Full)
(.data + .bss + .noinit)

```
Replace back to ordinary conditions:    

```
/*
 PROGMEM string demo
 How to store a table of strings in program memory (flash), 
 and retrieve them.

 Information summarized from:
 http://www.nongnu.org/avr-libc/user-manual/pgmspace.html

 Setting up a table (array) of strings in program memory is slightly complicated, but
 here is a good template to follow. 

 Setting up the strings is a two-step process. First define the strings.

*/

char string_0[] = "String 0";   // "String 0" etc are strings to store - change to suit.
char string_1[] = "String 1";
char string_2[] = "String 2";
char string_3[] = "String 3";
char string_4[] = "String 4";
char string_5[] = "String 5";


// Then set up a table to refer to your strings.

const char *string_table[] = 	   // change "string_table" name to suit
{   
  string_0,
  string_1,
  string_2,
  string_3,
  string_4,
  string_5 };

char buffer[30];    // make sure this is large enough for the largest string it must hold

void setup()			  
{
  Serial.begin(9600);
}


void loop()			  
{
  /* Using the string table in program memory requires the use of special functions to retrieve the data.
     The strcpy_P function copies a string from program space to a string in RAM ("buffer"). 
     Make sure your receiving string in RAM  is large enough to hold whatever
     you are retrieving from program space. */


  for (int i = 0; i < 6; i++)
  {
    //strcpy_P(buffer, (char*)pgm_read_word(&(string_table[i]))); // Necessary casts and dereferencing, just copy. 
    strcpy(buffer, (char*)(&(string_table[i]))); // Necessary casts and dereferencing, just copy. 
    Serial.println( buffer );
    delay( 500 );
  }
}

```
Then the size would be:    

```
$ avr-size -C --mcu=atmega328p /tmp/build7485065177781002113.tmp/sketch_oct29c.cpp.elf
AVR Memory Usage
----------------
Device: atmega328p

Program:    2320 bytes (7.1% Full)
(.text + .data + .bootloader)

Data:        291 bytes (14.2% Full)
(.data + .bss + .noinit)


```

### Performance
Use Arduino for test the performance of Arduino:    

```
void setup()
{
  Serial.begin(9600);
  Serial.println("Arduino performance test begins now.");
}
extern volatile unsigned long timer0_millis;

void loop()
{
  unsigned long i = 0;
  unsigned long stop_time;
  
  stop_time= millis() + 1000;
  
  while(timer0_millis <stop_time) i++;
  
  Serial.print(i);
  Serial.println(" loops in one second.");
  while(1);
}

```
The result from the serial port:    

```
Arduino performance test begins now.
836912 loops in one second.

```
Test for digitalwrite():    

```
  while(timer0_millis <stop_time) 
  {
    digitalWrite(13, HIGH);
    digitalWrite(13, LOW);
    i++;
  }

```
Output:    

```
Arduino performance test begins now.
111198 loops in one second.

```
If we change the functionality into:    

```
  while(timer0_millis <stop_time) 
  {
    //digitalWrite(13, HIGH);
    //digitalWrite(13, LOW);
    bitSet(PORTB, 5);
    bitClear(PORTB, 5);
    i++;
  }

```
Then the performance result will be:    

```
Arduino performance test begins now.
691362 loops in one second.

```

### Slow Down CPU
We change the prescale clock frequency, thus we could get a power-saving mode, which will consume less power.    

```
/* Slow down the avr cpu speed*/
void setup()
{
  Serial.begin(9600);
  Serial.println("Normal serial communiation at 9600 bps");
  
  pinMode(13, OUTPUT);
  
  noInterrupts();  //disable interrupts temporarily
  CLKPR = 1<<CLKPCE;  // enable clock prescaler write sequence
  CLKPR = 8;  // 62,500(0.0625MHZ), comparing to 16, 000, 000(16MHZ)
  interrupts();  //re-enable interrupts
}

void loop()
{
  digitalWrite(13, HIGH);  //LED is on
  delay(10);  //0.01 second delay
  digitalWrite(13, LOW);  // LED is off
  delay(10);
}

```
### Let CPU sleep
Via set_sleep_mode() and sleep_mode() we could let CPU sleep for power-saving.    

```
/* putting CPU into sleep */
#include <avr/sleep.h>
extern volatile unsigned long timer0_millis;

void setup()
{
  pinMode(13, OUTPUT);   // an LED is attached to D13
  Serial.begin(9600);
}

void loop()
{
  while(timer0_millis<1000)
  {
    set_sleep_mode(SLEEP_MODE_IDLE);  // select "lightly napping "
    sleep_mode();  // go to sleep
  }
  timer0_millis = 0;   // reset millisecond counter
  bitSet(PINB, 5);    // toggle LED
  Serial.println("I am waked!");
}

```
