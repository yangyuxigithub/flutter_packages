import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Calendar {
  Calendar._();

  OverlayEntry _overlayEntry;
  OverlayState _overlayState;

  ///选择单个日期
  Calendar.single(
      {@required BuildContext context,
      @required OnCalendarResult onCalendarResult}) {
    _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return _CalendarWidget(
        selection: CalendarSelection.single,
        onCalendarStateChange: () {
          try {
            _overlayEntry.remove();
          } catch (e) {}
        },
      );
    });
    _overlayState.insert(_overlayEntry);
  }
}

class _CalendarWidget extends StatefulWidget {
  final OnCalendarStateChange onCalendarStateChange;
  final CalendarSelection selection;

  const _CalendarWidget({Key key, this.onCalendarStateChange, this.selection})
      : assert(selection != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalendarWidgetState();
  }
}

double sw = window.physicalSize.width / window.devicePixelRatio;
double sh = window.physicalSize.height / window.devicePixelRatio;

class _CalendarWidgetState extends State<_CalendarWidget> {
  static final int centerIndex = 1200;
  Matrix4 matrix4 = Matrix4.identity()..translate(0.0, sh * 0.8);
  PageController _pageController = PageController(initialPage: centerIndex);

  ///头部展示的时间 xxxx年x月
  DateTime disPlayDateTime;

  ///点击选择的时间
  DateTime selected;

  ///动画的时间
  Duration duration = Duration(milliseconds: 200);

  ///背景色的透明度
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
    disPlayDateTime = now;
    selected = DateTime(now.year, now.month, now.day);

    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        matrix4 = Matrix4.identity()..translate(0.0, 0.0);
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      child: Material(
          color: Color.fromRGBO(0, 0, 0, 0.7),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: AnimatedContainer(
                color: Colors.white,
                curve: Curves.decelerate,
                duration: duration,
                transform: matrix4,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _layoutHeader(),
                    _layoutBody(),
                    _layoutFooter()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  ///头部
  _layoutHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 118,
      decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(125, 126, 126, 0.16),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 44,
            child: Center(
              child: Text(
                '日期选择',
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff323233),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            height: 44,
            child: Center(
              child: Text(
                '${disPlayDateTime.year}年${disPlayDateTime.month}月',
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff323233),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            height: 30,
            child: Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: Center(
                    child: Text(
                      _weekForIndex(index),
                      style: TextStyle(fontSize: 12, color: Color(0xff323233)),
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  ///body 日历部分
  _layoutBody() {
    return Expanded(
      child: Container(
        child: PageView.builder(
          onPageChanged: (int index) {
            DateTime dateTime = now;
            if (index != centerIndex) {
              int dis = index - centerIndex;
              int year = now.year;
              int m = now.month;
              int ay = (dis / 12).floor();
              year += ay;
              int am = dis % 12;
              m += am;
              dateTime = DateTime(year, m);
            }
            setState(() {
              disPlayDateTime = dateTime;
            });
          },
          controller: _pageController,
          pageSnapping: false,
          itemBuilder: (BuildContext context, int index) {
            _DataForMonth _dataForMonth = calc(index);
            List list = _dataForMonth.list;
            return Container(
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        '${_dataForMonth.dateTime.year}年${_dataForMonth.dateTime.month}月',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff323233),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Center(
                      child: Opacity(
                        opacity: 0.8,
                        child: Text(
                          '${_dataForMonth.dateTime.month}',
                          style: TextStyle(
                              fontSize: 160,
                              color: Color.fromRGBO(242, 243, 245, 1.0)),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(list.length, (index) {
                        List sub = list[index];
                        return Row(
                            children: List.generate(sub.length, (index) {
                          _DataForDay data = sub[index];
                          return _layoutCalendarItem(data, index);
                        }));
                      }),
                    )
                  ],
                ),
              ),
            );
          },
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  ///确定按钮
  _layoutFooter() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50 + MediaQuery.of(context).padding.bottom,
      color: Colors.white,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 7),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              dismiss();
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 36,
              decoration: BoxDecoration(
                color: Color(0xffee0a24),
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Center(
                child: Text(
                  '确定',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///布局单日
  _layoutCalendarItem(_DataForDay data, int index) {
    Color bgColor;
    Color textColor = Color(0xff323233);
    if (data != null && selected == data.dateTime) {
      //选中的状态
      bgColor = Color(0xffee0a24);
      textColor = Colors.white;
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          selected = data.dateTime;
          setState(() {});
        },
        child: ClipRRect(
          child: Container(
            height: 64,
            color: bgColor,
            child: Center(
              child: Text(
                '${data == null ? '' : data.day}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }

  ///周 日 一 二 三 四 五 六
  String _weekForIndex(int index) {
    switch (index) {
      case 0:
        return '日';
        break;
      case 1:
        return '一';
        break;
      case 2:
        return '二';
        break;
      case 3:
        return '三';
        break;
      case 4:
        return '四';
        break;
      case 5:
        return '五';
        break;
      case 6:
        return '六';
        break;
    }
    return '错误';
  }

  ///计算时间
  DateTime now;

  calc(int index) {
    DateTime dateTime = now;
    if (index != centerIndex) {
      int dis = index - centerIndex;
      int year = now.year;
      int m = now.month;
      int ay = (dis / 12).floor();
      year += ay;
      int am = dis % 12;
      m += am;
      dateTime = DateTime(year, m);
    }
    int month = dateTime.month;
    //某月的天数
    int days = 30;
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 11) {
      days = 31;
    }
    if (month == 2) {
      days = 28;
      if (dateTime.year % 4 == 0 && dateTime.year % 100 != 0) {
        //公历闰年
        days = 29;
      }
      if (dateTime.year % 100 == 0) {
        if (dateTime.year % 400 == 0) {
          //世纪闰年
          days = 29;
        }
      }
    }

    //本月第一天在周几
    int week = DateTime(dateTime.year, dateTime.month, 1).weekday;

    List list = [];
    List tmp = [];
    int count = 1;
    int line = 0;

    do {
      for (int i = 0; i <= 6; i++) {
        if (line == 0 && i < week) {
          tmp.add(null);
        } else {
          if (count <= days) {
            tmp.add(_DataForDay(
                day: count,
                dateTime: DateTime(dateTime.year, dateTime.month, count)));
          } else {
            tmp.add(null);
          }
          count++;
        }
      }
      list.add(tmp);
      tmp = [];
      line++;
    } while (count <= days);

    return _DataForMonth(
        list: list, dateTime: DateTime(dateTime.year, dateTime.month));
  }

  ///关闭自身
  dismiss() {
    setState(() {
      matrix4 = Matrix4.identity()..translate(0.0, sh * 0.8);
      opacity = 0.0;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      if (widget.onCalendarStateChange != null) {
        widget.onCalendarStateChange();
      }
    });
  }
}

class _DataForDay {
  final DateTime dateTime;
  final int day;

  _DataForDay({this.dateTime, this.day});
}

class _DataForMonth {
  final List list;
  final DateTime dateTime;

  _DataForMonth({this.list, this.dateTime});
}

class CalendarResult {
  final DateTime selectedDateTime;
  final List<DateTime> dateTimes;
  final DateTime startDateTime;
  final DateTime endDateTime;

  CalendarResult({
    this.selectedDateTime,
    this.dateTimes,
    this.startDateTime,
    this.endDateTime,
  });
}

///日历选择结果
typedef OnCalendarResult = Function(String format, DateTime dateTime);

///日历状态改变
typedef OnCalendarStateChange = Function();

///选择类型
enum CalendarSelection {
  single, //单个时间
  multiple, //多个时间
  section //时间区间
}
