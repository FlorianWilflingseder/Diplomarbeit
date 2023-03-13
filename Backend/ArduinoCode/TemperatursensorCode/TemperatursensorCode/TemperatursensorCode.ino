#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into Pin ? on the Arduino
#define ONE_WIRE_BUS 25
// Setup a OneWire instance to communicate with any OneWire devices
OneWire oneWire(ONE_WIRE_BUS);

// Pass OneWire reference to Dallas Temperature
DallasTemperature sensors(&oneWire);

void setup(void)
{
  Serial.begin(9600);
  Serial.println("Termperatur Sensor");
  sensors.begin(); // Start up the library
}

void loop(void)
{
  // call sensors.requestTemperatures() to issue a global temperature
  // request to all devices on the bus
  // Send the command to get temperature readings
  Serial.print("Requesting temperatures...");
  sensors.requestTemperatures(); // Send the command to get temperatures
  Serial.println("DONE");

  float tempC = sensors.getTempCByIndex(0);
  Serial.println(tempC);
  // Check if reading was successful
  if (tempC != DEVICE_DISCONNECTED_C)
  {
    Serial.print("Temperature for the device 1 (index 0) is: ");
    Serial.println(tempC);
  }
  else
  {
    Serial.println("Error: Could not read temperature data");
  }



  // Serial.println("Temperature is: " + String(sensors.getTempCByIndex(0)) + "°C");

  // You can have more than one DS18B20 on the same bus.
  // 0 refers to the first IC on the wire
  //delay(10);
}
