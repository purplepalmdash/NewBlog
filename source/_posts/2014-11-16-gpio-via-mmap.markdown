---
layout: post
title: "EBC Exercises on BBB -GPIO Via Mmap"
date: 2014-11-16 11:30
comments: true
categories: embedded
---
### Operate On Device Tree
Turn off the trigger and then shine on the LED USR3 via following command:     

```
root@arm:~# cd /sys/class/leds/beaglebone\:green\:usr3
root@arm:/sys/class/leds/beaglebone:green:usr3# ls
brightness  device  max_brightness  power  subsystem  trigger  uevent
root@arm:/sys/class/leds/beaglebone:green:usr3# echo none > trigger 
root@arm:/sys/class/leds/beaglebone:green:usr3# echo 1 > brightness

```
We could find the gpio is attached to which pin:     

```
# ./findGPIO.js USR3                                                                
{ name: 'USR3',                                                                                         
 gpio: 56,                                                                                             
 led: 'usr3',                                                                                          
 mux: 'gpmc_a8',                                                                                       
 key: 'USR3',                                                                                          
 muxRegOffset: '0x060',                                                                                
 options:                                                                                              
  [ 'gpmc_a8',                                                                                         
    'gmii2_rxd3',                                                                                      
    'rgmii2_rd3',                                                                                      
    'mmc2_dat6',                                                                                       
    'gpmc_a24',                                                                                        
    'pr1_mii1_rxd0',                                                                                   
    'mcasp0_aclkx',                                                                                    
    'gpio1_24' ] }
USR3 (gpio 56) mode: 7 (gpio1_24) 0x060 pullup
pin 24 (44e10860): (MUX UNCLAIMED) (GPIO UNCLAIMED)

```
`gpio1_24` is what we want. Then refer Memory Map table in the Technical Reference Manual, its base address is 0x4804c000.     
### devmem2
An easy way to read the contents of a memory location is with devmem2:    

```
root@arm:~/code/gpio# devmem2 0x4804c13c
/dev/mem opened.
Memory mapped at address 0xb6fea000.
Value at address 0x4804C13C (0xb6fea13c): 0x9A00000

```
Light ON the USR3 led:     

```
root@arm:~/code/gpio# devmem2 0x4804c190 w 0x01000000
/dev/mem opened.
Memory mapped at address 0xb6f52000.
Value at address 0x4804C190 (0xb6f52190): 0x9800000
Written 0x1000000; readback 0x1000000

```
Light OFF the USR3 led:   

```
root@arm:~/code/gpio# devmem2 0x4804c194 w 0x01000000
/dev/mem opened.
Memory mapped at address 0xb6f1c000.
Value at address 0x4804C194 (0xb6f1c194): 0x8A00000
Written 0x1000000; readback 0x1000000

```
### mmap code
The critical Code:     

```
    int fd = open("/dev/mem", O_RDWR);

    gpio_addr = mmap(0, GPIO1_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, GPIO1_START_ADDR);

    gpio_oe_addr           = gpio_addr + GPIO_OE;
    gpio_setdataout_addr   = gpio_addr + GPIO_SETDATAOUT;
    gpio_cleardataout_addr = gpio_addr + GPIO_CLEARDATAOUT;

    // Set USR3 to be an output pin
    reg = *gpio_oe_addr;
    printf("GPIO1 configuration: %X\n", reg);
    reg &= ~USR3;       // Set USR3 bit to 0
    *gpio_oe_addr = reg;
    printf("GPIO1 configuration: %X\n", reg);

    printf("Start blinking LED USR3\n");
    while(keepgoing) {
        // printf("ON\n");
        *gpio_setdataout_addr = USR3;
        usleep(250000);
        // printf("OFF\n");
        *gpio_cleardataout_addr = USR3;
        usleep(250000);
    }

```
Run the program and see its heartbeat:     

```
# ./gpioToggle 
Mapping 4804C000 - 4804E000 (size: 2000)
GPIO mapped to 0xb6f91000
GPIO OE mapped to 0xb6f91134
GPIO SETDATAOUTADDR mapped to 0xb6f91194
GPIO CLEARDATAOUT mapped to 0xb6f91190
GPIO1 configuration: F60FFFFF
GPIO1 configuration: F60FFFFF
Start blinking LED USR3

```
### gpioThru
This example need to be clearly written later.    
