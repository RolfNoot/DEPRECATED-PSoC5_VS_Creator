/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"

static volatile uint8_t dummy __attribute__ ((section(".cyeeprom"),unused));        // Fix for linker error.cyeeprom data will not fit in EEPROM 

int main(void)
{
    CyGlobalIntEnable; /* Enable global interrupts. */
    CyDelay(1000);
    Timer_1_Start();
    while(1) {}
}

/* [] END OF FILE */