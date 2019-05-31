import 'package:flutter/material.dart';
import 'dart:math';

class ToolBarPainter extends CustomPainter {

  static double _topRadius = 8.0;
  static double _bottomRadius = 15.0;
  static double _innerRingRadius = 8.0;
  List items = [1, 2, 3];
  Color bgColor = Colors.white;
  double x = 100;

  double itemRadius = 33;

  Paint _paint;
  Canvas _canvas;
  Size _size;

  ToolBarPainter({this.x}) {
    _paint = Paint()
      ..color = bgColor;
  }

  @override
  void paint(Canvas canvas, Size size) {

    _size = size;

    _canvas = canvas;

    Path path = _createPath();
    canvas.drawShadow(path, Colors.grey, 3, true);
    canvas.drawPath(path, _paint);

  }

  @override
  bool shouldRepaint(ToolBarPainter oldDelegate) {
    if (oldDelegate.x != x) return true;
    return false;
  }

  // 绘制路径
  Path _createPath() {

    Path path = new Path();
    // 路径的起始点
    path.moveTo(_topRadius, 0);

    // 此处添加向内的弧形
    _dynamicPath(_size, path);

    path.lineTo(_size.width - _topRadius, 0);
    //圆角 右上
    Offset center = new Offset(_size.width - _topRadius, _topRadius);
    path.arcTo(Rect.fromCircle(center: center, radius: _topRadius), -0.5 * pi, 0.5 * pi, false);

    path.lineTo(_size.width, _size.height - _bottomRadius);

    //圆角 右下
    center = new Offset(_size.width - _bottomRadius, _size.height - _bottomRadius);
    path.arcTo(Rect.fromCircle(center: center, radius: _bottomRadius), 0, 0.5 * pi, false);

    path.lineTo(_bottomRadius, _size.height);

    //圆角 左下
    center = new Offset(_bottomRadius, _size.height - _bottomRadius);
    path.arcTo(Rect.fromCircle(center: center, radius: _bottomRadius), 0.5 * pi, 0.5 * pi, false);

    path.lineTo(0, _topRadius);

    //圆角左上
    center = new Offset(_topRadius, _topRadius);
    path.arcTo(Rect.fromCircle(center: center, radius: _topRadius),  pi, 0.5 * pi, true);

    path.lineTo(_topRadius, 0); //起始点 与 结束点相同

    return path;
  }

  /*
  * 动态 路径
  * */
  _dynamicPath(Size size, Path path) {

    /*
      @ 阈值
      大圆圆心x坐标的阈值
     */
    double minDx = _topRadius + _innerRingRadius + itemRadius;
    double maxDx = size.width - minDx;

    if (x <= minDx) x = minDx;
    if (x >= maxDx) x = maxDx;

    // 大圆的中心点
    Offset center = Offset(x, _innerRingRadius);

    path.lineTo(x, 0);

    // 此处要注意  路径从 _topRadius 开始绘制
    path.arcTo(Rect.fromCircle(center: Offset(x - _innerRingRadius - itemRadius, _innerRingRadius), radius: _innerRingRadius), -0.5 * pi, 0.5 * pi, false);

    // 大圆
    path.fillType = PathFillType.evenOdd;
    path.arcTo(Rect.fromCircle(center: center, radius: itemRadius), 0, pi, false);

    // 大圆结束
    path.arcTo(Rect.fromCircle(center: Offset(x + _innerRingRadius + itemRadius, _innerRingRadius), radius: _innerRingRadius), pi, 0.5 * pi, false);

  }


}
