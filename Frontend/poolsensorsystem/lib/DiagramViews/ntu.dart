import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../infoscreens/ntuinfo.dart';
import 'package:intl/intl.dart';
import '../data/dataReciever.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

class NtuData {
  final DateTime dt;
  final double ntu;
  NtuData(this.dt, this.ntu);
}

String getDateAsHourString(DateTime time) {
  DateFormat dateFormat = DateFormat('H', 'de_DE');
  return dateFormat.format(time);
}

String getDateAsDayString(DateTime time) {
  DateFormat dateFormat = DateFormat('E', 'de_DE');
  return dateFormat.format(time);
}

Future<List<Data>> fetchSensorValues() async {
  final response = await http.get(Uri.parse("http://192.168.8.102/api/status"));

  if (response.statusCode == 200) {
    List<Data> values = [];
    List<String> lines = response.body.split('\n');
    initializeDateFormatting('de_DE', null);

    for (String line in lines) {
      List<String> data = line.split(';');
      if (data.length != 4) continue;
      DateTime time =
          DateTime.fromMillisecondsSinceEpoch(int.parse(data[0]) * 1000);
      double ntu = double.parse(data[1]);
      double ph = double.parse(data[2]);
      double temp = double.parse(data[3]);
      values.add(Data(time, ntu, ph, temp));
    }
    return values;
  } else {
    throw Exception('Failed to load album');
  }
}

class NTUStats extends StatefulWidget {
  NTUStats({
    super.key,
  });

  @override
  State<NTUStats> createState() => _NTUStatsState();
}

List<NtuData> GetAvg(Map<int, List<NtuData>> dateMap) {
  List<NtuData> avg = [];
  dateMap.forEach((key, value) {
    double avgPh = 0;
    value.forEach((element) {
      avgPh += element.ntu;
    });
    avgPh /= value.length;

    avg.add(NtuData(value.first.dt, avgPh));
  });
  return avg;
}

class _NTUStatsState extends State<NTUStats> {
  List<NtuData> data = [];
  List<NtuData> dataHours = [];
  List<NtuData> dataAvg = [];
  List<charts.Series<NtuData, String>> dataTemp = [];

  @override
  initState() {
    super.initState();
    fetchSensorValues().then((result) {
      setState(() {
        data = result.map((e) => NtuData(e.date, e.ntuValue)).toList();

        Map<int, List<NtuData>> dateMap = {};
        for (var dat in data) {
          if (!dateMap.containsKey(dat.dt.day)) {
            dateMap[dat.dt.day] = [];
          }

          dateMap[dat.dt.day]?.add(dat);
        }

        List<NtuData> dataHoursT = [];
        for (var d in data) {
          if (d.dt.day == data.first.dt.day) {
            dataHoursT.add(d);
          }
        }
        dataHours = dataHoursT;

        List<NtuData> avg = GetAvg(dateMap);
        dataAvg = avg;
        dataTemp = [
          charts.Series<NtuData, String>(
            id: 'ph',
            data: avg,
            domainFn: (NtuData temp, _) => getDateAsDayString(temp.dt),
            measureFn: (NtuData temp, _) => temp.ntu,
            colorFn: (_, __) => charts.Color.fromHex(code: '#5493e0AF'),
            labelAccessorFn: (NtuData temp, _) =>
                (temp.ntu.roundToDouble()).toString(),
          )
        ];
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5), // Adjust the left padding
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NtuInfo()),
                );
              },
              icon: const Icon(
                Icons.info,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          "NTU Diagramme",
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
                  interval: 3,
                  minimum: 0,
                  maximum: 24,
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
                  maximum: 10,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<NtuData, String>>[
                  SplineAreaSeries(
                    dataSource: dataHours,
                    xValueMapper: (NtuData data, _) =>
                        getDateAsHourString(data.dt),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
                    dataSource: dataHours,
                    xValueMapper: (NtuData data, _) =>
                        getDateAsHourString(data.dt),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
                  minimum: 0,
                  maximum: 31,
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
                  maximum: 10,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<NtuData, String>>[
                  SplineAreaSeries(
                    dataSource: dataAvg,
                    xValueMapper: (NtuData data, _) => data.dt.day.toString(),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
                    dataSource: dataAvg,
                    xValueMapper: (NtuData data, _) => data.dt.day.toString(),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
                  interval: 6,
                  minimum: 0,
                  maximum: 93,
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
                  maximum: 10,
                  isVisible: true,
                  borderColor: Colors.transparent,
                ),
                series: <ChartSeries<NtuData, String>>[
                  SplineAreaSeries(
                    dataSource: dataAvg,
                    xValueMapper: (NtuData data, _) => data.dt.day.toString(),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
                    dataSource: dataAvg,
                    xValueMapper: (NtuData data, _) => data.dt.day.toString(),
                    yValueMapper: (NtuData data, _) => data.ntu,
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
