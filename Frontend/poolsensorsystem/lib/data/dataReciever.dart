class Data {
  late int date;
  late int phValue;
  late int ntuValue;
  late int temperature;
  Data(this.date, this.phValue, this.ntuValue, this.temperature);

  factory Data.fromJson(Map<String, dynamic> parsedjson) {
    return Data(
      parsedjson['date'], // Convert EPOCH to DateTime
      parsedjson['phValue'],
      parsedjson['ntuValue'],
      parsedjson['temperature'],
    );
  }
}
