#pragma once

#include "common.h"

static esp_err_t alarm_post_handler(httpd_req_t *req);

static httpd_uri_t handler_alarm;