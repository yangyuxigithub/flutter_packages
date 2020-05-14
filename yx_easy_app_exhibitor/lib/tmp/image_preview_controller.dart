import 'package:flutter/material.dart';

class ImagePreViewController extends InheritedWidget {

  final Widget child;

  final PageController controller;

  ImagePreViewController({this.child, this.controller});

  static ImagePreViewController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ImagePreViewController>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  move({BuildContext context, bool hold, double dis, int spi}) {
    if (hold) {
      if (controller.position.pixels != spi * MediaQuery.of(context).size.width) {
        // ignore: invalid_use_of_protected_member
        controller.position.forcePixels(spi * MediaQuery.of(context).size.width);
      }
      controller.position.hold(null);
      return;
    }
    if (dis == null || spi == null) return;
    // ignore: invalid_use_of_protected_member
    controller.position.forcePixels(spi * MediaQuery.of(context).size.width + dis);
  }

  reset() {
    controller.animateToPage(controller.page.round(), duration: Duration(milliseconds: 300), curve: Curves.decelerate);
  }
}