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

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final key = new GlobalKey<ScaffoldState>();
  List<Driver> drivers = [];

  Future fetchDealer() async {
    //await readFromLocal();

    //read from cloud
    dynamic getdriver = await FlutterSession().get("driverid");
    return await Domain.callApi(Domain.getdriverinfo,
        {'getlist': '1', 'driverid': getdriver.toString()});
  }

  void _select(Choice choice) async {
    if (choice.title == 'Profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalProfile()),
      );
    } else if (choice.title == 'Logout') {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      //getlog();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => login()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text("Setting Delear Sequence"),
            ),
            Expanded(
              flex: 1,
              child: PopupMenuButton<Choice>(
                  onSelected: _select,
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Row(children: [
                          IconButton(
                            icon: Icon(choice.icon),
                            color: Colors.white,
                          ),
                          Text(choice.title),
                        ]),
                      );
                    }).toList();
                  }),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: DoubleBackToCloseApp(
              child: FutureBuilder(
                future: fetchDealer(),
                builder: (context, object) {
                  if (!object.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (object.connectionState == ConnectionState.done) {
                      Map data = object.data;
                      if (data['status'] == '1') {
                        drivers = [];

                        List driver = data['Driver'];

                        drivers.addAll(driver
                            .map((jsonObject) => Driver.fromJson(jsonObject))
                            .toList());

                        return customListView();
                      } else {
                        //not found view
                        Center(child: Text("Error"));
                      }
                    }
                  }
                  return Center(child: Text("No Dealer set for you now."));
                },
              ),
              snackBar: const SnackBar(
                content: Text('Tap back again to leave'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customListView() {
    return ReorderableListView(
      children: <Widget>[
        for (int index = 0; index < drivers.length; index++)
          Card(
            color: Colors.blueGrey,
            key: ValueKey(drivers[index].sequence),
            elevation: 2,
            child: ListTile(
              title: Text(drivers[index].dealername,
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              subtitle: Text(
                "Phone " + drivers[index].phone,
                style: TextStyle(color: Colors.white),
              ),
              leading: Text(drivers[index].sequence.toString(),
                  style: TextStyle(color: Colors.white)),
              // trailing: IconButton(
              //   icon: Icon(Icons.work),
              //   color: drivers[index].deliveryid == null
              //       ? Colors.white
              //       : Colors.red,
              //   onPressed: (){
              //     //PickUpItem(drivers[index].dealerid);
              //   },
              // ),
            ),
          ),
      ],
      onReorder: reorderData,
    );
  }

  void reorderData(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      Driver driver = drivers[oldIndex];
      drivers.removeAt(oldIndex);
      drivers.insert(newIndex, driver);

      updateCategorySequence();
    });
  }

  updateCategorySequence() async {
    dynamic getdriver = await FlutterSession().get("driverid");
    for (int i = 0; i < drivers.length; i++) {
      drivers[i].sequence = i + 1;
    }

    Map data = await Domain.callApi(Domain.getdriverinfo, {
      'updatesequence': '1',
      'driverid': getdriver.toString(),
      'sequence': jsonEncode(drivers)
    });
    if (data['status'] == '1') {
      //print(jsonEncode(drivers));
      _showSnackBar('Sequence Updated!');
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 500),
      content: new Text(message),
    ));
  }

  // void PickUpItem(dealerid) async {
  //   dynamic getdriver = await FlutterSession().get("driverid");
  //   //print("dealerid: "+dealerid.toString()+" driverid: "+getdriver.toString());
  //   Map data = await Domain.callApi(Domain.getdriverinfo, {
  //     'pickup': '1',
  //     'dealerid': dealerid.toString(),
  //     'driverid': getdriver.toString(),
  //   });
  //   print(data['status']);
  //   if (data['status'] == '1') {
  //     _showSnackBar('Pick up Completed!');
  //     setState(() {
  //
  //     });
  //   }
  // }
}
