#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "soc/soc_caps.h"
#include "esp_log.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"

const static char *TAG = "PH_SENSOR";

#if (SOC_ADC_PERIPH_NUM < 2)
    #error "ADC2 IS NOT SUPPORTED ON THIS DEVICE"
#endif

#define PH_SENSOR_ADC2_CHANNEL ADC_CHANNEL_8
#define PH_SENSOR_ADC2_ATTEN   ADC_ATTEN_DB_11

static bool adc_calibration_init(adc_unit_t unit, adc_atten_t atten, adc_cali_handle_t *out_handle) {
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

static void adc_calibration_deinit(adc_cali_handle_t handle) {
#if ADC_CALI_SCHEME_CURVE_FITTING_SUPPORTED
    ESP_LOGI(TAG, "deregister %s calibration scheme", "Curve Fitting");
    ESP_ERROR_CHECK(adc_cali_delete_scheme_curve_fitting(handle));

#elif ADC_CALI_SCHEME_LINE_FITTING_SUPPORTED
    ESP_LOGI(TAG, "deregister %s calibration scheme", "Line Fitting");
    ESP_ERROR_CHECK(adc_cali_delete_scheme_line_fitting(handle));
#endif
}

double clamp(double d, double min, double max) {
  const double t = d < min ? min : d;
  return t > max ? max : t;
}

void app_main(void) {
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

    ESP_ERROR_CHECK(adc_oneshot_del_unit(adc2_handle));

    if (do_calibration) {
        adc_calibration_deinit(adc2_cali_handle);
    }
}
