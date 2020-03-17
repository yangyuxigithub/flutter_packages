import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';

/*
1、自定义 ParentData 继承 ContainerBoxParentData 。
2、继承 RenderBox ，同时混入 ContainerRenderObjectMixin 和 RenderBoxContainerDefaultsMixin 实现自定义RenderObject 。
3、继承 MultiChildRenderObjectWidget，实现 createRenderObject 和 updateRenderObject 方法，关联我们自定义的 RenderBox。
4、override RenderBox 的 performLayout 和 setupParentData 方法，实现自定义布局。
* */


class CustomWidget extends MultiChildRenderObjectWidget {
  /*
  * 关键步骤
  * RenderObject 实现 布局 绘制
  * */
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCustomWidget();
  }
}

class _RenderCustomWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RenderCustomWidgetParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            RenderCustomWidgetParentData> {


  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! RenderCustomWidgetParentData)
      child.parentData = RenderCustomWidgetParentData();
  }

  @override
  void performLayout() {

    //判断是否有子控件
    if (childCount == 0) return;

    RenderBox child = firstChild;

    while (child != null) {

      final RenderCustomWidgetParentData childParentData = child.parentData;

      child.layout(constraints, parentUsesSize: true);

      child = childParentData.nextSibling; //下一个
    }
  }

}

class RenderCustomWidgetParentData extends ContainerBoxParentData<RenderBox> {
  double width;
  double height;

  Rect get content => Rect.fromLTWH(
        offset.dx,
        offset.dy,
        width,
        height,
      );
}
