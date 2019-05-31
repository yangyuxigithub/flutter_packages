library custom_tabs;

import 'dart:async';

import 'package:custom_tabs/painters.dart';
import 'package:flutter/material.dart';

class CustomTabs extends StatefulWidget {
  final int initializeIndex;
  final List<Widget> unSelectedItems;
  final List<Widget> selectedItems;
  final List<Widget> pages;

  const CustomTabs(
      {Key key,
      this.initializeIndex = 0,
      @required this.unSelectedItems,
      @required this.selectedItems,
      @required this.pages})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CustomTabsState();
  }
}

class _CustomTabsState extends State<CustomTabs>
    with SingleTickerProviderStateMixin {

  AnimationController controller;
  Animation<double> selectItemMoveAnimation;
  Animation<double> selectItemHideAnimation;
  Animation<double> selectItemShowAnimation;

  Widget selectedItem;

  double x;
  int selectIndex;
  int tapIndex;
  List<Widget> actions;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.initializeIndex;
    selectedItem = widget.selectedItems[selectIndex];
    tapIndex = selectIndex;
    initAnimation();
  }

  @override
  Widget build(BuildContext context) {

    actions = toolBarActions();

    if (x == null) {
      //第一次创建使用
      double width = (MediaQuery.of(context).size.width - 30) / 3;
      x = width / 2 + selectIndex * width;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Scaffold(
            body: IndexedStack(
              index: tapIndex,
              children: widget.pages,
            ),
          ),
          _CustomToolBar(x: x, actions: actions, selectedItem: createSelectedItem())
        ],
      ),
    );
  }

  /*
  * 按钮层
  * */
  List<Widget> toolBarActions() {
    double width = (MediaQuery.of(context).size.width - 30) / 3;

    List<Widget> list = [];

    if (widget.unSelectedItems != null) {
      widget.unSelectedItems.forEach((Widget item) {
        int i = widget.unSelectedItems.indexOf(item);
        list.add(
            Expanded(
              child: Offstage(
                offstage: tapIndex == i,
                child: GestureDetector(
                    onTap: () {
                      selectIndex = i;
                      startAnimation();
                    },
                    child: Container(
                      width: width - 10,
                      height: 50,
                      child: Center(
                        child: item,
                      ),
                    )
                ),
              )
            )
        );
      });
    }

    return list;
  }

  /*
  * 动画
  * select index
  * */
  initAnimation() {
    controller = new AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    controller.addListener(() {

      setState(() {
        // 移动
        if (controller.status == AnimationStatus.forward) {
          x = selectItemMoveAnimation.value;
        }
        // 文本 隐藏 显示
        if (selectItemHideAnimation.status == AnimationStatus.forward) {
          if (selectItemHideAnimation.value == 0) {
            selectedItem = widget.selectedItems[selectIndex];
            tapIndex = selectIndex;
          }
        }
      });

      if (controller.status == AnimationStatus.completed) {
        controller.reset();
      }
    });
  }

  startAnimation() {

    double now = x;

    double width = (MediaQuery.of(context).size.width - 30) / 3;
    double end = width / 2 + selectIndex * width;

    selectItemMoveAnimation = new Tween<double>(begin: now, end: end).animate(
        new CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, 1.0, curve: Curves.elasticInOut)));
    selectItemHideAnimation = new Tween<double>(begin: 1.0, end: 0.0).animate(
        new CurvedAnimation(
            parent: controller,
            curve: Interval(0.3, 0.5, curve: Curves.linear)));
    selectItemShowAnimation = new Tween<double>(begin: 0.0, end: 1.0).animate(
        new CurvedAnimation(
            parent: controller,
            curve: Interval(0.5, 1.0, curve: Curves.linear)));

    controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  /*
  * 创建选中项
  * */
  Widget createSelectedItem() {
    return Positioned(
      top: -19, // (R1 + dis) - R - R1 其中 R1为子圆形组件的大小
      left: (x - 33) + 6,
      child: Card(
          margin: EdgeInsets.all(0),
          color: Colors.white,
          elevation: 8,
          shape: CircleBorder(),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(27)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      offset: Offset(0, 1),
                      blurRadius: 0.5,
                      spreadRadius: 0.5),
                ]),
            child: Center(
              child: selectedItem,
            ),
          )),
    );
  }
}

/*
* @Widget  ToolBar
*
* */
class _CustomToolBar extends StatelessWidget {

  final double x;
  final List<Widget> actions;
  final Widget selectedItem;

  const _CustomToolBar({Key key, @required this.x, @required this.actions, this.selectedItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 15,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Align(
              alignment: Alignment.bottomCenter,
              /*-- toolbar 画布 --*/
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 50,
                    maxWidth: MediaQuery.of(context).size.width - 30),
                child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width - 30, 50),
                    painter: ToolBarPainter(x: x),
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[toolBarActions(), selectedItem],
                    )),
              )),
        ));
  }

  Widget toolBarActions() {
    return Container(
      height: 50,
      color: Colors.transparent,
      child: Row(children: actions),
    );
  }

}
