import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ParticleText extends StatefulWidget {

  final double height;
  final String text;

  const ParticleText({Key key, this.text, this.height}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ParticleTextState();
  }

}

class ParticleTextState extends State<ParticleText> {

  List<Particle> _particles;

  final Size _size = Size(window.physicalSize.width / window.devicePixelRatio, 60);

  @override
  void initState() {
    super.initState();
    _calcText(widget.text);
  }

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      size: Size(_size.width, widget.height),
      foregroundPainter: ParticleTextPainter(_particles),
      child: Container(
        color: Colors.black26,
      ),
    );

  }

  /*
  * 计算文本数据
  * */
  _calcText(String text) async {

    if (text == null || text == '') {
      setState(() {
        _particles = [];
      });
      return;
    }

    //偏移量
    double dx = 10;
    double dy = 40;

    double width = _size.width;

    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, 60));
    canvas.drawPaint(Paint()..color = Color.fromRGBO(0, 0, 0, 0));

    TextSpan span = new TextSpan(
        style: TextStyle(fontSize: 60, color: Colors.red), text: text);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(0, 0));

    dx = (width - tp.size.width) / 2;

    Picture picture = recorder.endRecording();
    ui.Image image = await picture.toImage(width.round(), 70);
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    Uint8ClampedList list = data.buffer.asUint8ClampedList();

    List<Particle> particles = [];
    double x = 0;
    double y = 0;

    x += dx; y += dy;

    int cursor = 0;

    List rgba = [];

    /*找到所有有颜色的点*/
    list.forEach((v) {
      rgba.add(v);
      cursor++;
      if (cursor == 4) {
        cursor = 0;
        if (v != 0) {
          particles.add(Particle(x, y));
        }

        rgba = [];
        x++;

        if (x >= width) {
          x = 0;
          y++;
        }
      }
    });
    /*筛选 粗化*/
    double minX, minY, maxX, maxY;
    particles.forEach((v) {
      if (minX == null) {
        minX = v.x;
      } else {
        if (minX > v.x) minX = v.x;
      }
      ;

      if (minY == null) {
        minY = v.y;
      } else {
        if (minY > v.y) minY = v.y;
      }
      ;

      if (maxX == null) {
        maxX = v.x;
      } else {
        if (maxX < v.x) maxX = v.x;
      }
      ;

      if (maxY == null) {
        maxY = v.y;
      } else {
        if (maxY < v.y) maxY = v.y;
      }
      ;
    });

    int step = 3;
    List<Particle> result = [];
    double c = minX;
    while (c <= maxX) {
      particles.forEach((v) {
        if (v.x == c) {
          result.add(v);
        }
      });
      c += step;
    }

    particles = result;
    c = minY;
    result = [];

    while (c <= maxY) {
      particles.forEach((v) {
        if (v.y == c) {
          result.add(v);
        }
      });
      c += step;
    }

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _particles = result;
      });
    });
  }

  /*
  * 爆炸
  * */
  Timer _bombTimer;
  bomb() {
    Size size = Size(_size.width, widget.height);
    _particles.forEach((Particle p) {
      p.bomb(size);
    });

    if (_bombTimer != null) {
      _bombTimer.cancel();
      _bombTimer = null;
    }

    int step = 0;
    _bombTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {

        _particles.forEach((Particle p) {
          p.tx += (p.bx - p.x) / 100;
          p.ty += (p.by - p.y) / 100;
          p.tz += (p.bz - p.z) / 100;
        });

        setState(() {

        });

        step ++;
        if (step >= 99) {
          timer.cancel();
          _bombTimer = null;
          _gather();
        }
    });
  }

  /*
  * 聚拢
  * */
  Timer _gatherTimer;
  _gather() {

    double dx = _size.width * 0.5;
    double dy = widget.height * 0.5;

    if (_gatherTimer != null) {
      _gatherTimer.cancel();
      _gatherTimer = null;
    }

    int step = 0;
    _gatherTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {

      _particles.forEach((Particle p) {
        p.tx += (dx - p.bx) / 100;
        p.ty += (dy - p.by) / 100;
        p.tz += (60 - p.bz) / 100;
      });

      setState(() {});

      step ++;
      if (step >= 99) {
        timer.cancel();
        _gatherTimer = null;
        //修正
        _particles.forEach((Particle p) {
          p.fusion(Offset(_size.width * 0.5, widget.height * 0.5));
        });
        setState(() {});
        tag = true;
        _rotate();
      }
    });
  }

  /*
  * 3D 旋转
  * */
  bool tag = true;
  _rotate() {
    double angle = pi / 180;
    _particles.forEach((Particle p) {
      p.rotateZ(angle);
      p.rotateX(angle);
    });
    setState(() {});
    Future.delayed(Duration(milliseconds: 10), () {
      if (tag) _rotate();
    });
  }

  /*
  * 恢复状态
  * */
  recovery() {
    tag = false;
    _particles.forEach((Particle p) {
      p.tx = p.x;
      p.ty = p.y;
    });
    setState(() {});
  }
}

