import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chart_data.dart';
import 'package:charts_flutter/flutter.dart' as charts;


class TemperatureData {
  final String day;
  final String month;
  final int temperature;

  TemperatureData(this.day, this.month, this.temperature);
}


class TemperaturStats extends StatefulWidget {
  TemperaturStats({
    super.key,
  });
  @override
  State<TemperaturStats> createState() => _TemperaturStatsState();
}

class _TemperaturStatsState extends State<TemperaturStats> {
  late List<ChartData> data;
  


Future<String> getJsonFromAssets() async {
  return await rootBundle.loadString('assets/temperature.json');
}


final List<charts.Series<TemperatureData, String>> dataTemp = [
  charts.Series<TemperatureData, String>(
    id: 'temperature',
    data: [
      TemperatureData('Mo','Jan', 20),
      TemperatureData('Di','Jan', 22),
      TemperatureData('Mi','Jan', 25),
      TemperatureData('Do','Jan', 24),
      TemperatureData('Fr','Jan', 35),
      TemperatureData('Sa','Jan', 21),
      TemperatureData('So','Jan', 22),
    ],
    domainFn: (TemperatureData temp, _) => temp.day,
    measureFn: (TemperatureData temp, _) => temp.temperature,
    colorFn: (_, __) => charts.Color.fromHex(code:'#5493e0AF'),
    labelAccessorFn: (TemperatureData temp,_) => temp.temperature.toString(),
  ),
];

  @override initState() {
    super.initState();
    data = [
      ChartData(1, 0),
      ChartData(2, 2),
      ChartData(3, 5),
      ChartData(4, 8),
      ChartData(5, 12),
      ChartData(6, 18),
      ChartData(7, 22),
      ChartData(8, 30),
      ChartData(9, 27),
      ChartData(10, 15),
      ChartData(11, 5),
      ChartData(12, 0),
    ];
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
          color:Colors.white,
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
              color:Colors.white,
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
              primaryXAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
                majorTickLines: const MajorTickLines(
                  color: Colors.transparent,
                ),
                axisLine: const AxisLine(
                  color: Colors.transparent,
                ),
                minimum: 1,
                maximum: 12,
                isVisible: true,
                borderColor: Colors.transparent,
                interval: 3,
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
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
              series: <ChartSeries<ChartData,int>>[
                SplineAreaSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature, 
                  splineType: SplineType.natural,
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 84, 147, 224), 
                      const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                    ] ,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      color: Colors.white
                      
                    ),
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
              color:Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
            SizedBox(
            height: 300,
            child : Card(
            color: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding :  const EdgeInsets.all(8),
              child: Column(
                children: <Widget> [
                  Expanded(
                  child: charts.BarChart(
                    dataTemp, 
                    animate: true,
                    defaultRenderer: charts.BarRendererConfig(
                      cornerStrategy: const charts.ConstCornerStrategy(30),
                      maxBarWidthPx: 20,  
                        barRendererDecorator: charts.BarLabelDecorator<String>(
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
              color:Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20,),
          Center(
            child: SfCartesianChart(
              margin: const EdgeInsets.all(0),
              borderWidth: 0,
              borderColor: Colors.transparent,
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
                majorTickLines: const MajorTickLines(
                  color: Colors.transparent,
                ),
                axisLine: const AxisLine(
                  color: Colors.transparent,
                ),
                minimum: 1,
                maximum: 12,
                isVisible: true,
                borderColor: Colors.transparent,
                interval: 3,
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
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
              series: <ChartSeries<ChartData,int>>[
                SplineAreaSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature, 
                  splineType: SplineType.natural,
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 84, 147, 224), 
                      const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                    ] ,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature,
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
              color:Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20,),
          Center(
            child: SfCartesianChart(
              margin: const EdgeInsets.all(0),
              borderWidth: 0,
              borderColor: Colors.transparent,
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
                majorTickLines: const MajorTickLines(
                  color: Colors.transparent,
                ),
                axisLine: const AxisLine(
                  color: Colors.transparent,
                ),
                minimum: 1,
                maximum: 12,
                isVisible: true,
                borderColor: Colors.transparent,
                interval: 3,
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.white),
                majorGridLines: const MajorGridLines(
                  color: Colors.transparent,
                ) ,
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
              series: <ChartSeries<ChartData,int>>[
                SplineAreaSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature, 
                  splineType: SplineType.natural,
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 84, 147, 224), 
                      const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                    ] ,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                SplineSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature,
                  color:  const Color.fromARGB(255, 121, 123, 245),
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


