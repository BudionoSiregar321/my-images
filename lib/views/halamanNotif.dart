import 'package:flutter/material.dart';

class Halamannotif extends StatefulWidget {
  const Halamannotif({super.key});

  @override
  State<Halamannotif> createState() => _HalamannotifState();
}

class _HalamannotifState extends State<Halamannotif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 86, 154, 255),
       title: const Text('kembali'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          ListTile(
            leading: Icon(Icons.mail_outline_sharp, size: 50,color: const Color.fromARGB(255, 109, 189, 255),),
            title: Text("Kami menyambut anda", style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20, color: Color.fromARGB(255, 49, 163, 255)),),
            subtitle: Text("Aplikasi masih dalam tahap pengembangan.")
          ),
        ],
      ),
    );
  }
}