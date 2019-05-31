import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:custom_tabs/custom_tabs.dart';

void main() {
  test('adds one to input values', () {
    final tabs = CustomTabs(
      initializeIndex: 1,
      unSelectedItems: <Widget>[
        Text("首页",
            style: TextStyle(
                inherit: false,
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        Text("消息",
            style: TextStyle(
                inherit: false,
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        Text("个人中心",
            style: TextStyle(
                inherit: false,
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold))
      ],
      selectedItems: <Widget>[
        Text(
          "首页",
          style: TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "消息",
          style: TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "我的",
          style: TextStyle(
              inherit: false,
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      ],
      pages: <Widget>[
        Container(
          color: Colors.blue,
        ),
        Container(
          color: Colors.red,
        ),
        Container(
          color: Colors.green,
        ),
      ],
    );
  });
}
