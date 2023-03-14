import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:poolsensorsystem/chart.dart';

import 'model/chart_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoolOverview',
      theme: ThemeData(

        useMaterial3: true,
        colorSchemeSeed: Colors.blue[700],
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late double temperature = 0.0;

  Future<void> getData() async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=Berlin&appid=YOUR_API_KEY'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = data['main']['temp'] - 273.15;
      });
    } else {
      //show a snakcbar error
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 38, 82),
        title: Text("PoolOverview",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20), // Adjust the left padding
            child: IconButton(
              onPressed: () {
                getData();
              },
              icon: const Icon(Icons.refresh, size: 40, color: Colors.white,),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DataCard(
              title: "23 °C",
              subtitle: 'Temperatur',
              icon: Icons.device_thermostat,
              primary: const Color(0xFF4EA8DE),
              secondary: const Color.fromARGB(73, 78, 167, 222),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TemperaturStats()),
                );
              },
            ),
            DataCard(
              title: '7 Ph',
              subtitle: 'Ph-Wert',
              icon: Icons.water_drop,
              primary: const Color(0xFF64DFDF),
              secondary: const Color.fromARGB(66, 100, 223, 223),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhStats()),
                );
              },
            ),
            DataCard(
              title: '2 NTU',
              subtitle: 'Trübung',
              icon: Icons.lens_blur,
              primary: const Color(0xFF5390D9),
              secondary: const Color.fromARGB(68, 83, 143, 217),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NTUStats()),
                );
              },
            ),
            DataCard(
              title: 'ON',
              subtitle: 'Alarm',
              icon: Icons.notifications,
              primary: const Color(0xFF5E60CE),
              secondary: const Color.fromARGB(59, 94, 96, 206),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      elevation: 0.0, 
      title: Text("Temperatur Diagramme",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,),
        ),
      ),
      body: Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("1 Year",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 40,
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
              labelStyle:  const TextStyle(color: Colors.white),
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
              labelStyle:  const TextStyle(color: Colors.white),
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
                ),
                SplineSeries(
                  dataSource: data, 
                  xValueMapper: (ChartData data,_) =>data.month,
                  yValueMapper: (ChartData data, _) => data.temperature,
                  color: Color.fromARGB(255, 121, 123, 245),
                  width: 4,
                  markerSettings: const MarkerSettings(
                    color: Colors.white, 
                    borderWidth: 2, 
                    shape: DataMarkerType.circle, 
                    isVisible: true, 
                    borderColor: Colors.white),
                  )             
              ],
          ),
        ),
      ],
      ),

    );
          
  }
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
      title: Text("Ph-Value over Time",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,),
        ),
      ),
      body: Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          Text("Ph-Value",
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






class NTUStats extends StatefulWidget {


  NTUStats({
    super.key,
  });

  @override
  State<NTUStats> createState() => _NTUStatsState();
}

class _NTUStatsState extends State<NTUStats> {
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
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      elevation: 0.0, 
      title:  Text("NTU",
        style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,),
        ),
      ),
      body: Column( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("NTU",
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














class DataCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final VoidCallback onPressed;

  const DataCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: secondary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          trailing: Icon(
            icon,
            size: 120,
            color: primary,
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(7, 40, 0, 0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: primary,
                fontSize: 60,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(7, 0, 0, 15),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
