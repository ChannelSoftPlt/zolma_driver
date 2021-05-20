import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:zolma_driver/object/Driver.dart';
import 'package:zolma_driver/pages/home.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:zolma_driver/domain/domain.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  final key = new GlobalKey<ScaffoldState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<Driver> drivers = [];
  var session = FlutterSession();

  @override
  void initState() {
    super.initState();
  }

  redirect() async {
    try {
      var getdriverid = await FlutterSession().get("driverid");
      if (getdriverid != null) {
        openHomePage();
      } else {
        showloginpage();
      }
    } catch ($e) {
      print($e);
    }
  }

  @override
  Widget build(BuildContext context) {
    redirect();
    return showloginpage();
  }

  void checkLogin(name, pswd) async {
    Map data = await Domain.callApi(
        Domain.getdriverinfo, {'read': '1', 'name': name, 'pswd': pswd});

    if (data["status"] == '1') {
      drivers = [];
      List driver = data['Driver'];

      drivers.addAll(
          driver.map((jsonObject) => Driver.fromJson(jsonObject)).toList());

      await session.set("driverid", drivers[0].id);

      dynamic getdriverid = FlutterSession().get("driverid") ?? 0;
      openHomePage();
    } else {
      _showSnackBar("Wrong User or Password. Please try again.");
    }
  }

  openHomePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ));
    });
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }

  Widget showloginpage() {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text('ZOLMA Driver'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'ZOLMA Driver',
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                  color: Colors.blueGrey[400],
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () {
                    checkLogin(nameController.text, passwordController.text);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
