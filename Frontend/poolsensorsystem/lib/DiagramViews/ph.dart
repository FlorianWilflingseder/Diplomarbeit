import 'package:flutter/material.dart';
import 'package:poolsensorsystem/infoscreens/phinfo.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'chart_data.dart';

class PhData {
  final String day;
  final double phvalue;
  PhData(this.day, this.phvalue);
}




class PhStats extends StatefulWidget {
  PhStats({
    super.key,
  });

  @override
  State<PhStats> createState() => _PhStatsState();
}




class _PhStatsState extends State<PhStats> {
  late List<ChartData> data;

final List<charts.Series<PhData, String>> dataPh = [
  charts.Series<PhData, String>(
    id: 'ph-value',
    data: [
      PhData('Mo', 7.5),
      PhData('Di', 7.6),
      PhData('Mi', 7.2),
      PhData('Do', 7.8),
      PhData('Fr', 7.6),
      PhData('Sa', 7.8),
      PhData('So', 7.4),
    ],
    domainFn: (PhData temp, _) => temp.day,
    measureFn: (PhData temp, _) => temp.phvalue,
    colorFn: (_, __) => charts.Color.fromHex(code:'#5493e0AF'),
    labelAccessorFn: (PhData temp , _) => temp.phvalue.toString(),
  ),
];

  @override initState() {
    super.initState();
    data = [
      ChartData(1, 7.1),
      ChartData(2, 7.1),
      ChartData(3, 7.4),
      ChartData(4, 8),
      ChartData(5, 7.9),
      ChartData(6, 7.8),
      ChartData(7, 7.4),
      ChartData(8, 7.4),
      ChartData(9, 7.3),
      ChartData(10, 7.4),
      ChartData(11, 7.3),
      ChartData(12, 7.4),
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
                  MaterialPageRoute(builder: (context) => PhInfo()),
                );
              },
              icon: const Icon(Icons.info, size: 35, color: Colors.white,),
            ),
          ),
      ],
      title: Text(
        "Ph Diagramme",
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
                maximum: 9,
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
                    dataPh, 
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
                maximum: 9,
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
                maximum: 9,
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
