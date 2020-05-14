import 'package:flutter/material.dart';
import 'package:yxeasyappexhibitor/tmp/calendar/calendar.dart';

class CalendarPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return CalendarPageState();
  }

}

class CalendarPageState extends State<CalendarPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar'),),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
              child: Text('基础用法', style: TextStyle(fontSize: 15, color: Color(0xffa3a3a3)),),
            ),
            Container(
              height: 45,
              color: Colors.white,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Calendar.single(context: context, onCalendarResult: null);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 15),),
                    Text('选择单个日期', style: TextStyle(fontSize: 15),)
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

}