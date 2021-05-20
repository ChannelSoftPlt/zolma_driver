import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zolma_driver/object/Driver.dart';
import 'package:zolma_driver/object/menu.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:zolma_driver/pages/login.dart';
import 'package:zolma_driver/pages/Personalprofile.dart';

import 'package:zolma_driver/domain/domain.dart';

class mainpage extends StatefulWidget {
  @override
  _mainpageState createState() => _mainpageState();
}

class _mainpageState extends State<mainpage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text("Welcome"),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(child: Text("page"),),
          Expanded(
            child: DoubleBackToCloseApp(
              child: Text("halo"),
              snackBar: const SnackBar(
                content: Text('Tap back again to leave'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
