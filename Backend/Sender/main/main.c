#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

#include "lora.h"
#include "sensors.h"

void
app_main()
{
   lora_init();
   lora_set_frequency(915e6);
   lora_enable_crc();

   init_sensors();

   xTaskCreate(&sensors_task, "sensors_task", 2048, NULL, 5, NULL);
}