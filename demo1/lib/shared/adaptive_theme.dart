import 'package:flutter/material.dart';

final ThemeData androidTheme = ThemeData(
  brightness: Brightness.dark,
  //fontFamily: 'Oswald'
);

final ThemeData iosTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.grey
  //fontFamily: 'Oswald'
);

ThemeData getAdaptiveThemeData(BuildContext context){
  return Theme.of(context).platform == TargetPlatform.android ?  androidTheme : iosTheme;
}