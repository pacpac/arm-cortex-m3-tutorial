/* 
 PACPAC LLC 2017
 Greg Zaytsev
*/
 
/*
 Хардкоре практикум для ARM 32-bit Cortex®-M3
 
 Пример 1 - Мигающий светодиод

 Плата: NUCLEO-F103RB
 Микроконтроллер: STM32F103RB
 Ядро микроконтроллера: ARM 32-bit Cortex-M3
 
 Используемые ресурсы МК (UM1724 User manual STM32 Nucleo-64 boards):

 Светодиод LD2:
 The green LED is a user LED connected to MCU I/O PA5 (pin 21).
    * When the I/O is HIGH value, the LED is on.
    * When the I/O is LOW, the LED is off.
    
 Конфигурирование
 
 Для перевода PA5 в режим "Output mode, max speed 50 MHz"
 Установить: биты 21,20 MODE5[1:0] = 11 в регистре GPIOA_CRL
 
 Для конфигурирования PA5 в виде "General purpose output push-pull"
 Установить: биты 23,22 CNF5[1:0] = 00 в регистре GPIOA_CRL
 
 Документация:
    * http://www.st.com/content/st_com/en/products/microcontrollers/stm32-32-bit-arm-cortex-mcus/stm32f1-series/stm32f103/stm32f103rb.html
    * UM1724 User manual STM32 Nucleo-64 boards (August 2015)
    * RM0008 Reference manual STM32F103xx advanced ARM-based 32-bit MCUs
*/ 

// Указания для AS - тип ядра и требования к синтаксису
.syntax unified
.cpu cortex-m3
.thumb

// Адреса регистров в виде макроопределений

.set GPIOA_BASE,    0x40010800      // Базовый адрес для GPIOA
.set GPIOB_BASE,    0x40010C00      // Базовый адрес для GPIOB
.set GPIOC_BASE,    0x40011000      // Базовый адрес для GPIOC

.set GPIOA_CRL,     GPIOA_BASE+0x00 // Configuration register low
.set GPIOA_CRH,     GPIOA_BASE+0x04 // Configuration register high 

.set GPIOA_IDR,     GPIOA_BASE+0x08 // Input data register
.set GPIOA_ODR,     GPIOA_BASE+0x0C // Оutput data register 

.set GPIOA_BSRR,    GPIOA_BASE+0x10 // set/reset register
.set GPIOA_BRR,     GPIOA_BASE+0x04 // reset register

.set GPIOA_LCKR,    GPIOA_BASE+0x08 // locking register 

.set RCC_BASE,      0x40021000      // Базовый адрес для RCC 
.set RCC_APB2ENR,   RCC_BASE+0x18   // APB2 peripheral clock enable register

.set LED_BIT,       1 << 5          // Светодиод на линии PA5 GPIOA
 
.set DELAY,         0x80000         // Пауза
.set DELAY_VAR,     0x20000000      // Адрес в RAM, где будем хранить значение DELAY

.global _start

// Таблица векторов прерываний
.long   0x20001001  // Исходное значение для SP (Stack pointer) после старта
.long   _start      // Адрес обработчика прерывания Reset

// Точка входа в программу
_start:

// Подключаем тактовый генератор к блоку GPIOA
    LDR     R1, =0x00000004         // IOPAEN = 1
    LDR     R2, =RCC_APB2ENR
    STR     R1, [R2]
    
// Переводим линию GPIOA PA5 в режим "Output push-pull"
    LDR     R1, =0x44344444         // CNF5[1:0],MODE5[1:0] = 0011 
    LDR     R2, =GPIOA_CRL
    STR     R1, [R2]

// Инициализируем ячейку памяти, где хранится DELAY 
    LDR     R1, =DELAY
    LDR     R2, =DELAY_VAR
    STR     R1, [R2]
    
    LDR     R1, =GPIOA_ODR
    
loop:
    MOVW    R2, LED_BIT
    STR     R2, [R1]                // Зажигаем светодиод
    BL      delay
    EORS    R2, R2
    STR     R2, [R1]                // Гасим светодиод
    BL      delay
    B       loop
    
delay:
    LDR     R3, =DELAY_VAR
    LDR     R4, [R3]
dloop:
    SUBS    R4, #1
    BNE     dloop
    BX      LR
    
