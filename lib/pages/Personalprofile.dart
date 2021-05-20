import 'package:zolma_driver/pages/Editprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:zolma_driver/object/DriverInfo.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PersonalProfile extends StatefulWidget {
  @override
  _PersonalProfileState createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  //QR Code Part
  String qrData="https://github.com/ChinmayMunje";

  List<DriverInfo> drivers = [];

  Future fetchDriver() async {
    dynamic getdriverid = await FlutterSession().get("driverid");
    return await Domain.callApi(Domain.getdriverinfo,
        {'reading': '1', 'driverid': getdriverid.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Personal Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
        child: FutureBuilder(
            future: fetchDriver(),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  drivers = [];
                  //print(data);
                  if (data['status'] == '1') {
                    List getdriver = data['Driver'];
                    //print(getdriver);
                    drivers.addAll(getdriver
                        .map((jsonObject) => DriverInfo.fromJson(jsonObject))
                        .toList());

                    return customProfile();
                  }
                }
              }
              return Center(child: Text("No Data"));
            }),
      ),
    );
  }

  Widget customProfile() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Gnome-stock_person.svg/1024px-Gnome-stock_person.svg.png'),
              radius: 40,
              backgroundColor: Colors.grey,
            ),
          ),
          Divider(
            height: 60,
            color: Colors.grey[800],
          ),
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                drivers[0].name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey[800])
            ),
            child: FlatButton(
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Colors.blueGrey[800],
                  ),
                  SizedBox(width: 10),
                  Text(
                    "QR Code",
                    style: TextStyle(
                      color: Colors.blueGrey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                showalert(drivers[0].id);
                //String codeSanner = await BarcodeScanner.scan(); //barcode scnne
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: <Widget>[
              Icon(
                Icons.email,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                drivers[0].email,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.phone,
                color: Colors.blueGrey[800],
              ),
              SizedBox(width: 10),
              Text(
                drivers[0].phone,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  color: Colors.blueGrey[800],
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditProfile(driverid: drivers[0].id.toString())),
                      );
                    },
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]);
  }

  void showalert(driverid) async {
    qrData = driverid.toString();

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Center(
            child: AlertDialog(
              title: Text("Scan here:"),
              content:
              //Text(qrData),
              Container(
                width: 300.0,
                height: 300.0,
                child: QrImage(
                  data: qrData,
                ),
              ),
              actions: [
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
