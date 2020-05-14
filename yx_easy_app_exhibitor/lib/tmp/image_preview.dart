import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'image_preview_controller.dart';

class ImagePreview {
  OverlayEntry _overlayEntry;

  ImagePreview._();

  ImagePreview.normal({BuildContext context, List<String> images})
      : assert(images != null && images.length > 0) {
    OverlayState state = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          color: Color.fromRGBO(0, 0, 0, 0.3),
          child: _ImageContainer(
            images: images,
          ),
        );
      },
    );

    state.insert(_overlayEntry);
  }
}

class _ImageContainer extends StatefulWidget {
  final List<String> images;

  const _ImageContainer({Key key, this.images}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageContainerState();
  }
}

class _ImageContainerState extends State<_ImageContainer> {
  PageController _pageController = PageController(keepPage: true);

  @override
  void initState() {
    super.initState();
    //PhotoViewGallery.builder(itemCount: null, builder: null)
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ImagePreViewController(
          controller: _pageController,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            controller: _pageController,
            itemBuilder: (BuildContext context, int index) {
              return _Item(
                image: widget.images[index],
              );
            },
            itemCount: widget.images.length,
          ),
        ),
      ),
    );
  }
}

class _Item extends StatefulWidget {
  final String image;

  const _Item({Key key, this.image}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemState();
  }
}

class _ItemState extends State<_Item> with TickerProviderStateMixin {
  //拖拽手势
  double sx, sy, st, sl;
  double mx, my;
  double dx, dy;
  double top = 0, left = 0;

  //布局缩放比
  double userScale = 1.0;

  //记录缩放开始时的缩放比
  double sScale;

  //最大缩放倍数
  double maxScale = 4.0;

  //最小缩放倍数
  double minScale = 1.0;

