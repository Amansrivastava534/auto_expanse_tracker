

import 'package:flutter/material.dart';

navigateToPage(Widget page,BuildContext context){
 return Navigator.push(context,
      MaterialPageRoute(builder: (_) => page));
}

navigateAndRemoveUntilPage(Widget page,BuildContext context){
  return Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => page), (
          route) => false);
}