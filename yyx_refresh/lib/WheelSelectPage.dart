import 'dart:ui';
import 'package:flutter/material.dart';
import 'SafeWheel.dart';
import 'dart:math';

class WheelSelectPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    return WheelSelectPageState();
  }

}

class WheelSelectPageState extends State<WheelSelectPage> {

  double right = (window.physicalSize.width / window.devicePixelRatio) * 0.3;
  double r;
  double l;
  double p = 150;
  double m;

  String value = '00';

  @override
  void initState() {
    super.initState();
    l = (window.physicalSize.height / window.devicePixelRatio) - p * 2;
    l = l / 2.0;
    r = (pow(right, 2) + pow(l, 2)) / (2 * right);
    m = r - l;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF1D1617),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -(2 * r - right),
              top: p - m,
              child: SafeWheel(
                size: Size(2 * r, 2 * r),
                onValue: (int v) {
                    setState(() {
                      value = v.toString();
                      if (value.length <= 1) {
                        value = '0' + value;
                      }
                    });
                },
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width - right,
                child: Center(
                  child: Text('$value', style: TextStyle(inherit: false, color: Colors.white, fontSize: 100),),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

}