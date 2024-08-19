import 'dart:convert';

import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:zolma_driver/object/DriverInfo.dart';

import 'home.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:zolma_driver/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:zolma_driver/object/getDealerInfo.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class addDelivery extends StatefulWidget {
  @override
  _addDeliveryState createState() => _addDeliveryState();
}

class _addDeliveryState extends State<addDelivery> {
  final key = new GlobalKey<ScaffoldState>();
  List<DealerInfo> dealers = [];
  List<DriverInfo> drivers = [];
  List<DropdownMenuItem> items = [];

  TextEditingController setnote = TextEditingController();
  TextEditingController setdeliverycode = TextEditingController();
  String dealerName;
  String dealerValue;

  //QR Code Part
  String qrCodeResult = "Not Yet Scanned";
  String scannerResult;

  //image part
  File _image;
  var imagePath;
  ImageProvider provider;

  final picker = ImagePicker();
  var compressedFileSource;

  final String loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  Future fetchDealer() async {
    dynamic getdriver = await FlutterSession().get("driverid");
    Map data = await Domain.callApi(Domain.listdealer, {'getlist': '1', 'driverid': getdriver.toString()});

    dealers = [];
    if (data['status'] == '1') {
      List responseJson = data['Dealer'];

      dealers.addAll(responseJson.map((e) => DealerInfo.fromJson(e)));
    } else {
      _showSnackBar("No Dealer yet");
    }
    setState(() {
      for (int i = 0; i < dealers.length; i++) {
        items.add(DropdownMenuItem(
          child: Text(dealers[i].name),
          value: dealers[i].name,
        ));
      }
    });
  }

  Future fetchDriver() async {
    dynamic getdriverid = await FlutterSession().get("driverid");
    Map data = await Domain.callApi(Domain.getdriverinfo, {'reading': '1', 'driverid': getdriverid.toString()});

    drivers = [];
    if (data['status'] == '1') {
      List responseJson = data['Driver'];

      drivers.addAll(responseJson.map((e) => DriverInfo.fromJson(e)));
    } else {
      _showSnackBar("Catch failed in driver info.");
    }
    setState(() {});
  }

  Future fetchSelectedDealer(String dealerid) async {
    if (dealerid == dealerValue) {
      scannerResult = dealerValue;
      qrCodeResult = "match";
    } else {
      scannerResult = dealerValue;
      qrCodeResult = "Not match";
    }
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to submit the result before leaving the page?'),
            actions: <Widget>[
              TextButton(
                  child: new Text('Submit result'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    updateDelivery(qrCodeResult);
                  }),
              TextButton(
                  child: new Text('Stay this page'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Back'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    fetchDealer();
    fetchDriver();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        key: key,
        appBar: AppBar(backgroundColor: Colors.blueGrey[400], title: Text('Add Delivery')),
        body: mainContent(),
      ),
    );
  }

  Widget mainContent() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [imageWidget()],
        ),
      ),
    );
  }

  Widget imageWidget() {
    return Column(
      children: [
        Stack(fit: StackFit.passthrough, overflow: Overflow.visible, children: [
          Container(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () => _showSelectionDialog(context),
              child: compressedFileSource != null
                  ? Image.memory(
                      compressedFileSource,
                      width: double.infinity,
                    )
                  : Icon(
                      Icons.camera_alt,
                      size: 100,
                    ),
            ),
          ),
          Visibility(
            visible: compressedFileSource != null,
            child: Container(
                padding: EdgeInsets.all(5),
                height: 150,
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[200],
                  ),
                  onPressed: clearImage,
                )),
          ),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: EdgeInsets.all(15), child: Text("Document Code: ", style: TextStyle(color: Colors.black, fontSize: 24))),
            TextField(
              controller: setdeliverycode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Document Code",
              ),
            ),
            Container(padding: EdgeInsets.all(15), child: Text("Dealer:", style: TextStyle(color: Colors.black, fontSize: 20))),
            Container(
              padding: EdgeInsets.all(15),
              child: SearchableDropdown.single(
                items: items,
                value: dealerName,
                hint: "Select Dealer",
                searchHint: "Select Dealer",
                onChanged: (value) {
                  setState(() {
                    dealerName = value;
                    for (int a = 0; a < dealers.length; a++) {
                      if (dealerName == dealers[a].name) {
                        dealerValue = dealers[a].id.toString();
                      }
                    }
                    print(dealerValue);
                  });
                },
                isExpanded: true,
              ),
            ),
            Container(padding: EdgeInsets.all(15), child: Text("Remark", style: TextStyle(color: Colors.black, fontSize: 20))),
            TextField(
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: setnote,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: "Remark",
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey[800])),
              child: FlatButton(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text("Dealer QR Code :"),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "${qrCodeResult}",
                              style: TextStyle(color: qrCodeResult == "match" ? Colors.green : Colors.red, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.photo_camera_outlined),
                          Container(
                            padding: EdgeInsets.only(left: 15),
                            child: Text("Open Scanner"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  String codeSanner = await BarcodeScanner.scan(); //barcode scnner

                  fetchSelectedDealer(codeSanner);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    padding: EdgeInsets.all(15.0),
                    color: Colors.blueGrey[800],
                    onPressed: () {
                      showalert(qrCodeResult);
                    },
                    child: Text(
                      "Submit the Result",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  clearImage() {
    setState(() {
      compressedFileSource = null;
    });
  }

  /*-------------------------------Submit Delivery Info---------------------------------------------------*/
  void updateDelivery(matchresult) async {
    dynamic getdriver = await FlutterSession().get("driverid");

    if (compressedFileSource != null) {
      Map data = await Domain.callApi(Domain.getdriverinfo, {
        'adddelivery': '1',
        'deliverycode': setdeliverycode.text.toString(),
        'type': 'PR',
        'status': '2',
        'dealerid': dealerValue,
        'driverid': getdriver.toString(),
        'remark': setnote.text.toString(),
        'identity': matchresult,
        'image': compressedFileSource != null ? base64Encode(compressedFileSource).toString() : '',
        'creater': drivers[0].name,
      });

      if (data['status'] == '1') {
        //completed submit
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ));
      }
    } else {
      _showSnackBar("You must take photo before submit this case");
    }
  }

  void showalert(qrcode) async {
    print(dealerValue);
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit the Result"),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                updateDelivery(qrcode);
              },
            ),
            FlatButton(
              child: Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 500),
      content: new Text(message),
    ));
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Take Photo From"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text('Gallery', style: TextStyle(color: Colors.white)),
                      color: Colors.orangeAccent,
                      icon: Icon(
                        Icons.perm_media,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(false);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: RaisedButton.icon(
                      label: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blueAccent,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ));
        });
  }

  base64Data(String data) {
    switch (data.length % 4) {
      case 1:
        break;
      case 2:
        data = data + "==";
        break;
      case 3:
        data = data + "=";
        break;
    }
    return data;
  }

  /*
  * compress purpose
  * */
  Future getImage(isCamera) async {
    imagePath = await picker.getImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // compressFileMethod();
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = (await ImageCropper.cropImage(
        sourcePath: imagePath.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        )));
    if (croppedFile != null) {
      _image = croppedFile;
      compressFileMethod();
    }
  }

  void compressFileMethod() async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    compressedFileSource = await compressFile(file);
    setState(() {});
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<Uint8List> compressFile(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    return result;
  }

  countQuality(int quality) {
    if (quality <= 100)
      return 60;
    else if (quality > 100 && quality < 500)
      return 25;
    else
      return 20;
  }
}
