#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into Pin ? on the Arduino
#define ONE_WIRE_BUS 

// Setup a OneWire instance to communicate with any OneWire devices
OneWire oneWire(ONE_WIRE_BUS);

// Pass OneWire reference to Dallas Temperature
DallasTemperature sensors(&oneWire);

void setup(void)
{
    Serial.begin(9600);
    sensors.begin(); // Start up the library
}

void loop(void)
{
    // call sensors.requestTemperatures() to issue a global temperature
    // request to all devices on the bus
    // Send the command to get temperature readings
    sensors.requestTemperatures();

    Serial.println("Temperature is: " + String(sensors.getTempCByIndex(0)) + "°C");

    // You can have more than one DS18B20 on the same bus.
    // 0 refers to the first IC on the wire
    delay(1000);
}
