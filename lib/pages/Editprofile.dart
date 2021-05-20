import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:zolma_driver/object/DriverInfo.dart';

class EditProfile extends StatefulWidget {
  final String driverid;

  EditProfile({this.driverid});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  List<DriverInfo> driver = [];
  TextEditingController _editName;
  TextEditingController _editoldpswd;
  TextEditingController _editnewpswd;
  TextEditingController _editrepeatpswd;
  TextEditingController _editemail;
  TextEditingController _editphone;
  bool checkingvalue = true;

  Future fetchDealer() async {
    dynamic getdriverid = await FlutterSession().get("driverid");
    return await Domain.callApi(Domain.getdriverinfo,
        {'reading': '1', 'driverid': getdriverid.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Edit Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: fetchDealer(),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  if (data['status'] == '1') {
                    driver = [];
                    List getdriver = data['Driver'];

                    driver.addAll(getdriver
                        .map((jsonObject) => DriverInfo.fromJson(jsonObject))
                        .toList());

                    _editName = TextEditingController(text: driver[0].name);
                    _editoldpswd = TextEditingController();
                    _editnewpswd = TextEditingController();
                    _editrepeatpswd = TextEditingController();
                    _editemail = TextEditingController(text: driver[0].email);
                    _editphone = TextEditingController(
                        text: driver[0].phone.substring(3));

                    return CustomeView();
                  }
                }
              }
              return Center(child: Text("No Data"));
            }),
      ),
    );
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Company: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: _editName,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            //labelText: dealer[0].name,
            //hintText: dealer[0].name,
          ),
        ),
      ],
    );
  }

  Column buildDisplayContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Phone: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text("+60"),
                        ),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: _editphone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              //hintText: dealer[0].phone.substring(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "Email: ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _editemail,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        //hintText: dealer[0].email,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column buildDisplayPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Old Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editoldpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Enter old password",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "New Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editnewpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Enter new password",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            "Repeat Password: ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          obscureText: true,
          controller: _editrepeatpswd,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Repeat new password",
          ),
        ),
      ],
    );
  }

  Widget CustomeView() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              buildDisplayNameField(),
              buildDisplayContactField(),
              buildDisplayPasswordField(),
            ],
          ),
        ),
        RaisedButton(
          color: Colors.blueGrey[400],
          onPressed: () {
            updateProfile();
          },
          child: Text(
            "Update Profile",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,),
          ),
        )
        //Text(widget.dealerid),
      ],
    );
  }

  void updateProfile() async {

    _editnewpswd.text != _editrepeatpswd.text
        ? checkingvalue = false
        : checkingvalue = true;

    if (checkingvalue == true) {
      dynamic getdriverid = await FlutterSession().get("driverid");
      if (_editnewpswd.text.isEmpty && _editoldpswd.text.isEmpty && _editrepeatpswd.text.isEmpty) {

        await Domain.callApi(Domain.getdriverinfo, {
          'updatenopswd': '1',
          'driverid': getdriverid.toString(),
          'name': _editName.text,
          'email': _editemail.text,
          'phone': "+60"+_editphone.text,
        });
        return showalert();
      } else {

        Map data = await Domain.callApi(Domain.getdriverinfo, {
          'check': '1',
          'driverid': getdriverid.toString(),
          'password': _editoldpswd.text,
        });
        if(data['status']=="1") {
          await Domain.callApi(Domain.getdriverinfo, {
            'update': '1',
            'driverid': getdriverid.toString(),
            'name': _editName.text,
            'email': _editemail.text,
            'phone': "+60"+_editphone.text,
            'password': _editoldpswd.text,
            'newpassword': _editnewpswd.text,
          });
          return showalert();
        }else{
          return showpasswordalert();
        }
      }
    }else{
      return showalert();
    }
  }

  void showalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: checkingvalue == true ? Text("Update Successfully.") : Text("Update Unsuccessfully."),
          content: checkingvalue == true ? Text(
              "You have changed your personal information successfully.") : Text("Your password and repeat password are incorrect."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showpasswordalert() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error."),
          content: Text("Your password is incorrect."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
