import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NtuInfo extends StatefulWidget {
  NtuInfo({
    super.key,
  });
  @override
  State<NtuInfo> createState() => _NtuInfo();
}

class _NtuInfo extends State<NtuInfo> {

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 37, 38, 82),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 37, 38, 82),
      elevation: 0.0, 
      title: Text(
        "NTU Info",
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
      "Typische NTU Werte\nTrinkWasser: 0.01-0.5\nQuellWasser: 0.5-10\nAbwasser(ungeklärt): 70-2000\nFormazin: 4000",
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