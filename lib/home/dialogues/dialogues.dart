import 'package:flutter/material.dart';
import '../../models/user_entry.dart';

void showManualEntryForm(BuildContext context, void Function(UserEntry) onSubmit) {
  final nameController = TextEditingController();
  final latController = TextEditingController();
  final lonController = TextEditingController();
  final popController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Manual Entry'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'City Name')),
            TextField(controller: latController, decoration: const InputDecoration(labelText: 'Latitude')),
            TextField(controller: lonController, decoration: const InputDecoration(labelText: 'Longitude')),
            TextField(controller: popController, decoration: const InputDecoration(labelText: 'Population'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(
       onPressed: () {
  final newEntry = UserEntry(
    cityName: nameController.text.trim(),
    latitude: double.tryParse(latController.text) ?? 0.0,
    longitude: double.tryParse(lonController.text) ?? 0.0,
    population: int.tryParse(popController.text) ?? 0,
  );
  
  onSubmit(newEntry);       
  Navigator.pop(context);  
},

          child: const Text('Submit'),
        )
      ],
    ),
  );
}
