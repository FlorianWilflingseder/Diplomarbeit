#include <string.h>
#include <esp_wifi.h>
#include <esp_event.h>
#include <esp_log.h>
#include <esp_system.h>
#include <nvs_flash.h>
#include <sys/param.h>
#include "esp_netif.h"
#include "esp_eth.h"
#include "esp_tls_crypto.h"
#include <esp_http_server.h>

#include "wifi.h"
#include "lora.h"

static const char *TAG = "sender";

/* [********************************] STATUS [********************************] */
static esp_err_t
get_status_handler(httpd_req_t *req)
{
    char *buf;
    size_t buf_len;

    /* Get header value string length and allocate memory for length + 1,
        * extra byte for null termination */
    buf_len = httpd_req_get_hdr_value_len(req, "Host") + 1;
    if (buf_len > 1) {
        buf = malloc(buf_len);

        /* Copy null terminated value string into buffer */
        if (httpd_req_get_hdr_value_str(req, "Host", buf, buf_len) == ESP_OK) {
            ESP_LOGI(TAG, "Found header => Host: %s", buf);
        }
        
        free(buf);
    }

    httpd_resp_set_hdr(req, "Content-Type", "application/json");

    // const char* resp_str = (const char*) req->user_ctx;

    char output[50];
    snprintf(output, 50, "%f", 7.127);

    httpd_resp_send(req, output, HTTPD_RESP_USE_STRLEN);

    /* After sending the HTTP response the old HTTP request
     * headers are lost. Check if HTTP request headers can be read now. */
    if (httpd_req_get_hdr_value_len(req, "Host") == 0) {
        ESP_LOGI(TAG, "Request headers lost");
    }

    return ESP_OK;
}

static httpd_uri_t handler_status = {
    .uri = "/api/status",
    .method = HTTP_GET,
    .handler = get_status_handler,
    .user_ctx = NULL};
/* [********************************] STATUS [********************************] */

/* [********************************] WEBSOCKET [********************************] */
static const size_t max_clients = 4;

struct async_resp_arg {
    httpd_handle_t hd;
    int fd;
    char *buf;
};

static esp_err_t
ws_handler(httpd_req_t *req)
{
    if (req->method == HTTP_GET) {
        ESP_LOGI(TAG, "Handshake done, the new connection was opened");

        // QoL: SEND LATEST DATA TO CLIENT

        return ESP_OK;
    }

    return ESP_OK;
}

static const httpd_uri_t handler_ws = {
    .uri        = "/ws",
    .method     = HTTP_GET,
    .handler    = ws_handler,
    .user_ctx   = NULL,
    .is_websocket = true
};

static void
send_data(void *arg)
{
    struct async_resp_arg *resp_arg = arg;
    httpd_handle_t hd = resp_arg->hd;
    int fd = resp_arg->fd;
    httpd_ws_frame_t ws_pkt;
    memset(&ws_pkt, 0, sizeof(httpd_ws_frame_t));
    ws_pkt.payload = (uint8_t*)resp_arg->buf;
    ws_pkt.len = strlen(resp_arg->buf);
    ws_pkt.type = HTTPD_WS_TYPE_TEXT;

    httpd_ws_send_frame_async(hd, fd, &ws_pkt);
    free(resp_arg);
}

esp_err_t
http_404_error_handler(httpd_req_t *req, httpd_err_code_t err)
{
   if (strcmp("/api/status", req->uri) == 0) {
      httpd_resp_send_err(req, HTTPD_404_NOT_FOUND, "/api/status URI is not available");
      /* Return ESP_OK to keep underlying socket open */
      return ESP_OK;
   } else if (strcmp("/ws", req->uri) == 0)　{
      httpd_resp_send_err(req, HTTPD_404_NOT_FOUND, "/ws URI is not available");
      return ESP_FAIL;
   }

   /* For any other URI send 404 and close socket */
   httpd_resp_send_err(req, HTTPD_404_NOT_FOUND, "Some 404 error message");
   return ESP_FAIL;
}

static httpd_handle_t start_webserver(void)
{
    httpd_handle_t server = NULL;
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();
    config.lru_purge_enable = true;

    ESP_LOGI(TAG, "Starting server on port: '%d'", config.server_port);
    if (httpd_start(&server, &config) == ESP_OK) {
        ESP_LOGI(TAG, "Registering URI handlers");
        httpd_register_uri_handler(server, &handler_status);
        httpd_register_uri_handler(server, &handler_ws);
        return server;
    }

    ESP_LOGI(TAG, "Error starting server!");
    return NULL;
}

static esp_err_t
stop_webserver(httpd_handle_t server)
{
   return httpd_stop(server);
}

static void
disconnect_handler(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
{
   httpd_handle_t *server = (httpd_handle_t *)arg;

   if (*server) {
      ESP_LOGI(TAG, "Stopping webserver");

      if (stop_webserver(*server) == ESP_OK) {
         *server = NULL;
      } else {
         ESP_LOGE(TAG, "Failed to stop http server");
      }
   }
}

static void
connect_handler(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
{
   httpd_handle_t *server = (httpd_handle_t *)arg;
   if (*server == NULL) {
      ESP_LOGI(TAG, "Starting webserver");
      *server = start_webserver();
   }
}

uint8_t buf[32];

void
task_rx(void *p)
{
    httpd_handle_t *serv = (httpd_handle_t *) p;

    int x;
    for (;;) {
        lora_receive();

        while (lora_received()) {
            x = lora_receive_packet(buf, sizeof(buf));
            buf[x] = 0;

            printf("rec: %s\n", buf);

            size_t clients = max_clients;
            int client_fds[max_clients];
            
            if (httpd_get_client_list(*serv, &clients, client_fds) == ESP_OK) {
                for (size_t i = 0; i < clients; ++i) {
                    int sock = client_fds[i];

                    if (httpd_ws_get_fd_info(*serv, sock) == HTTPD_WS_CLIENT_WEBSOCKET) {
                        ESP_LOGI(TAG, "Active client (fd=%d) -> sending async message", sock);
                        
                        struct async_resp_arg *resp_arg = malloc(sizeof(struct async_resp_arg));
                        resp_arg->hd = *serv;
                        resp_arg->fd = sock;
                        resp_arg->buf = (char*)buf;
                        
                        if (httpd_queue_work(resp_arg->hd, send_data, resp_arg) != ESP_OK) {
                            ESP_LOGE(TAG, "httpd_queue_work failed!");
                            break;
                        }
                    }
                }
            } else {
                ESP_LOGE(TAG, "httpd_get_client_list failed!");
            }

            lora_receive();
        }
        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

void
app_main(void)
{
    static httpd_handle_t server = NULL;

    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    init_wifi();

    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_STA_GOT_IP, &connect_handler, &server));
    ESP_ERROR_CHECK(esp_event_handler_register(WIFI_EVENT, WIFI_EVENT_STA_DISCONNECTED, &disconnect_handler, &server));

    server = start_webserver();

    lora_init();
    lora_set_frequency(915e6);
    lora_enable_crc();

    xTaskCreate(&task_rx, "task_rx", 2048, (void *) &server, 5, NULL);
}
