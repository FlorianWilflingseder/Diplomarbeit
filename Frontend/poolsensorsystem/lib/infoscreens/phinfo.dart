


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PhInfo extends StatefulWidget {
  PhInfo({
    super.key,
  });
  @override
  State<PhInfo> createState() => _PhInfo();
}

class _PhInfo extends State<PhInfo> {

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 37, 38, 82),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      elevation: 0.0, 
      title: Text(
        "Ph-Wert Info",
          style: GoogleFonts.poppins(
          color:Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body:
    Padding(
      padding: const EdgeInsets.all(25),
      child: Text(
      "Der pH-Wert ist ein Maß für den sauren oder basischen Charakter einer wässrigen Lösung. \nMan nennt eine verdünnte wässrige Lösung mit einem pH-Wert von weniger als 7 sauer, mit einem pH-Wert gleich 7 neutral und mit einem pH-Wert von mehr als 7 basisch bzw. alkalisch.\nDer pH-Wert von Wasser liegt normalerweise ziwschen 7 - 8.5.",
      style: GoogleFonts.poppins(
        color:Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
       ),
      ),
    ),
    
  );
}

}