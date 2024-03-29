import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'DiagramViews/temperature.dart';
import 'DiagramViews/ntu.dart';
import 'DiagramViews/ph.dart';
import '../data/dataReciever.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PoolOverview',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue[700],
      ),
      home: const MyWidget(),
    );
  }
}

Future<List<Data>> fetchSensorValues() async {
  final response = await http.get(Uri.parse("http://192.168.8.102/api/status"));

  if (response.statusCode == 200) {
    List<Data> values = [];
    List<String> lines = response.body.split('\n');

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

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late String temperature = '';
  late String ph = '';
  late String ntu = '';
  IconData alarmIcon = Icons.notifications;
  String onOrOff = "ON";

  @override
  void initState() {
    super.initState();
    fetchSensorValues().then((value) {
      setState(() {
        temperature = value.last.temperature.round().toString();
        ph = value.last.phValue.toString();
        ntu = value.last.ntuValue.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 38, 82),
        title: Text(
          "PoolOverview",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 20), // Adjust the left padding
            child: IconButton(
              onPressed: () {
                fetchSensorValues().then((value) {
                  setState(() {
                    temperature = value.last.temperature.round().toString();
                    ph = value.last.phValue.toString();
                    ntu = value.last.ntuValue.toString();
                  });
                });
              },
              icon: const Icon(
                Icons.refresh,
                size: 40,
                color: Colors.white,
              ),
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
              title: "$temperature°C",
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
              title: ph,
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
              title: ntu,
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
              title: onOrOff,
              subtitle: 'Alarm',
              icon: alarmIcon,
              primary: const Color(0xFF64DFDF), //const Color(0xFF5E60CE)
              secondary: const Color.fromARGB(
                  66, 100, 223, 223), // const Color.fromARGB(59, 94, 96, 206)
              onPressed: () {
                setState(() {
                  if (alarmIcon == Icons.notifications) {
                    // update icon
                    alarmIcon = Icons.notifications_off;
                    onOrOff = "OFF";
                  } else {
                    alarmIcon = Icons.notifications;
                    onOrOff = "ON";
                  }
                });
              },
            ),
          ],
        ),
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
                fontSize: 70,
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
                fontSize: 20,
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
