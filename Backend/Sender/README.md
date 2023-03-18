| Supported Targets | ESP32 | ESP32-C3 | ESP32-S2 | ESP32-S3 |
| ----------------- | ----- | -------- | -------- | -------- |

# Simple HTTPD Server Example

The Example consists of HTTPD server demo with demostration of URI handling :
    1. URI \hello for GET command returns "Hello World!" message
    2. URI \echo for POST command echoes back the POSTed message

## How to use example

### Hardware Required

* A development board with ESP32/ESP32-S2/ESP32-C3 SoC (e.g., ESP32-DevKitC, ESP-WROVER-KIT, etc.)
* A USB cable for power supply and programming

### Configure the project

```
idf.py menuconfig
```
* Open the project configuration menu (`idf.py menuconfig`) to configure Wi-Fi or Ethernet. See "Establishing Wi-Fi or Ethernet Connection" section in [examples/protocols/README.md](../../README.md) for more details.

### Build and Flash

Build the project and flash it to the board, then run monitor tool to view serial output:

```
idf.py -p PORT flash monitor
```

(Replace PORT with the name of the serial port to use.)

(To exit the serial monitor, type ``Ctrl-]``.)

See the Getting Started Guide for full steps to configure and use ESP-IDF to build projects.

### Test the example :
        * run the test script : "python scripts/client.py \<IP\> \<port\> \<MSG\>"
            * the provided test script first does a GET \hello and displays the response
            * the script does a POST to \echo with the user input \<MSG\> and displays the response
        * or use curl (asssuming IP is 192.168.43.130):
            1. "curl 192.168.43.130:80/hello"  - tests the GET "\hello" handler
            2. "curl -X POST --data-binary @anyfile 192.168.43.130:80/echo > tmpfile"
                * "anyfile" is the file being sent as request body and "tmpfile" is where the body of the response is saved
                * since the server echoes back the request body, the two files should be same, as can be confirmed using : "cmp anyfile tmpfile"
            3. "curl -X PUT -d "0" 192.168.43.130:80/ctrl" - disable /hello and /echo handlers
            4. "curl -X PUT -d "1" 192.168.43.130:80/ctrl" -  enable /hello and /echo handlers

## Example Output
```
I (9580) example_connect: - IPv4 address: 192.168.194.219
I (9580) example_connect: - IPv6 address: fe80:0000:0000:0000:266f:28ff:fe80:2c74, type: ESP_IP6_ADDR_IS_LINK_LOCAL
I (9590) example: Starting server on port: '80'
I (9600) example: Registering URI handlers
I (66450) example: Found header => Host: 192.168.194.219
I (66460) example: Request headers lost
```

## Troubleshooting
* If the server log shows "httpd_parse: parse_block: request URI/header too long", especially when handling POST requests, then you probably need to increase HTTPD_MAX_REQ_HDR_LEN, which you can find in the project configuration menu (`idf.py menuconfig`): Component config -> HTTP Server -> Max HTTP Request Header Length

/*
 * REORDER FROM LARGEST TO SMALLEST TO REDUCE INITIAL SLOP !
 *
 * LARGEST                      ->                      SMALLEST
 * +-----------------------+-------------------+---------------+
 * | Temperature    0 - 63 | NTU        0 - 31 | PH     0 - 15 |
 * +-----------------------+-------------------+---------------|
 * | 1 | 0 | 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | <-> 40;20;14
 * +-----------------------+---------------+-------------------+
 * | 0   1   2   3   4   5   6   7   8   9   0   1   2   3   4 | -> 15 bits
 * +-----------------------+---------------+-------------------+
 * |           a           |         b         |       c       |
 * +-----------------------+---------------+-------------------+
 * |              1              |              2              | -> 02 bytes
 * +-----------------------------------------------------------+
 *
 * 0 <= a <= 40 < 41
 * 0 <= b <= 14 < 15
 * 0 <= c <= 20 < 21
 * 
 * PACK:
 * o = c
 * o *= 21
 * o += b
 * o *= 41	
 * o += a
 *
 * UNPACK:
 * a = o % 41
 * o /= 41
 * b = o % 21
 * o /= 21
 * c = o
 *
 * a=40,b=20,c=14
 *
 * pack(a, b, c) = 12914
 * +-------------------------------------------------------+
 * | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | -> 14 (!) bits
 * +-------------------------------------------------------+ -> 12.5% decrease in size
 *
 * a = 12914 % 41 = 40
 * o /= 41
 * b = 314 % 21 = 20
 * o /= 21
 * c = 14
 */

 uint8_t buf[32];

void task_rx(void *p)
{
   int x;
   for(;;) {
      lora_receive();
      while(lora_received()) {
         x = lora_receive_packet(buf, sizeof(buf));
         buf[x] = 0;
         printf("Received: %s\n", buf);
         lora_receive();
      }
      vTaskDelay(pdMS_TO_TICKS(1000));
   }
}

void app_main()
{
   lora_init();
   lora_set_frequency(915e6);
   lora_enable_crc();
   xTaskCreate(&task_rx, "task_rx", 2048, NULL, 5, NULL);
}