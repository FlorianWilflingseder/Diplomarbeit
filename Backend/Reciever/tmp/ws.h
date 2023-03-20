#pragma once

#include "common.h"

struct async_resp_arg {
    httpd_handle_t hd;
    int fd;
};

static void ws_async_send(void *arg);

static esp_err_t trigger_async_send(httpd_handle_t handle, httpd_req_t *req);

static esp_err_t ws_handler(httpd_req_t *req);

static httpd_uri_t handler_ws;