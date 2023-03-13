#pragma once

#include "common.h"

static esp_err_t status_get_handler(httpd_req_t *req);

static const httpd_uri_t status = {
    .uri       = "/status",
    .method    = HTTP_GET,
    .handler   = status_get_handler,
    .user_ctx  = "Hello World!"
};