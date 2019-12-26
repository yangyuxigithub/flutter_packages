import 'package:flutter/material.dart';

import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'DragSortWidget.dart';
import 'SafeWheel.dart';
import 'WheelSelectPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WheelSelectPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF1D1617),
        padding: EdgeInsets.only(top: 20),
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            Positioned(
              top: 84,
              right: -450,
              child: SafeWheel(),
            )
          ],
        )
      ),
    );
  }
}
