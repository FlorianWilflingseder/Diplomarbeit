#pragma once

#include "common.h"

static esp_err_t alarm_post_handler(httpd_req_t *req);

static const httpd_uri_t alarm = {
    .uri       = "/alarm",
    .method    = HTTP_POST,
    .handler   = alarm_post_handler,
    .user_ctx  = NULL
};