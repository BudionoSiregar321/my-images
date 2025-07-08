import 'package:flutter/material.dart';

class Halamancheckout extends StatelessWidget {
  const Halamancheckout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Halaman checkOut Belum bisa digunakan,",style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          Text("Programer masih pemula.",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    )
    );
  }
}