class ParticleTextPainter extends CustomPainter {
  final List<Particle> _particles;

  Canvas _canvas;
  Size _size;

  ParticleTextPainter(this._particles);

  @override
  void paint(Canvas canvas, Size size) {

    _canvas = canvas;
    _size = size;

    _drawParticles(_particles);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /*
  * 绘制粒子
  * */
  _drawParticles(List particles) {
    if (particles == null) return;
    _particles.forEach((v) {
      if (v.ty <= _size.height - 5) {
        v.draw(_canvas);
      }
    });
  }
}


/*
* 粒子类
* */
class Particle {

  final double x;
  final double y;
  final double z = 60;

  final OP _op = OP();

  Particle(this.x, this.y) {

    ty = y;
    tx = x;
    tz = z;

    double r = Random().nextInt(5) + 0.0;

    paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(220, 20, 60, Random().nextDouble())
      ..strokeWidth = r
      ..strokeCap = StrokeCap.round;

  }

  //最终绘制的坐标
  double tx;
  double ty;
  double tz;

  Paint paint;

  /*
  * 观察点A 观察 空间内的任一点G
  * 投射后的值（x, y）
  * x = (xG - xA) * zA / (zA - zG)
  * y = (yG - yA) * zA / (zA - zG)
  * */
  Offset project() {
    double dx = (tx - _op.x) * _op.z / (_op.z - tz);
    double dy = (ty - _op.y) * _op.z / (_op.z - tz);
    return new Offset(dx, dy);
  }

  draw(Canvas canvas) {

    Offset offset = project();

    canvas.drawPoints(
        PointMode.points, [offset], paint);
  }
  

  /*
  * 爆炸
  * */
  double bx, by, bz;
  bomb(Size size) {

    double r = size.width * 0.5;

    Offset center = Offset(size.width * 0.5, 60);

    Offset start = Offset(center.dx - r, center.dy - r);

    bx = Random().nextInt((2 * r).ceil()) + Random().nextDouble() + start.dx;
    by = Random().nextInt((2 * r).ceil()) + Random().nextDouble() + start.dy;

    while(pow(bx - center.dx, 2) + pow(by - center.dy, 2) > r * r) {
      bomb(size);
    }

    bz = Random().nextInt((2 * r).ceil()) + Random().nextDouble();

  }

  /*聚合*/
  fusion(Offset center) {

    int r = 30;

    Offset start = Offset(center.dx - r, center.dy - r);

    tx = Random().nextInt(2 * r) + Random().nextDouble() + start.dx;
    ty = Random().nextInt(2 * r) + Random().nextDouble() + start.dy;

    while(pow(tx - center.dx, 2) + pow(ty - center.dy, 2) > r * r) {
      fusion(center);
    }

    //球面上的任意一点 z r (x, y)都能形成直角三角形 可应用勾股定理
    double a2 = pow(tx - center.dx, 2) + pow(ty - center.dy, 2);
    double disZ = sqrt(pow(r, 2) - a2);

    tz = r + disZ;
    int random = Random().nextInt(2);
    if (random >= 1) tz = r - disZ;
  }

  /*
  * 绕Z轴旋转
  * */
  rotateZ(double angle) {

    double CX = window.physicalSize.width / window.devicePixelRatio * 0.5;
    double CY = 60;

    //坐标点与环绕点的坐标距离
    var xo = tx - CX;
    var yo = ty - CY;

    var _x = xo * cos(angle) + yo * sin(angle) + CX;
    var _y = yo * cos(angle) - xo * sin(angle) + CY;
    var _z = tz;

    tx = _x;
    ty = _y;
    tz = _z;
  }

  /*
  * 绕X轴旋转
  * */
  rotateX(double angle) {

    double CY = 60;
    double R = 30;

    var yo = ty - CY;
    var zo = tz - R;

    var _x = tx;
    var _y = yo * cos(angle) + zo * sin(angle) + CY;
    var _z = zo * cos(angle) - yo * sin(angle) + R;

    tx = _x;
    ty = _y;
    tz = _z;
  }
}

/*
* 投射的观察点
* */
class OP {
  final double x = 0;
  final double y = 0;
  final double z = 300000;
}
