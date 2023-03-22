import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dataReciever.dart';
import 'chart_data.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class TemperatureData {
  final String day;
  final double temperature;

  TemperatureData(this.day, this.temperature);
}

String getDayAsString(DateTime time) {
  DateFormat dateFormat = DateFormat('EEEE', 'de_DE');
  return dateFormat.format(time);
}

// http://XXX.XXX.X.X/api/status?d=1
// http://XXX.XXX.X.X/api/status?d=7
// http://XXX.XXX.X.X/api/status?d=14
// http://XXX.XXX.X.X/api/status?d=30
// http://XXX.XXX.X.X/api/status?d=60

// http://XXX.XXX.X.X/api/status?d=90 -> 3monat

// TODAY.month = 6
// EPOCH.month = 1

// date.month = 5

// date =(DateTime.TODAY - DateTimeFromEpoch(123123)) -> DateTime
// date.month, date.day
// date.day <= 7 0-30/31
// date.month == 3
// date.month == 2
// date.month == 1
Future<List<Data>> fetchSensorValues() async {
  final response = await http.get(Uri.parse("http://192.168.1.4/api/status"));

  if (response.statusCode == 200) {
    List<Data> values = [];
    List<String> lines = response.body.split('\n');
    initializeDateFormatting('de_DE', null);
    int epochtime = 1679440224;
    int realLines = 0;
    for (String line in lines) {
      epochtime = epochtime + 86400; //!!!!!
      List<String> data = ("$epochtime;$line")
          .split(';'); //manuelles DATE backend hat kein timestamp!!!!!!!!!!!!
      if (data.length != 4) continue;
      DateTime time =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data[0]) * 1000);
      double ntu = double.parse(data[1]);
      double ph = double.parse(data[2]);
      double temp = double.parse(data[3]);
      values.add(Data(time, ntu, ph, temp));
      if (values.length == 7) {
        return values;
      }
    }
    return values;
  } else {
    throw Exception('Failed to load album');
  }
}

class TemperaturStats extends StatefulWidget {
  TemperaturStats({
    super.key,
  });
  @override
  State<TemperaturStats> createState() => _TemperaturStatsState();
}

class _TemperaturStatsState extends State<TemperaturStats> {
  List<TemperatureData> data = [];
  List<charts.Series<TemperatureData, String>> dataTemp = [];

  @override
  initState() {
    super.initState();
    fetchSensorValues().then((result) {
      setState(() {
        data = result
            .map((e) => TemperatureData(getDayAsString(e.date), e.temperature))
            .toList();
        dataTemp.add(charts.Series<TemperatureData, String>(
          id: 'temperature',
          data: data,
          domainFn: (TemperatureData temp, _) => temp.day,
          measureFn: (TemperatureData temp, _) => temp.temperature,
          colorFn: (_, __) => charts.Color.fromHex(code: '#5493e0AF'),
          labelAccessorFn: (TemperatureData temp, _) =>
              temp.temperature.toString(),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 38, 82),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Temperatur Diagramme",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "24 Stunden",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: SfCartesianChart(
                margin: const EdgeInsets.all(0),
                borderWidth: 0,
                borderColor: Colors.transparent,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  isVisible: true,
                  borderColor: Colors.transparent,
                  interval: 1,
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  minimum: 0,
                  maximum: 35,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<TemperatureData, String>>[
                  SplineAreaSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    splineType: SplineType.natural,
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 84, 147, 224),
                        const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  SplineSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    color: const Color.fromARGB(255, 121, 123, 245),
                    width: 4,
                    markerSettings: const MarkerSettings(
                      color: Colors.white,
                      borderWidth: 2,
                      shape: DataMarkerType.circle,
                      isVisible: true,
                      borderColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(
                color: Colors.white,
                height: 50, // set the height of the divider
                thickness: 2, // set the thickness of the divider
              ),
            ),
            Text(
              "7-Tage",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 300,
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: charts.BarChart(
                          dataTemp,
                          animate: true,
                          defaultRenderer: charts.BarRendererConfig(
                            cornerStrategy:
                                const charts.ConstCornerStrategy(30),
                            maxBarWidthPx: 20,
                            barRendererDecorator:
                                charts.BarLabelDecorator<String>(
                              labelAnchor: charts.BarLabelAnchor.end,
                              labelPosition: charts.BarLabelPosition.outside,
                              outsideLabelStyleSpec: const charts.TextStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                            ),
                          ),
                          domainAxis: const charts.OrdinalAxisSpec(
                            renderSpec: charts.SmallTickRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.transparent,
                              ),
                            ),
                          ),
                          primaryMeasureAxis: const charts.NumericAxisSpec(
                            renderSpec: charts.GridlineRendererSpec(
                              labelStyle: charts.TextStyleSpec(
                                color: charts.MaterialPalette.white,
                              ),
                              lineStyle: charts.LineStyleSpec(
                                color: charts.MaterialPalette.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(
                color: Colors.white,
                height: 50, // set the height of the divider
                thickness: 2, // set the thickness of the divider
              ),
            ),
            Text(
              "1 Monat",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: SfCartesianChart(
                margin: const EdgeInsets.all(0),
                borderWidth: 0,
                borderColor: Colors.transparent,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  isVisible: true,
                  borderColor: Colors.transparent,
                  interval: 3,
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  minimum: 0,
                  maximum: 35,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<TemperatureData, String>>[
                  SplineAreaSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    splineType: SplineType.natural,
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 84, 147, 224),
                        const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  SplineSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    color: const Color.fromARGB(255, 121, 123, 245),
                    width: 4,
                    markerSettings: const MarkerSettings(
                      color: Colors.white,
                      borderWidth: 2,
                      shape: DataMarkerType.circle,
                      isVisible: true,
                      borderColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Divider(
                color: Colors.white,
                height: 50, // set the height of the divider
                thickness: 2, // set the thickness of the divider
              ),
            ),
            Text(
              "3 Monate",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: SfCartesianChart(
                margin: const EdgeInsets.all(0),
                borderWidth: 0,
                borderColor: Colors.transparent,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  isVisible: true,
                  borderColor: Colors.transparent,
                  interval: 3,
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  majorGridLines: const MajorGridLines(
                    color: Colors.transparent,
                  ),
                  majorTickLines: const MajorTickLines(
                    color: Colors.transparent,
                  ),
                  axisLine: const AxisLine(
                    color: Colors.transparent,
                  ),
                  minimum: 0,
                  maximum: 35,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<TemperatureData, String>>[
                  SplineAreaSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    splineType: SplineType.natural,
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 84, 147, 224),
                        const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  SplineSeries(
                    dataSource: data,
                    xValueMapper: (TemperatureData data, _) => data.day,
                    yValueMapper: (TemperatureData data, _) => data.temperature,
                    color: const Color.fromARGB(255, 121, 123, 245),
                    width: 4,
                    markerSettings: const MarkerSettings(
                      color: Colors.white,
                      borderWidth: 2,
                      shape: DataMarkerType.circle,
                      isVisible: true,
                      borderColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
