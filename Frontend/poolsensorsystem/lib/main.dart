import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:poolsensorsystem/chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        print("done");
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
      appBar: AppBar(
        title: const Text(
          'Pool Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20), // Adjust the left padding
            child: IconButton(
              onPressed: () {
                getData();
                print("reload");
              },
              icon: Icon(Icons.refresh, size: 40),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DataCard(
              title: temperature.toStringAsFixed(1),
              subtitle: 'Temperatur',
              icon: Icons.device_thermostat,
              primary: const Color(0xFF4EA8DE),
              secondary: const Color.fromARGB(73, 78, 167, 222),
              onPressed: () {
                print('Pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page1()),
                );
              },
            ),
            DataCard(
              title: '7 Ph',
              subtitle: 'Ph-Wert',
              icon: Icons.water_drop,
              primary: const Color(0xFF64DFDF),
              secondary: Color.fromARGB(66, 100, 223, 223),
              onPressed: () {
                print('Pressed');
              },
            ),
            DataCard(
              title: '2',
              subtitle: 'Trübung',
              icon: Icons.lens_blur,
              primary: const Color(0xFF5390D9),
              secondary: Color.fromARGB(68, 83, 143, 217),
              onPressed: () {
                print('Pressed');
              },
            ),
            DataCard(
              title: 'ON',
              subtitle: 'Alarm',
              icon: Icons.notifications,
              primary: const Color(0xFF5E60CE),
              secondary: const Color.fromARGB(59, 94, 96, 206),
              onPressed: () {
                print('Pressed');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test1'),
      ),
      body: Column(
        children: [
          LineChartSample2(),
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
          contentPadding: EdgeInsets.fromLTRB(25, 0, 25, 0),
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
