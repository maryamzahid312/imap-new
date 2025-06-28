import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/user_entry.dart';
import 'dart:convert';

class FileUtils {
  static Future<List<UserEntry>> pickAndParseFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final ext = file.path.split('.').last.toLowerCase();
        final content = await file.readAsString();

        if (ext == 'json') {
          final List<dynamic> jsonList = jsonDecode(content);
          return jsonList.map((e) => UserEntry.fromJson(e)).toList();
        } else if (ext == 'csv') {
          final csvList = const CsvToListConverter().convert(content, eol: '\n');
          return csvList.skip(1).map((e) => UserEntry.fromCsv(e.map((e) => e.toString()).toList())).toList();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    return [];
  }
}
