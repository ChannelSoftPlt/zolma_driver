import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zolma_driver/pages/delivery.dart';
import 'package:zolma_driver/pages/setting.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBottomNavigationBar(),
    );
  }
}


class MyBottomNavigationBar extends StatefulWidget {
  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    //mainpage(),
    DeliveryPage(),
    Setting(),
  ];

  void onTappedBar(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],

      body:_children[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[500],

        onTap: onTappedBar,
        currentIndex: _currentIndex,

        items: [
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.home),
//            title: new Text('Home'),
//          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.airport_shuttle_sharp),
            title: new Text('Delivery'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.wysiwyg),
            title: new Text('Setting'),
          ),
        ],
      ),
    );
  }
}