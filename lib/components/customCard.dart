import 'package:flutter/material.dart';

class customCard extends StatelessWidget {
  final String title;
  final Function()? onTap;
  const customCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.only(left: 5),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download,color: Colors.blueAccent,size: 50,),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
