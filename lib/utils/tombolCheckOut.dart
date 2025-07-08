import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/db.dart';
import 'package:flutter_application_1/views/halamanCheckOut.dart';

class TombolCheckOut extends StatelessWidget {
  const TombolCheckOut({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      onPressed: () async {
        final bool online = await DatabaseHandler().isOnline();
        if (!context.mounted) return;

        if (online) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => Halamancheckout()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Harus Online Terlebih Dahulu Untuk Checkout'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const Text(
        "Check Out",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }
}
