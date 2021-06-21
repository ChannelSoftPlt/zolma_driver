import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:zolma_driver/object/Delivery.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

  //image part
  File _image;
  var imagePath;
  ImageProvider provider;

  final picker = ImagePicker();
  var takenotephoto;

  int checking=0;

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
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
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


                    if(checking==0) {
                      if (deliveryinfo[0].notephoto != null) {
                        takenotephoto =
                            base64.decode(deliveryinfo[0].notephoto);
                      }else{
                        takenotephoto;
                      }
                    }else{
                      takenotephoto;
                    }

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
              child: Text("Take note photo",
                  style: TextStyle(color: Colors.black, fontSize: 20))),
          Stack(
              fit: StackFit.passthrough,
              overflow: Overflow.visible,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => _showSelectionDialog(context, "notephoto"),
                    child: takenotephoto != null
                        ? Image.memory(
                            takenotephoto,
                            width: double.infinity,
                          )
                        : Icon(
                            Icons.camera_alt,
                            size: 50,
                          ),
                  ),
                ),
                Visibility(
                  visible: takenotephoto != null,
                  child: Container(
                      padding: EdgeInsets.all(5),
                      height: 150,
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[200],
                        ),
                        onPressed: clearNoteImage,
                      )),
                ),
              ]),
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

  clearNoteImage() {
    setState(() {
      takenotephoto = null;
      checking=1;
    });
  }

  void updateRemark(newremark) async {
    Map data = await Domain.callApi(Domain.getdelivery, {
      'updateremarkV2': '1',
      'deliveryid': widget.deliveryid.toString(),
      'remark': newremark.text.toString(),
      'note_photo':
          takenotephoto != null ? base64Encode(takenotephoto).toString() : '',
    });

    if (data["status"] == "1") {
      return _showSnackBar("Update Successfully");
    } else {
      return _showSnackBar("Somethings wrong. Please try again.");
    }
  }

  /*-----------------------------------------photo compress-------------------------------------------*/
  Future<void> _showSelectionDialog(BuildContext context, String phototype) {
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
                      label: Text('Gallery',
                          style: TextStyle(color: Colors.white)),
                      color: Colors.orangeAccent,
                      icon: Icon(
                        Icons.perm_media,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getImage(false, phototype);
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
                        getImage(true, phototype);
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
  Future getImage(isCamera, phototype) async {
    imagePath = await picker.getImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    // compressFileMethod();
    _cropImage(phototype);
  }

  Future<Null> _cropImage(phototype) async {
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
      compressFileMethod(phototype);
    }
  }

  void compressFileMethod(phototype) async {
    await Future.delayed(Duration(milliseconds: 300));

    Uint8List bytes = _image.readAsBytesSync();
    final ByteData data = ByteData.view(bytes.buffer);

    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());
    checking=1;
    if (phototype == "notephoto") {
      takenotephoto = await compressFile(file);
    }
    // else {
    //   compressedFileSource = await compressFile(file);
    // }
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

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 1000),
      content: new Text(message),
    ));
  }
}
