import 'package:flutter/material.dart';
import 'package:yxeasyappexhibitor/tmp/image_preview.dart';

class ImagePreviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagePreviewPageState();
  }

}

class _ImagePreviewPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ImagePreview')),
      body: Container(
        padding: EdgeInsets.only(left: 15),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 20), child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                ImagePreview.normal(context: context, images: ['assets/img/1.jpg', 'assets/img/2.jpg', 'assets/img/3.jpg', 'assets/img/4.jpg', 'assets/img/5.jpeg', 'assets/img/6.jpeg', 'assets/img/7.jpg',]);
              },
              child: Container(
                width: 87, height: 44, color: Colors.green,
                child: Center(
                  child: Text('预览图片', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),)
          ],
        ),
      ),
    );
  }

}