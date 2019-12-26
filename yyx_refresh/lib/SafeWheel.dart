import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class SafeWheel extends StatefulWidget {

  final Size size;
  final Function onValue;

  const SafeWheel({Key key, this.size, this.onValue})
      : assert(size != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SafeWheelState();
  }
}

class SafeWheelState extends State<SafeWheel> with TickerProviderStateMixin {

  AnimationController _controller;

  double angle = 0;
  double preAngle;
  Offset preOffset;
  Offset startOffset;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent, width: 1),
              color: Colors.transparent),
          child: CustomPaint(
            painter: WheelPainter(),
            size: widget.size,
          ),
        ),
      ),
      onVerticalDragStart: (DragStartDetails details) {
        startOffset = details.localPosition;
        preOffset = details.localPosition;
        preAngle = angle;
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        _calc(details.localPosition);
      },
      onVerticalDragEnd: (DragEndDetails details) {},
    );
  }

  /*
  * 计算角度
  * */
  _calc(Offset cOffset) {
    Offset pa = preOffset;
    Offset pb = cOffset;
    Offset pc = Offset(widget.size.width * 0.5, widget.size.height * 0.5);

    double a2 = pow((pb.dx - pc.dx), 2) + pow((pb.dy - pc.dy), 2);
    double b2 = pow((pa.dx - pc.dx), 2) + pow((pa.dy - pc.dy), 2);
    double c2 = pow((pa.dx - pb.dx), 2) + pow((pa.dy - pb.dy), 2);

    double cosC = (a2 + b2 - c2) / (2 * sqrt(a2) * sqrt(b2));

    double add = acos(cosC);
    if (add.isNaN) return;
    if (cOffset.dy >= preOffset.dy) {
      if (preOffset.dx < widget.size.width * 0.5) {
        angle -= add;
      } else {
        angle += add;
      }
    } else {
      if (preOffset.dx < widget.size.width * 0.5) {
        angle += add;
      } else {
        angle -= add;
      }
    }

    preOffset = cOffset;

    setState(() {});

    _output();
  }

  /*
  * 输出结果
  * */
  _output() {
    double d = 100 / pi;
    double s = angle % pi;
    int n = 100 - int.parse((d * s).toStringAsFixed(0));
    if (widget.onValue != null) {
      widget.onValue(n);
    }
  }

}

/*
* 组件  轮子
* */
class WheelPainter extends CustomPainter {
  Canvas _canvas;
  Size _size;

  Offset _dialCenter;
  double _dialRadius;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    _size = size;

    _dialCenter = Offset(_size.width * 0.5, _size.height * 0.5);
    _dialRadius = _size.width * 0.5;

    //外圈圆环
    _drawOuterRing();

    _drawCalibration();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /*
  * 外圈圆环
  * */
  _drawOuterRing() {
    Paint paint = new Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFFCA2655)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    _canvas.drawCircle(_dialCenter, _dialRadius, paint);
  }

  /*
  * 刻度
  * */
  _drawCalibration() {
    Paint paint = new Paint()
      ..style = PaintingStyle.stroke
      ..color = Color(0xFF473037)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double r = _dialRadius - 5;
    //圆的中心点
    double a = _dialCenter.dx;
    double b = _dialCenter.dy;

    double m = _dialCenter.dx;

    double x = m; // x = m
    double y;

    y = b + sqrt(pow(r, 2) - pow((m - a), 2));
    Offset ps = Offset(x, y);
    y = b - sqrt(pow(r, 2) - pow((m - a), 2));
    Offset pe = Offset(x, y);

    //_canvas.drawLine(ps, pe, paint);

    List<Offset> longNeedles = [];

    double angle = 0;
    double add = 2 * pi / 360;
    for (int i = 0; i <= 360; i++) {
      angle += add;
      ps = Offset(a, b);

      x = a + r * sin(angle);
      y = b + r * cos(angle);
      pe = Offset(x, y);

      if (i % 10 == 0) {
        longNeedles.add(pe);
      } else {
        _canvas.drawLine(ps, pe, paint);
      }
    }

    Paint whiteDialPaint = new Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xFF1D1617);
    _canvas.drawCircle(_dialCenter, r - 12, whiteDialPaint);

    for (Offset pe in longNeedles) {
      ps = Offset(a, b);
      _canvas.drawLine(ps, pe, paint);
    }

    _canvas.drawCircle(_dialCenter, r - 22, whiteDialPaint);
  }
}
