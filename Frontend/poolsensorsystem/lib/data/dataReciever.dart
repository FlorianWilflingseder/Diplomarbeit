
class Data {
  late DateTime date;
  late double phValue;
  late double ntuValue;
  late double temperature;
  Data(this.date,this.phValue,this.ntuValue, this.temperature);

  Data.fromJson(Map<String, dynamic> json){
        date = json['date'];
        phValue = json['phValue'];
        ntuValue = json['ntuValue'];
        temperature = json['temperature'];
  }
}
