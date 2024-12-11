import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_tracker1/utils.dart';
import 'components/customScaffold.dart';
import 'screens/cardDetailsPage.dart';
import 'screens/expanseTrackerPage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CustomHome(),
    );
  }
}

class CustomHome extends StatefulWidget {
  const CustomHome({super.key});

  @override
  State<CustomHome> createState() => _CustomHomeState();
}

class _CustomHomeState extends State<CustomHome> {

  @override
  void initState() {
    getSharedPrefData();
    super.initState();
  }

  getSharedPrefData()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? savedCards = prefs.getStringList('savedCards');

    if(savedCards == null ||  savedCards.isEmpty){
      navigateAndRemoveUntilPage(CardSaverPage(),context);
    }
    else{
      navigateAndRemoveUntilPage(const ExpenseTrackerPage(),context);
    }

  }
  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(title: "");
  }
}


