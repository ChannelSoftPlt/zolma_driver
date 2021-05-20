import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:zolma_driver/object/Delivery.dart';

class DeliveryHistoryDetail extends StatefulWidget {
  final String deliveryid;

  DeliveryHistoryDetail({this.deliveryid});

  @override
  _DeliveryHistoryDetailState createState() => _DeliveryHistoryDetailState();
}

class _DeliveryHistoryDetailState extends State<DeliveryHistoryDetail> {
  final key = new GlobalKey<ScaffoldState>();
  List<Delivery> deliveryinfo = [];
  TextEditingController _editRemark;

  Future showDeliveryinfo(String deliveryid) async {
    return await Domain.callApi(Domain.getdelivery, {
      'checkrecord': '1',
      'deliveryid': deliveryid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[400],
        title: Text("Delivery Detail"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
        child: FutureBuilder(
            future: showDeliveryinfo(widget.deliveryid),
            builder: (context, object) {
              if (!object.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (object.connectionState == ConnectionState.done) {
                  Map data = object.data;
                  deliveryinfo = [];

                  if (data['status'] == '1') {
                    List getdelivery = data['getdelivery'];

                    deliveryinfo.addAll(getdelivery
                        .map((jsonObject) => Delivery.fromJson(jsonObject))
                        .toList());

                    _editRemark =
                        TextEditingController(text: deliveryinfo[0].note);

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
          Visibility(
            visible: deliveryinfo[0].picture != "",
            child: Container(
              child: Image.memory(
                  base64.decode(deliveryinfo[0].picture.toString())),
            ),
          ),
          Visibility(
            visible: deliveryinfo[0].signature != "",
            child: Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Image.memory(
                  base64.decode(deliveryinfo[0].signature.toString())),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              deliveryinfo[0].deliverycode + " (${deliveryinfo[0].name})",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "Match: ${deliveryinfo[0].identify == 1 ? "Yes" : "No"}",
              style: TextStyle(
                  color:
                  deliveryinfo[0].identify == 1 ? Colors.green : Colors.red,
                  fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            child: TextField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _editRemark,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                // labelText: "Remark",
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: RaisedButton(
                  padding: EdgeInsets.all(15.0),
                  color: Colors.blueGrey[800],
                  onPressed: () {
                    updateRemark(_editRemark);
                  },
                  child: Text(
                    "Update Remark",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          )
        ]);
  }

  void updateRemark(newremark) async {
    Map data = await Domain.callApi(Domain.getdelivery, {
      'updateremark': '1',
      'deliveryid': widget.deliveryid.toString(),
      'remark': newremark.text.toString(),
    });

    if(data["status"]=="1"){
      return _showSnackBar("Update Successfully");
    }else{
      return _showSnackBar("Somethings wrong. Please try again.");
    }
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }
}
