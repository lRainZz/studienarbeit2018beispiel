import 'package:flutter/material.dart';
import 'cityOverview.dart';
import 'activeCity.dart';

void main() => runApp(new MainApp());

class MainApp extends StatefulWidget {

  @override
  createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new ActiveCity(),
        routes: <String, WidgetBuilder> {
          '/activeCity':   (BuildContext context) => new ActiveCity(),
          '/cityOverview': (BuildContext context) => new CityOverview(),
        }
    );
  }
}