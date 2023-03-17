import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../infoscreens/ntuinfo.dart';
import 'chart_data.dart';

class NtuData {
  final String day;
  final double ntu;
  NtuData(this.day, this.ntu);
}

class NTUStats extends StatefulWidget {


  NTUStats({
    super.key,
  });

  @override
  State<NTUStats> createState() => _NTUStatsState();
}

class _NTUStatsState extends State<NTUStats> {
  late List<ChartData> data;

  final List<charts.Series<NtuData, String>> dataNtu = [
  charts.Series<NtuData, String>(
    id: 'ntu-value',
    data: [
      NtuData('Mo', 0.5),
      NtuData('Di', 0.6),
      NtuData('Mi', 0.2),
      NtuData('Do', 0.3),
      NtuData('Fr', 0.4),
      NtuData('Sa', 0.3),
      NtuData('So', 0.2),
    ],
    domainFn: (NtuData temp, _) => temp.day,
    measureFn: (NtuData temp, _) => temp.ntu,
    colorFn: (_, __) => charts.Color.fromHex(code:'#5493e0AF'),
  ),
];
  @override initState() {
    super.initState();
    data = [
      ChartData(1, 1),
      ChartData(2, 3),
      ChartData(3, 4),
      ChartData(4, 4),
      ChartData(5, 3),
      ChartData(6, 3),
      ChartData(7, 2),
      ChartData(8, 3),
      ChartData(9, 2),
      ChartData(10, 3),
      ChartData(11, 2),
      ChartData(12, 1),
    ];
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
              icon: const Icon(Icons.info, size: 40, color: Colors.white,),
            ),
          ),
      ], 
      title: Text(
        "NTU-Diagramme",
          style: GoogleFonts.poppins(
          color:Colors.white,
          fontSize: 25,
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
                maximum: 10,
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
                    dataNtu, 
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
                maximum: 10,
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
            "1 Jahr",
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
                maximum: 10,
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
