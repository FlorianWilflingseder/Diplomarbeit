#define SENSOR 25
#define OFFSET 0.00
#define LED 13
#define SAMPLING_INTERVAL 20
#define PRINT_INTERVAL 800
#define ARRAY_LENGTH 40
int PH_ARRAY[ARRAY_LENGTH]; // average value of sensor feedback
int PH_ARRAY_INDEX=0;

void setup() {
  //pinMode(SENSOR,OUTPUT);
  Serial.begin(115200);
}

void loop() {
  //Serial.println(analogRead(SENSOR));
  static unsigned long SAMPLING_TIME = millis();
  static unsigned long PRINT_TIME = millis();
  static float VOLTAGE;
  if(millis()-SAMPLING_TIME>SAMPLING_INTERVAL)
  {
    PH_ARRAY[PH_ARRAY_INDEX++]= analogRead(SENSOR);
    if(PH_ARRAY_INDEX == ARRAY_LENGTH)PH_ARRAY_INDEX=0;
    VOLTAGE = AVERAGE_ARRAY(PH_ARRAY,ARRAY_LENGTH)*5.0/1024;
    SAMPLING_TIME=millis();
  }
  if(millis()- PRINT_TIME > PRINT_INTERVAL)
  {
    Serial.print("Voltage:");
    Serial.println(VOLTAGE,2);
  }
  sleep(1);
} 
double AVERAGE_ARRAY(int* ARR, int NUMBER){
  int i;
  int max,min;
  double AVG;
  long AMOUNT = 0;
  if(NUMBER<=0){
    Serial.println("ERROR!/n");
    return 0;
  }
  if(NUMBER<5){
    for(i = 0; i < NUMBER; i++){
      AMOUNT +=ARR[i];
    }
    AVG = AMOUNT/NUMBER;
    return AVG;
  }else{
    if(ARR[0]<ARR[1]){
      min = ARR[0];max=ARR[1];
    }
    else{
      min=ARR[1];max=ARR[0];
    }
    for(i=2;i<NUMBER;i++){
      if(ARR[i]<min){
        AMOUNT += min;
        min=ARR[i];
      }else{
        if(ARR[i]>=max){
          AMOUNT += max; //arr>max
          max= AMOUNT+=ARR[i];
        }else{
          AMOUNT+= ARR[i];
        }
      }
    }
  }
}
