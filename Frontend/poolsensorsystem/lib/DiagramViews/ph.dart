import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chart_data.dart';

class PhStats extends StatefulWidget {


  PhStats({
    super.key,
  });

  @override
  State<PhStats> createState() => _PhStatsState();
}

class _PhStatsState extends State<PhStats> {
  late List<ChartData> data;

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
      backgroundColor:  const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      elevation: 0.0, 
      title: Text("Ph-Wert Diagramme",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,),
        ),
      ),
      body: Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          Text("1- Jahr",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,),
        ),
        const SizedBox(height: 20,),
        Center(
          child: SfCartesianChart(
            margin: const EdgeInsets.all(0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            plotAreaBorderWidth: 0,
            primaryXAxis: NumericAxis(
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
                SplineAreaSeries(dataSource: data, 
                xValueMapper: (ChartData data,_) =>data.month,
                 yValueMapper: (ChartData data, _) => data.temperature, 
                 splineType: SplineType.natural,
                 gradient: LinearGradient(colors: [
                  const Color.fromARGB(255, 84, 147, 224), 
                 const Color.fromARGB(255, 37, 38, 82).withAlpha(150),
                 ] ,
                 begin: Alignment.topCenter,
                 end: Alignment.bottomCenter,
                 ),
                )               
              ],
          ),
        ),
      ],
      ),

    );
          
  }
}