  //图片的详细信息
  ImageInfo _imageInfo;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _layout();
  }

  /*
  * 基本布局
  * */
  double dis; //越过边界的X距离
  int spi; //当前页面的pageIndex
  int endTime;
  Widget _layout() {

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      //此处可以控制pageView是否处理滑动手势
      onHorizontalDragStart: userScale > 1.0 ? (_) {} : null,
      onDoubleTap: handleTap,
      child: RawGestureDetector(
        gestures: {
          MG: GestureRecognizerFactoryWithHandlers<
              MG>(
                () => MG(),
                (MG instance) {
              instance.onStart = (ScaleStartDetails details) {
                sx = details.localFocalPoint.dx;
                sy = details.localFocalPoint.dy;
                sl = left;
                st = top;
                sScale = userScale;
                spi = ImagePreViewController.of(context).controller.page.floor();

                if (_timer != null) {
                  _timer.cancel();
                  _timer = null;
                }

              };
              instance.onUpdate = (ScaleUpdateDetails details) {
                //单指拖动 可以移动
                if (details.scale == 1.0) {

                  if (userScale > 1.0) {

                    bool hold = true;

                    dx = (details.localFocalPoint.dx - sx);
                    dy = (details.localFocalPoint.dy - sy);
                    left = sl + dx;
                    top = st + dy;

                    dis = null;
                    //放大状态下的边界条件
                    if (mx != null && left > mx) {
                      dis = -(left - mx);
                      left = mx;
                      hold = false;
                    }
                    if (my != null && top >= my) top = my;
                    //右边
                    if (mx != null && left < -mx) {
                      dis = -left - mx;
                      left = -mx;
                      hold = false;
                    }
                    if (my != null && top <= -my) top = -my;

                    ImagePreViewController.of(context).move(context: context, hold: hold, dis: dis, spi: spi);

                  }else{
                    dx = (details.localFocalPoint.dx - sx);
                    dy = (details.localFocalPoint.dy - sy);
                    //left = sl + dx;
                    //top = st + dy;
                  }

                } else {
                  ImagePreViewController.of(context).move(context: context, hold: true, spi: spi);
                  //缩放
                  handleUserScale(details);
                }
                if (mounted) setState(() {});
              };
              instance.onEnd = (ScaleEndDetails details) {
                ///根据onEnd调用次数可以区分是多指操作还是单指操作
                ///几个手指触摸，onEnd会被回调几次
                endTime = DateTime.now().millisecondsSinceEpoch;
                inertia(endTime, details);
                //pageView在触摸结束后回到固定的位置
                if (userScale > 1.0) {
                  ImagePreViewController.of(context).reset();
                }
                // 超出最小和做大边界的情况下要恢复到指定位置
                animateInHoming();
              };
            },
          ),
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              Center(
                child: Transform.translate(
                  offset: Offset(left, top),
                  child: Transform.scale(
                    scale: userScale,
                    alignment: Alignment.center,
                    child: Image.asset(
                      widget.image,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  * 处理图片宽高
  * */
  _resolveImage() {
    Future.delayed(Duration(milliseconds: 200), () {
      Image image = Image.asset(
        widget.image,
        width: MediaQuery.of(context).size.width,
      );
      image.image
          .resolve(ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        _imageInfo = info;
      }));
    });
  }

  /*
  * 处理双击
  * */
  handleTap() {
    if (userScale <= 1.0) {
      AnimationController _controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
      Animation<double> scale =
          Tween<double>(begin: userScale, end: 2.0).animate(_controller);
      scale.addListener(() {
        userScale = scale.value;
        setBoundary();
        if (mounted) setState(() {});
        if (_controller.status == AnimationStatus.completed) {
          _controller.dispose();
        }
      });
      _controller.forward();
    } else {
      //双击恢复原状态
      AnimationController _controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
      Animation<double> scale =
          Tween<double>(begin: userScale, end: 1.0).animate(_controller);
      scale.addListener(() {
        userScale = scale.value;
        setBoundary();
        if (mounted) setState(() {});
      });
      // x 方向平移
      Animation<double> topTween = Tween<double>(begin: top, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.decelerate));
      topTween.addListener(() {
        if (mounted) setState(() {
          top = topTween.value;
        });
      });
      // y 方向平移
      Animation<double> leftTween = Tween<double>(begin: left, end: 0.0)
          .animate(
              CurvedAnimation(parent: _controller, curve: Curves.decelerate));
      leftTween.addListener(() {
        if (mounted) setState(() {
          left = leftTween.value;
        });
        if (leftTween.status == AnimationStatus.completed) {
          _controller.dispose();
        }
      });
      _controller.forward();
    }
  }

  /*
  * 回到原位
  * */
  animateInHoming() {
    if (userScale <= 1.0) {
      AnimationController controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 200));
      //缩放
      Animation<double> scaleTween =
          Tween<double>(begin: userScale, end: minScale).animate(
              CurvedAnimation(parent: controller, curve: Curves.decelerate));
      scaleTween.addListener(() {
        if (mounted) setState(() {
          userScale = scaleTween.value;
        });
      });
      // y 方向平移
      Animation<double> topTween = Tween<double>(begin: top, end: 0.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.decelerate));
      topTween.addListener(() {
        if (mounted) setState(() {
          top = topTween.value;
        });
      });
      // x 方向平移
      Animation<double> leftTween = Tween<double>(begin: left, end: 0.0)
          .animate(
              CurvedAnimation(parent: controller, curve: Curves.decelerate));
      leftTween.addListener(() {
        if (mounted) setState(() {
          left = leftTween.value;
        });
        if (leftTween.status == AnimationStatus.completed) {
          controller.dispose();
        }
      });
      controller.forward();
    } else {
      //高度小于屏幕高度的情况
      double height = _imageInfo.image.height /
          (_imageInfo.image.width / MediaQuery.of(context).size.width);
      double cHeight = height * userScale;
      if (cHeight <= MediaQuery.of(context).size.height) {
        AnimationController controller = AnimationController(
            vsync: this, duration: Duration(milliseconds: 200));
        // y 方向平移
        Animation<double> topTween = Tween<double>(begin: top, end: 0.0)
            .animate(
                CurvedAnimation(parent: controller, curve: Curves.decelerate));
        topTween.addListener(() {
          if (mounted) setState(() {
            top = topTween.value;
          });
          if (topTween.status == AnimationStatus.completed) {
            controller.dispose();
          }
        });
        controller.forward();
      }

      if (userScale >= maxScale) {
        AnimationController controller = AnimationController(
            vsync: this, duration: Duration(milliseconds: 200));
        //缩放
        Animation<double> scaleTween =
            Tween<double>(begin: userScale, end: maxScale).animate(
                CurvedAnimation(parent: controller, curve: Curves.decelerate));
        scaleTween.addListener(() {
          if (mounted) setState(() {
            userScale = scaleTween.value;
          });
          if (scaleTween.status == AnimationStatus.completed) {
            controller.dispose();
            setBoundary();
          }
        });
        controller.forward();
      }
    }
  }

  /*
  * 处理用户缩放手势
  * */
  double preScale;
  handleUserScale(ScaleUpdateDetails details) {
    preScale = userScale;

    userScale = sScale * details.scale;

    //下面开始计算偏移量__
    //图片的原始高度
    double height = _imageInfo.image.height /
        (_imageInfo.image.width / MediaQuery.of(context).size.width);
    //图片的原始宽度
    double width = MediaQuery.of(context).size.width;

    double cWidth = width * userScale;
    mx = null;

    double cHeight = height * userScale;
    my = null;

    if (preScale >= userScale) {
      //正在进行缩小的操作
      if (userScale > 1.0) {
        if (left >= (cWidth - width) * 0.5) {
          left = (cWidth - width) * 0.5;
        }
        if (left <= -(cWidth - width) * 0.5) {
          left = -(cWidth - width) * 0.5;
        }

        if (cHeight >= MediaQuery.of(context).size.height) {
          if (top >= (cHeight - MediaQuery.of(context).size.height) * 0.5) {
            top = (cHeight - MediaQuery.of(context).size.height) * 0.5;
          }
          if (top <= -(cHeight - MediaQuery.of(context).size.height) * 0.5) {
            top = -(cHeight - MediaQuery.of(context).size.height) * 0.5;
          }
        }
      }
    }

    setBoundary();

    if (mounted) setState(() {});
  }

  /*
  * 计算当前状态下临界值
  * */
  setBoundary() {
    double height = _imageInfo.image.height /
        (_imageInfo.image.width / MediaQuery.of(context).size.width);
    //图片的原始宽度
    double width = MediaQuery.of(context).size.width;

    double cWidth = width * userScale;
    mx = null;

    double cHeight = height * userScale;
    my = null;

    if (cWidth >= MediaQuery.of(context).size.width) {
      //超越屏幕宽度
      //单指拖拽 临界点的设置
      mx = (cWidth - MediaQuery.of(context).size.width) * 0.5;
      if (cHeight >= MediaQuery.of(context).size.height) {
        //超越屏幕高度
        my = (cHeight - MediaQuery.of(context).size.height) * 0.5;
      } else {
        my = -(cHeight - MediaQuery.of(context).size.height) * 0.5;
      }
    }
  }

  /*
  * 拖拽惯性
  * */
  Timer _timer;
  bool flag = false;
  inertia(int end, ScaleEndDetails details) {
    if (flag == false) {
      flag = true;
      Future.delayed(Duration(milliseconds: 50), () {
        if (endTime == end && userScale > 1.0) {

          sl = left;
          st = top;

          double vx = details.velocity.pixelsPerSecond.dx;
          double vy = details.velocity.pixelsPerSecond.dy;

          vx = 10 * vx / 1000; // 像素 / 10毫秒
          vy = 10 * vy / 1000; // 像素 / 10毫秒

          int count = 1;
          int t = 60;

          double ax = vx / t; //加速度
          if (vx < 0) {
            ax = ax.abs();
          }else {
            ax = -ax.abs();
          }

          double ay = vy / t; //加速度
          if (vy < 0) {
            ay = ay.abs();
          }else {
            ay = -ay.abs();
          }

          if (_timer != null) {
            _timer.cancel();
            _timer = null;
          }
          _timer =  Timer.periodic(Duration(milliseconds: 10), (timer) {

            double sx = 0.5 * ax * pow(count, 2) + vx * count;
            double sy = 0.5 * ay * pow(count, 2) + vy * count;

            left = sl + sx;

            double height = _imageInfo.image.height /
                (_imageInfo.image.width / MediaQuery.of(context).size.width);

            double cHeight = height * userScale;
            if (cHeight > MediaQuery.of(context).size.height) {
              top = st + sy;
            }

            if (mx != null && left > mx) left = mx;
            if (mx != null && left < -mx) left = -mx;
            if (my != null && top <= -my) top = -my;
            if (my != null && top >= my) top = my;

            count ++;
            if (count >= t) {
              timer.cancel();
              count = 1;
              timer = null;
            }
            setState(() {});
          });
        }
        flag = false;
      });
    }
  }

}

/*
* 自定义手势处理器
* 无限复活BUFF
* */
class MG extends ScaleGestureRecognizer {

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  @override
  void acceptGesture(int pointer) {
    super.acceptGesture(pointer);
  }
}

