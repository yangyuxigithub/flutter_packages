import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yxeasyappexhibitor/page/calendar_page.dart';
import 'package:yxeasyappexhibitor/page/image_preview_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'EA'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _list = ['图片查看（这是个半成品）', 'Calendar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              handleTap(index);
            },
            child: Container(
              padding: EdgeInsets.only(left: 10),
              width: MediaQuery.of(context).size.width,
              height: 45,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xffa3a3a3), width: 0.5))),
              child: Align(alignment: Alignment.centerLeft, child: Text('${_list[index]}'),),
            ),
          );
        },
        itemCount: _list.length,),
      ),
    );
  }

  /*
  * 点击事件
  * */
  handleTap(int index) {

    Widget page;

    switch(index) {
      case 0:
        page = ImagePreviewPage();
        break;
      case 1:
        page = CalendarPage();
        break;
    }

    Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
      return page;
    }));
  }
}
