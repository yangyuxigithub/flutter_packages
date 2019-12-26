import 'package:flutter/material.dart';

class DragSortWidget extends StatefulWidget {
  final List dataSource;

  const DragSortWidget({Key key, this.dataSource}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DragSortWidgetState();
  }
}

class DragSortWidgetState extends State<DragSortWidget> {

  List<Widget> items;
  List _list = [];
  dynamic _movingValue; //记录正在移动的数据

  @override
  void initState() {
    super.initState();
    _list = widget.dataSource;
  }

  @override
  Widget build(BuildContext context) {

    items = [];
    for (dynamic value in _list) {
      items.add(
          draggableItem(value)
      );
    }

    return Wrap(direction: Axis.horizontal, spacing: 5, runSpacing: 5, children: items);
  }

  Widget draggableItem(value) {
    return Draggable(
      data: value,
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return baseItem(value, Colors.blue);
        },
        onWillAccept: (moveData) {
          var accept = moveData != null;
          if (accept) {
            exchangeItem(moveData, value, false);
          }
          return accept;
        },
        onAccept: (moveData) {
          exchangeItem(moveData, value, true);
        },
        onLeave: (moveData) {

        },
      ),
      feedback: baseItem(value, Colors.green),
      childWhenDragging: null,
      onDragStarted: () {
        setState(() {
          _movingValue = value;//记录开始拖拽的数据
        });
      },
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        setState(() {
          _movingValue = null;//清空标记进行重绘
        });
      },
      onDragCompleted: () {},
    );
  }
  
  /*
  * 自定义模板
  * */
  Widget baseItem(value, bgColor) {

    if (value == _movingValue) {
      return Container(
          padding: EdgeInsets.all(10),
          //color: Colors.red,
          child: Text(value.toString(), style: TextStyle(inherit: false, color: Colors.transparent),)
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.blue,
      child: Text(value.toString(), style: TextStyle(inherit: false),)
    );
  }

  // 重新排序
  exchangeItem(moveData, toData, onAccept) {
    setState(() {
      var toIndex = _list.indexOf(toData);

      _list.remove(moveData);
      _list.insert(toIndex, moveData);

      if (onAccept) {
        _movingValue = null;
      }
    });
  }

}
