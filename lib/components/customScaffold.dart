import 'package:flutter/material.dart';

import '../screens/cardDetailsPage.dart';
import '../screens/expanseTrackerPage.dart';
import '../screens/settingPage.dart';
import '../utils.dart';


class CustomScaffold extends StatefulWidget {
  final String title;
  final Widget? body;
  final List<Widget>? appBarActions;
  final bool drawerDisable;
  final PreferredSizeWidget? bottom;
  const CustomScaffold({super.key, required this.title, this.body, this.appBarActions, this.drawerDisable = false, this.bottom});

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: widget.drawerDisable ? null : const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.blueAccent.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: Colors.blueAccent.shade200)
            ),
            title: Text(widget.title),
            actions: widget.appBarActions,
            bottom: widget.bottom,
          ),
          body: widget.body,

        ));
  }
}


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,10,0,0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  icon: Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  }),
            ),
            InkWell(
              onTap: (){
                navigateAndRemoveUntilPage(ExpenseTrackerPage(),context);
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.home_filled),
                    SizedBox(width: 10,),
                    Text("Home")
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                navigateAndRemoveUntilPage(CardSaverPage(),context);
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10,),
                    Text("Manage Cards")
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                navigateAndRemoveUntilPage(const Settings(),context);
              },
              child: const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10,),
                    Text("Settings")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

