import 'package:flutter/material.dart';
import 'package:sms_tracker1/screens/pdf_excell_generate.dart';

import '../components/customCard.dart';
import '../components/customScaffold.dart';
import '../services/pdfReport.dart';
import '../utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title:"Settings",
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: customCard(
          title: "Pdf/Excel Generate",
          onTap: () async {
            navigateToPage(GenerateReport(),context);
            // await generateExcel(context);
          },
        ),
      ),
    );
  }
}
