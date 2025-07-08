import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/model/logic.dart';

class FloatingButtonHapus extends StatelessWidget {
  const FloatingButtonHapus({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BerandaController>(context, listen: false);

    return FloatingActionButton(
      onPressed: () => controller.hapusDatabase(context),
      child: const Icon(Icons.delete),
    );
  }
}
