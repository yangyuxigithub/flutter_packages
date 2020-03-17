import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class RefreshHeader extends StatefulWidget {
  final Size size;

  const RefreshHeader({Key key, this.size}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RefreshHeaderState();
  }
}

class RefreshHeaderState extends State<RefreshHeader> {

  List balls = [];

  @override
  void initState() {
    super.initState();
    _createBalls();
    _drop();
  }

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      painter: _Painter(balls: balls),
      size: widget.size,
    );
  }

  _createBalls() {

    var width = widget.size.width - MARGIN * 2;

    if (balls.length >= 50) {
      balls.removeAt(0);
    }

    var y = Random().nextInt(5);
    var sX = (width * 0.5) * (MAXHEIGHT - y) / MAXHEIGHT;
    sX = MARGIN + width * 0.5 - sX;
    var x = sX + Random().nextInt(width.floor());
    var z = 0;
    Ball ball = new Ball(x: x, y: y, z: z);
    balls.add(ball);

    Future.delayed(Duration(milliseconds: 100), () {
      _createBalls();
      setState(() {});
    });
  }

  _drop() {

    List list = [];
    list.addAll(balls);

    for (Ball ball in list) {
      ball._drop();
    }
    Future.delayed(Duration(milliseconds: 50), () {
      _drop();
      setState(() {});
    });
  }
}

double MARGIN = 80;
double MAXHEIGHT = 120;
double WIDTH = (window.physicalSize.width / window.devicePixelRatio) - MAXHEIGHT * 2;

class _Painter extends CustomPainter {

  final List balls;
  _Painter({this.balls});

  Canvas _canvas;
  Size _size;

  @override
  void paint(Canvas canvas, Size size) {

    if (size.height < 10) return;

    _canvas = canvas;
    _size = size;

    _drawBg();

    _drawBalls();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  _drawBg() {
    double width = _size.width - MARGIN * 2;
    double height = _size.height;
    if (height > MAXHEIGHT) height = MAXHEIGHT;

    /*
    * 中心点渐变
    * */
    Gradient gradient = RadialGradient(
      center: const Alignment(0, -0.5),
      radius: 1.0,
      colors: [
        const Color(0xff1B224B),
        const Color(0x330099FF),
      ],
      stops: [0.4, 1],
    );

    Paint paint = new Paint()
      ..strokeWidth = 1
      ..color = Color(0xff1B224B)
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(Rect.fromLTWH((_size.width - width) * 0.5, 0, width, _size.height));

    Path path = new Path()..moveTo((_size.width - width) * 0.5, 0);

    Offset control = new Offset(_size.width * 0.5, height * 2);
    Offset end = new Offset(_size.width - (_size.width - width) * 0.5, 0);

    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    _canvas.drawPath(path, paint);
  }


  _drawBalls() {

    Paint paint = new Paint()..style = PaintingStyle.fill..color = Colors.red;

    for (Ball ball in balls) {
      Offset p = ball.project();
      _canvas.drawCircle(p, ball.r, paint);
    }
  }
}


/*
* 3D 坐标 表示点
* */
class Ball {

  Color _color;
  double _alpha;
  double _r = 0;
  get r => _r;

  final endY;

  //坐标点
  num x;
  num y;
  num z;

  //初始坐标点
  num xo;
  num yo;
  num zo;

  final Visual _visual = new Visual();

  Ball({this.x, this.y, this.z, this.endY})
      : assert(x != null),
        assert(y != null),
        assert(z != null) {
    xo = x;
    yo = y;
    zo = z;
    //_drop();
    _r = Random().nextInt(4) + 0.0;
  }

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
  * 绕Z轴旋转
  * */
  rotateZ(double angle, Offset center) {
    //坐标点与环绕点的坐标距离
    var xo = x - center.dx;
    var yo = y - center.dy;

    var _x = xo * cos(angle) + yo * sin(angle) + center.dx;
    var _y = yo * cos(angle) - xo * sin(angle) + center.dy;
    var _z = z;

    x = _x;
    y = _y;
    z = _z;
  }

  _drop() {

    y += 5;

    if (y >= MAXHEIGHT) y = MAXHEIGHT;

  }

  breath() {

    if (_r <= 2) {
      _r++;
    }

    if (_r > 10) {
      _r--;
    }

    print(_r);

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