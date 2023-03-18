#include "sensor.h"

const static char *TAG = "PH_SENSOR";

#define PH_SENSOR_ADC2_CHANNEL ADC_CHANNEL_8
#define PH_SENSOR_ADC2_ATTEN   ADC_ATTEN_DB_11

double get_ph() {
    adc_oneshot_chan_cfg_t config = {
        .bitwidth = ADC_BITWIDTH_DEFAULT,
        .atten = PH_SENSOR_ADC2_ATTEN,
    };
    adc_oneshot_unit_handle_t adc2_handle;
    adc_oneshot_unit_init_cfg_t init_config2 = {
        .unit_id = ADC_UNIT_2,
        .ulp_mode = ADC_ULP_MODE_DISABLE,
    };

    ESP_ERROR_CHECK(adc_oneshot_new_unit(&init_config2, &adc2_handle));

    adc_cali_handle_t adc2_cali_handle = NULL;
    bool do_calibration = adc_calibration_init(ADC_UNIT_2, PH_SENSOR_ADC2_ATTEN, &adc2_cali_handle);

    ESP_ERROR_CHECK(adc_oneshot_config_channel(adc2_handle, PH_SENSOR_ADC2_CHANNEL, &config));

    int adc_raw, voltage, raw;
    double pH = 0.0;

    ESP_ERROR_CHECK(adc_oneshot_read(adc2_handle, PH_SENSOR_ADC2_CHANNEL, &adc_raw));
    raw = adc_raw;

    if (do_calibration) {
        ESP_ERROR_CHECK(adc_cali_raw_to_voltage(adc2_cali_handle, adc_raw, &voltage));
        // ESP_LOGI(TAG, "ADC%d Channel[%d] Cali Voltage: %d mV -> %lf", ADC_UNIT_2 + 1, PH_SENSOR_ADC2_CHANNEL, voltage, pH);
        raw = voltage;
    }

    pH = raw * (5.0 / 1024);
    pH = (pH * 3.56) - 1.889;

/*
    while (1) {
        ESP_ERROR_CHECK(adc_oneshot_read(adc2_handle, PH_SENSOR_ADC2_CHANNEL, &adc_raw));
        raw = adc_raw;

        if (do_calibration) {
            ESP_ERROR_CHECK(adc_cali_raw_to_voltage(adc2_cali_handle, adc_raw, &voltage));
            // ESP_LOGI(TAG, "ADC%d Channel[%d] Cali Voltage: %d mV -> %lf", ADC_UNIT_2 + 1, PH_SENSOR_ADC2_CHANNEL, voltage, pH);
            raw = voltage;
        }
        pH = raw * (5.0 / 1024); // TODO: take temperature into account !!!!!!!!
        pH = (pH * 3.56) - 1.889;
        pH = clamp(pH, 0, 14);
        ESP_LOGI(TAG,"pH: %lf", pH);

        vTaskDelay(pdMS_TO_TICKS(1000));
    }
    */

    ESP_ERROR_CHECK(adc_oneshot_del_unit(adc2_handle));

    if (do_calibration) {
        adc_calibration_deinit(adc2_cali_handle);
    }

    return pH;
}