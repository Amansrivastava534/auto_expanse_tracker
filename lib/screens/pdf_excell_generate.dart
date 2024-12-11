import 'package:flutter/material.dart';
import 'package:sms_tracker1/components/customScaffold.dart';

class GenerateReport extends StatefulWidget {
  const GenerateReport({super.key});

  @override
  State<GenerateReport> createState() => _GenerateReportState();
}

class _GenerateReportState extends State<GenerateReport> {
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(title: "Report");
  }
}
