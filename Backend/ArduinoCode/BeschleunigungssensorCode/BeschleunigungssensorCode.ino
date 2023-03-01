#include "Wire.h" // Importieren der I2C Bibliothek.
const int I2C_adress_MPU = 0x68; // I2C Adresse des MPU6050.
int16_t Beschleunigung_x, Beschleunigung_y, Beschleunigung_z; // Variablen für den Beschleunigungssensor
int16_t gyro_x, gyro_y, gyro_z; // Variablen für das Gyroscope
char tmp_str[7];
char* convert_int16_to_str(int16_t i) {
  sprintf(tmp_str, "%6d", i);
  return tmp_str;
}
void setup() {
  Serial.begin(9600);
  Wire.begin();
  Wire.beginTransmission(I2C_adress_MPU); // Starten der I2C übertragung
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);
}


void loop() {
  Wire.beginTransmission(I2C_adress_MPU);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(I2C_adress_MPU, 7 * 2, true);
  Beschleunigung_x = Wire.read() << 8 | Wire.read();
  Beschleunigung_y = Wire.read() << 8 | Wire.read();
  Beschleunigung_z = Wire.read() << 8 | Wire.read();
  //gyro_x = Wire.read() << 8 | Wire.read();
  //gyro_y = Wire.read() << 8 | Wire.read();
  //gyro_z = Wire.read() << 8 | Wire.read();
  delay(1000);
}
