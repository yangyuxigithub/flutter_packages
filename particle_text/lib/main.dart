import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:particle_text/particle_text_painter.dart';

import 'header.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '粒子文本'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String text = 'hello';
  TextEditingController _textEditingController = new TextEditingController();

  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EasyRefresh.custom(
        header: ParticleHeader(),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 10));
        },
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return Container(
                  width: 60.0,
                  height: 60.0,
                  child: Center(
                    child: Text('$index'),
                  ),
                  color:
                  index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
                );
              },
              childCount: 20,
            ),
          ),
        ],
      )
    );
  }

}
