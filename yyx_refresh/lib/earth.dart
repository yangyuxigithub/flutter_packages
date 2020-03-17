import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

/*
* 定义坐标系中心点
* */
double CX = (window.physicalSize.width / window.devicePixelRatio) * 0.5;
double CY = (window.physicalSize.height / window.devicePixelRatio) * 0.5;
/*
* 球体半径
* */
double R = (window.physicalSize.width / window.devicePixelRatio) * 0.5 - 30;


class Earth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EarthState();
  }
}

class EarthState extends State<Earth> {
  List<Offset> dataOfCircle;
  List<TDP> points;

  @override
  void initState() {
    super.initState();
    dataOfCircle = [];
    points = [];
    _calcLH(0);
    _calcUH(0);
    _animate();
  }

  @override
  void reassemble() {
    super.reassemble();
    _animate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          painter: EarthPainter(list: dataOfCircle),
        ),
      ),
    );
  }

  /*
  * 下半球的点
  * Lower hemisphere
  * */
  _calcLH(double dis) {

    double zOff = R;

    double r = sqrt(pow(R, 2) - pow(dis, 2));

    double angle = 0;
    double add = 2 * pi / 40;
    for (int i = 0; i <= 40; i++) {
      angle += add;
      var x = CX + r * sin(angle);
      var y = CY + r * cos(angle);
      var z = zOff - dis;
      TDP tdp = new TDP(x, y, z);
      points.add(tdp);
      dataOfCircle.add(tdp.project());
    }

    //递归
    if (dis < R) {
      dis = dis + 20;
      if (dis >= R) dis = R;
      _calcLH(dis);
    }

  }

  /*
  * 上半球的点
  * Upper hemisphere
  * */
  _calcUH(double dis) {

    double zOff = R;

    double r = sqrt(pow(R, 2) - pow(dis, 2));

    double angle = 0;
    double add = 2 * pi / 40;
    for (int i = 0; i <= 40; i++) {
      angle += add;
      var x = CX + r * sin(angle);
      var y = CY + r * cos(angle);
      var z = zOff + dis;
      TDP tdp = new TDP(x, y, z);
      points.add(tdp);
      dataOfCircle.add(tdp.project());
    }

    //递归
    if (dis < R) {
      dis = dis + 20;
      if (dis >= R) dis = R;
      _calcUH(dis);
    }

  }

  _animate() {

    dataOfCircle = [];

    double angle = pi / 360;
    for (TDP tdp in points) {
//      tdp.rotateZ(angle);
//      tdp.rotateY(angle);
      tdp.rotateX(pi / 6);
      dataOfCircle.add(tdp.project());
    }
    setState(() {});
    Future.delayed(Duration(milliseconds: 100), () {
      //_animate();
    });
  }
}

class EarthPainter extends CustomPainter {
  Size _size;
  Canvas _canvas;

  List<Offset> list;

  EarthPainter({this.list}) {}

  @override
  void paint(Canvas canvas, Size size) {
    _size = size;
    _canvas = canvas;

    Paint paint = new Paint()
      ..strokeWidth = 3
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPoints(PointMode.points, list, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/*
* 3D 坐标 表示点
* */
class TDP {

  //原始坐标点
  num x;
  num y;
  num z;

  final Visual _visual = new Visual();

  TDP(this.x, this.y, this.z)
      : assert(x != null),
        assert(y != null),
        assert(z != null);

  /*
  * 观察点A 观察 空间内的任一点G
  * 投射后的值（x, y）
  * x = (xG - xA) * zA / (zA - zG)
  * y = (yG - yA) * zA / (zA - zG)
  * */
  Offset project() {
    double dx = (x - _visual.x) * _visual.z / (_visual.z - z);
    double dy = (y - _visual.y) * _visual.z / (_visual.z - z);
    return new Offset(dx, dy);
  }

  /*
  * 绕Y轴旋转
  * 倍角公式计算偏移后的值
  * */
  rotateY(double angle) {

    var xo = x - CX;
    var zo = z - R;

    var _x = xo * cos(angle) + zo * sin(angle) + CX;
    var _y = y;
    var _z = zo * cos(angle) - xo * sin(angle) + R;

    x = _x;
    y = _y;
    z = _z;

  }

  /*
  * 绕Z轴旋转
  * */
  rotateZ(double angle) {
    //坐标点与环绕点的坐标距离
    var xo = x - CX;
    var yo = y - CY;

    var _x = xo * cos(angle) + yo * sin(angle) + CX;
    var _y = yo * cos(angle) - xo * sin(angle) + CY;
    var _z = z;

    x = _x;
    y = _y;
    z = _z;
  }

  /*
  * 绕X轴旋转
  * */
  rotateX(double angle) {

    var yo = y - CY;
    var zo = z - R;

    var _x = x;
    var _y = yo * cos(angle) + zo * sin(angle) + CY;
    var _z = zo * cos(angle) - yo * sin(angle) + R;

    x = _x;
    y = _y;
    z = _z;
  }
}

/*
* 投射的观察点
* */
class Visual {
  final double x = 0;
  final double y = 0;
  final double z = 300000;
}
