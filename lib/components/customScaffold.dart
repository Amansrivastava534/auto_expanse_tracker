import 'package:flutter/material.dart';


class CustomScaffold extends StatefulWidget {
  final String title;
  final Widget? body;
  final List<Widget>? appBarActions;
  final bool drawerDisable;
  const CustomScaffold({super.key, required this.title, this.body, this.appBarActions, this.drawerDisable = false});

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
            title: Text(widget.title),
            actions: widget.appBarActions,
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
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 10,),
                  Text("Settings")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

