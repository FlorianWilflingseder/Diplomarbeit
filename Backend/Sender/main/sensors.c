#include "sensors.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "soc/soc_caps.h"
#include "esp_log.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"

#include "onewire_bus.h"
#include "ds18b20.h"

#include "lora.h"

#define PH_SENSOR_ADC2_CHANNEL  ADC_CHANNEL_8
#define NTU_SENSOR_ADC2_CHANNEL ADC_CHANNEL_6

#define TEMP_ONEWIRE_GPIO_PIN    GPIO_NUM_4

#define SENSOR_ADC2_ATTEN ADC_ATTEN_DB_11

#define DELAY 1000 * 10 // 60 * 60

const static char *TAG = "SENDER_TASK";

#if (SOC_ADC_PERIPH_NUM < 2)
    #error "ADC2 IS NOT SUPPORTED ON THIS DEVICE"
#endif

bool
adc_calibration_init(adc_unit_t unit, adc_atten_t atten, adc_cali_handle_t *out_handle)
{
    adc_cali_handle_t handle = NULL;
    esp_err_t ret = ESP_FAIL;
    bool calibrated = false;

#if ADC_CALI_SCHEME_CURVE_FITTING_SUPPORTED
    if (!calibrated) {
        ESP_LOGI(TAG, "calibration scheme version is %s", "Curve Fitting");
        adc_cali_curve_fitting_config_t cali_config = {
            .unit_id = unit,
            .atten = atten,
            .bitwidth = ADC_BITWIDTH_DEFAULT,
        };

        ret = adc_cali_create_scheme_curve_fitting(&cali_config, &handle);
        if (ret == ESP_OK) {
            calibrated = true;
        }
    }
#endif

#if ADC_CALI_SCHEME_LINE_FITTING_SUPPORTED
    if (!calibrated) {
        ESP_LOGI(TAG, "calibration scheme version is %s", "Line Fitting");
        adc_cali_line_fitting_config_t cali_config = {
            .unit_id = unit,
            .atten = atten,
            .bitwidth = ADC_BITWIDTH_DEFAULT,
        };
        ret = adc_cali_create_scheme_line_fitting(&cali_config, &handle);
        if (ret == ESP_OK) {
            calibrated = true;
        }
    }
#endif

    *out_handle = handle;
    if (ret == ESP_OK) {
        ESP_LOGI(TAG, "Calibration Success");
    } else if (ret == ESP_ERR_NOT_SUPPORTED || !calibrated) {
        ESP_LOGW(TAG, "eFuse not burnt, skip software calibration");
    } else {
        ESP_LOGE(TAG, "Invalid arg or no memory");
    }

    return calibrated;
}

void
adc_calibration_deinit(adc_cali_handle_t handle)
{
#if ADC_CALI_SCHEME_CURVE_FITTING_SUPPORTED
    ESP_LOGI(TAG, "deregister %s calibration scheme", "Curve Fitting");
    ESP_ERROR_CHECK(adc_cali_delete_scheme_curve_fitting(handle));

#elif ADC_CALI_SCHEME_LINE_FITTING_SUPPORTED
    ESP_LOGI(TAG, "deregister %s calibration scheme", "Line Fitting");
    ESP_ERROR_CHECK(adc_cali_delete_scheme_line_fitting(handle));
#endif
}

adc_oneshot_chan_cfg_t chan_cfg = {
    .bitwidth = ADC_BITWIDTH_DEFAULT,
    .atten = SENSOR_ADC2_ATTEN,
};
adc_oneshot_unit_handle_t adc2_handle;
adc_oneshot_unit_init_cfg_t init_cfg = {
    .unit_id = ADC_UNIT_2,
    .ulp_mode = ADC_ULP_MODE_DISABLE,
};

onewire_rmt_config_t config = {
    .gpio_pin = TEMP_ONEWIRE_GPIO_PIN,
    .max_rx_bytes = 10,
};
onewire_bus_handle_t handle;
uint8_t device_num = 0;
uint8_t device_rom_id[5][8];

void
init_sensors()
{
    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_cfg, &adc2_handle));

    // install new 1-wire bus
    ESP_ERROR_CHECK(onewire_new_bus_rmt(&config, &handle));
    ESP_LOGI(TAG, "1-wire bus installed");

    // create 1-wire rom search context
    onewire_rom_search_context_handler_t context_handler;
    ESP_ERROR_CHECK(onewire_rom_search_context_create(handle, &context_handler));

    do {
        esp_err_t search_result = onewire_rom_search(context_handler);

        if (search_result == ESP_ERR_INVALID_CRC) {
            continue;
        } else if (search_result == ESP_FAIL || search_result == ESP_ERR_NOT_FOUND) {
            break;
        }

        ESP_ERROR_CHECK(onewire_rom_get_number(context_handler, device_rom_id[device_num]));
        ESP_LOGI(TAG, "found device with rom id " ONEWIRE_ROM_ID_STR, ONEWIRE_ROM_ID(device_rom_id[device_num]));
        device_num++;
    } while (device_num < 5);

    ESP_ERROR_CHECK(onewire_rom_search_context_delete(context_handler));
    ESP_LOGI(TAG, "%d device%s found on 1-wire bus", device_num, device_num > 1 ? "s" : "");
}

void
sensors_task(void *p)
{
    int raw;
    float pH = 0, ntu = 0, temp = 0;
    char str[64];

    for(;;) {
        ESP_ERROR_CHECK(adc_oneshot_config_channel(adc2_handle, PH_SENSOR_ADC2_CHANNEL, &chan_cfg));
        ESP_ERROR_CHECK(adc_oneshot_read(adc2_handle, PH_SENSOR_ADC2_CHANNEL, &raw));
        pH = raw * (5.0 / 1024);
        pH *= 2;

        esp_err_t err = ds18b20_set_resolution(handle, NULL, DS18B20_RESOLUTION_12B);
        if (err != ESP_OK) {
            ESP_LOGI(TAG, "failed to set res");
        }
        err = ds18b20_trigger_temperature_conversion(handle, NULL); 
        if (err != ESP_OK) {
            ESP_LOGI(TAG, "failed to trigger temp conversion");
        }
        
        vTaskDelay(pdMS_TO_TICKS(800));

        // 5YSq5pyI44G+44KK44Gq base64

        for (int i = 0; i < device_num; ++i) {
            float newTemp;
            err = ds18b20_get_temperature(handle, device_rom_id[i], &newTemp);
            if (err != ESP_OK) {
                continue;
            }

            if (newTemp != 0) {
                temp = newTemp;
            }
        }

        ESP_ERROR_CHECK(adc_oneshot_config_channel(adc2_handle, NTU_SENSOR_ADC2_CHANNEL, &chan_cfg));
        ESP_ERROR_CHECK(adc_oneshot_read(adc2_handle, NTU_SENSOR_ADC2_CHANNEL, &raw));
        ntu = raw * (5.0 / 1023);
        ntu /= 20;

        snprintf(str, 64, "%.2f;%.2f;%.2f", pH, ntu, temp);

        printf("SENT %s\n", str);
        lora_send_packet((uint8_t*)str, 64);

        vTaskDelay(pdMS_TO_TICKS(DELAY));
    }


    ESP_ERROR_CHECK(onewire_del_bus(handle));
    ESP_LOGI(TAG, "1-wire bus deleted");

    ESP_ERROR_CHECK(adc_oneshot_del_unit(adc2_handle));
}