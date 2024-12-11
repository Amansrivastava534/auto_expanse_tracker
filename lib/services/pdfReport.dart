import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> generatePDFReport(List<String> data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return pw.Text(data[index]);
        },
      ),
    ),
  );

  final directory = await getDownloadsDirectory();
  final file = File('${directory?.path}/report.pdf');
  await file.writeAsBytes(await pdf.save());
  print('PDF saved to ${file.path}');
}

Future<void> generateExcel(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var excel = Excel.createExcel(); // Create a new Excel document

  // Add a sheet for debits
  Sheet debitsSheet = excel['Debits'];
  debitsSheet.appendRow([/*'Type',*/ 'Amount',/* 'Description',*/ 'Date']);

  List<String>? encodedTransactions = prefs.getStringList('allTransactions');

  List<Map<String, dynamic>> _filteredTransactions;
  if (encodedTransactions != null) {
    // Decode each JSON string back to a Map<String, dynamic>
    _filteredTransactions = encodedTransactions
        .map((transaction) => jsonDecode(transaction) as Map<String, dynamic>)
        .toList();
  } else {
    _filteredTransactions = [];
  }

  for (var transaction in _filteredTransactions.where((t) => t['type'] == 'Debited')) {
    debitsSheet.appendRow([
      // transaction['type'],
      transaction['debitAmount'] ?? '',
      // transaction['body'] ?? '',
      transaction['date'],
    ]);
  }

  // Add a sheet for credits
  Sheet creditsSheet = excel['Credits'];
  creditsSheet.appendRow(['Type', 'Amount', 'Description', 'Date']);

  for (var transaction in _filteredTransactions.where((t) => t['type'] == 'Credited')) {
    creditsSheet.appendRow([
      // transaction['type'],
      transaction['creditAmount'] ?? '',
      // transaction['body'] ?? '',
      transaction['date'],
    ]);
  }

  // Save the file
  try {
    final directory = await getDownloadsDirectory();
    String filePath = "${directory?.path}/Transactions.xlsx";

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    print("Excel generated successfully:");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel generated successfully: $filePath")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error generating Excel: $e")),
    );
  }
}


