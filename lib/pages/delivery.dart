import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geocoder/geocoder.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:zolma_driver/object/System.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:zolma_driver/object/Delivery.dart';
import 'package:zolma_driver/object/getDealerInfo.dart';
import 'package:zolma_driver/pages/processdelivery.dart';
import 'package:zolma_driver/domain/domain.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'adddelivery.dart';
import 'completedelivery.dart';
import 'deliveryhistory.dart';

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController _textController = TextEditingController();

  List<Delivery> deliveries = [];
  List<Delivery> currentdeliveries = [];
  List<System> systems = [];
  int checkposition = 0;
  List<DealerInfo> dealers = [];

  List<String> tickitem = [];
  int counttrue;
  int countPR;
  int aftercount;

  bool checkstatus = true;

  //Pagination purpose
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 50;

  String query = '';
  Timer _debounce;

  Future fetchDelivery() async {
    counttrue = 0;
    countPR = 0;
    tickitem = [];
    dynamic getdriver = await FlutterSession().get("driverid");
    Map data = await Domain.callApi(Domain.getdelivery,
        {'read': '1', 'query': query, 'driverid': getdriver.toString()});

    deliveries = [];
    currentdeliveries = [];
    if (data['status'] == '1') {
      List responseJson = data['getdelivery'];

      deliveries.addAll(responseJson.map((e) => Delivery.fromJson(e)));
      currentdeliveries.addAll(responseJson.map((e) => Delivery.fromJson(e)));

      for (int i = 0; i < deliveries.length; i++) {
        if (deliveries[i].status == 1) {
          counttrue = counttrue + 1;
        } else if (deliveries[i].status == 2) {
          countPR = countPR + 1;
        }
      }
      aftercount = counttrue + countPR;

      // print("aftercount: "+aftercount.toString());
      // print("counttrue: "+counttrue.toString());
      // print("countPR: "+countPR.toString());
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  Future fetchSystem() async {
    Map systemdata = await Domain.callApi(Domain.getsystem, {'read': '1'});

    systems = [];
    if (systemdata['status'] == '1') {
      List responseJsonsystem = systemdata['system'];
      systems.addAll(responseJsonsystem.map((e) => System.fromJson(e)));
      checkposition = systems[0].accessadddelivery;
    } else {
      _showSnackBar("Can't get system information.");
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchDelivery();
    fetchSystem();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search Here...',
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Visibility(
              visible: checkposition == 1,
              child: Expanded(
                flex: 1,
                child: Container(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => addDelivery()),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: IconButton(
                  icon: Icon(Icons.article_outlined),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeliveryHistory()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: mainContent(),
    );
  }

  Widget mainContent() {
    //print(deliveries.length.toString());
    if (deliveries.length > 0) {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = CircularProgressIndicator();
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: mainPageView(),
      );
    } else {
      return Container(
        child: Center(child: Text("No Data")),
      );
    }
  }

  Widget mainPageView() {
    return Column(
      children: <Widget>[
        Expanded(flex: 11, child: customListView()),
        Visibility(
          visible: tickitem.length > 0,
          child: Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Align(
                      alignment: FractionalOffset.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 15.0, bottom: 5.0),
                        child: Text(
                          'Total: ${tickitem.length}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(2.0),
                    color: Colors.blueGrey[800],
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < deliveries.length; i++) {
                                if (deliveries[i].status == 0) {
                                  tickitem.add(deliveries[i].deliverycode);
                                  deliveries[i].status = 1;
                                }
                              }
                            });
                          },
                          child: Text(
                            'Pick up All',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    margin: const EdgeInsets.all(2.0),
                    color: Colors.blueGrey[800],
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: FlatButton(
                          onPressed: () {
                            updatepickupStatus();
                          },
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget customListView() {
    if (deliveries.length > 0) {
      return ListView.builder(
        itemBuilder: (c, i) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Visibility(
                  visible: countPR != 0,
                  child: Visibility(
                    visible: i == 0,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text("Return Product",
                            style: TextStyle(
                              fontSize: 20,
                            ))),
                  ),
                ),
                Visibility(
                  visible: counttrue != 0,
                  child: Visibility(
                    visible: i == countPR,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                        child: Text("Deliver",
                            style: TextStyle(
                              fontSize: 20,
                            ))),
                  ),
                ),
                Visibility(
                  visible: i == aftercount,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                      child: Text("Pick Up",
                          style: TextStyle(
                            fontSize: 20,
                          ))),
                ),
                //Product Return Part*************************************
                currentdeliveries[i].status == 2
                    ? GestureDetector(
                  onTap: () {
                    showDealerinfo(deliveries[i].dealerid,
                        deliveries[i].deliverycode, deliveries[i].remark);
                  },
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Slidable(
                        actions: <Widget>[
                          IconSlideAction(
                              icon: Icons.more,
                              caption: 'Completed',
                              color: Colors.blueGrey[400],
                              onTap: () {
                                navigateToCompleteState(
                                    context,
                                    deliveries[i].id,
                                    deliveries[i].deliverycode,
                                    deliveries[i].type);
                              }),
                        ],
                        child: ListTile(
                          leading: Icon(Icons.arrow_back_ios),
                          trailing: Text(""),
                          title: GestureDetector(
                            child: Text(
                                deliveries[i].urgent == 1
                                    ? deliveries[i].name + "\u{26A0}"
                                    : deliveries[i].name,
                                style: TextStyle(
                                  fontSize: 18,
                                )),
                          ),
                          subtitle: GestureDetector(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    "Collection: RM " +
                                        deliveries[i].collection.toString(),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                    )),
                                Text(
                                    "SC: " +
                                        deliveries[i].type +
                                        " " +
                                        deliveries[i].systemcode,
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 14,
                                    )),

                                Text(
                                  "DC: " +
                                    deliveries[i].deliverycode,
                                    style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 14,
                                )),
                              ],
                            ),
                          ),
                        ),
                        actionPane: SlidableDrawerActionPane(),
                      ),
                    ),
                  ),
                )
                //Pick up Part*************************************
                    : currentdeliveries[i].status == 1
                    ? GestureDetector(
                  onTap: () {
                    showDealerinfo(
                        deliveries[i].dealerid,
                        deliveries[i].deliverycode,
                        deliveries[i].remark);
                  },
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Slidable(
                        actions: <Widget>[
                          IconSlideAction(
                              icon: Icons.more,
                              caption: 'Completed',
                              color: Colors.blueGrey[400],
                              onTap: () {
                                deliveries[i].type != "OD"
                                    ? navigateToNextActivity(
                                    context,
                                    deliveries[i].id,
                                    deliveries[i].deliverycode,
                                    deliveries[i].type)
                                    : navigateToCompleteState(
                                    context,
                                    deliveries[i].id,
                                    deliveries[i].deliverycode,
                                    deliveries[i].type);
                              }),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              icon: Icons.delete,
                              color: Colors.blueGrey[800],
                              caption: 'Unpick',
                              onTap: () {
                                Unpickup(deliveries[i].id);
                              })
                        ],
                        child: ListTile(
                          leading: Icon(Icons.arrow_back_ios),
                          trailing: Icon(Icons.arrow_forward_ios),
                          title: GestureDetector(
                            child: Text(
                                deliveries[i].urgent == 1
                                    ? deliveries[i].name + "\u{26A0}"
                                    : deliveries[i].name,
                                style: TextStyle(
                                  color: deliveries[i].remark != "" ? Colors.red : Colors.black,
                                  fontSize: 18,
                                )),
                          ),
                          subtitle: GestureDetector(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    "Collection: RM " +
                                        deliveries[i].collection.toString(),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                    )),
                                Text(
                                    "SC: " +
                                        deliveries[i].type +
                                        " " +
                                        deliveries[i].systemcode,
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 14,
                                    )),
                                Text(
                                    "DC: " +
                                        deliveries[i].deliverycode,
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        actionPane: SlidableDrawerActionPane(),
                      ),
                    ),
                  ),
                )
                //Pending Part*************************************
                    : GestureDetector(
                  onTap: () {
                    showDealerinfo(
                        deliveries[i].dealerid,
                        deliveries[i].deliverycode,
                        deliveries[i].remark);
                  },
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ListTile(
                        leading: Text(""),
                        title: GestureDetector(
                          child: Text(
                              deliveries[i].urgent == 1
                                  ? deliveries[i].name + "\u{26A0}"
                                  : deliveries[i].name,
                              style: TextStyle(
                                color: deliveries[i].remark != "" ? Colors.red : Colors.black,
                                fontSize: deliveries[i].remark != "" ? 20 : 18,
                              )),
                        ),
                        subtitle: GestureDetector(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  "Collection: RM " +
                                      deliveries[i].collection.toString(),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                  )),
                              Text(
                                  "SC: " +
                                      deliveries[i].type +
                                      " " +
                                      deliveries[i].systemcode,
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                  )),
                              Text(
                                  "DC: " +
                                      deliveries[i].deliverycode,
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 14,
                                  )),
                            ],
                          ),
                        ),
                        // trailing: Icon(Icons.arrow_forward_ios),
                        trailing: Checkbox(
                          value: deliveries[i].status == 1,
                          onChanged: (bool value) {
                            setState(() {
                              deliveries[i].status = value ? 1 : 0;

                              if (value == true) {
                                tickitem
                                    .add(deliveries[i].deliverycode);
                              } else {
                                tickitem.remove(
                                    deliveries[i].deliverycode);
                              }

                              // updatepickupStatus(
                              //     deliveries[i].deliverycode, value);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        itemCount: deliveries.length,
      );
    } else {
      return Container(
        height: 220,
        child: Text('No data'),
      );
    }
  }

  navigateToNextActivity(
      BuildContext context, int dataHolder, String deliverycode, String type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProcessDelivery(
        deliveryid: dataHolder.toString(),
        deliverycode: deliverycode,
        deliverytype: type,
      ),
    ));
  }

  navigateToCompleteState(
      BuildContext context, int dataHolder, String deliverycode, String type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CompleteDelivery(
        deliveryid: dataHolder.toString(),
        deliverycode: deliverycode,
        deliverytype: type,
      ),
    ));
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        deliveries.clear();
        currentPage = 1;
        itemFinish = false;
        fetchDelivery();
        fetchSystem();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
        fetchDelivery();
        fetchSystem();
      });
    }
    _refreshController.loadComplete();
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      deliveries.clear();
      currentPage = 1;
      itemFinish = false;

      this.query = query;
      fetchDelivery();
      fetchSystem();
    });
  }

  void updatepickupStatus() async {
    Map data = await Domain.callApi(Domain.getdelivery,
        {'updatestatus': '1', 'delivery': jsonEncode(deliveries)});

    if (data['status'] == '1') {
      setState(() {
        fetchDelivery();
        fetchSystem();
        _showSnackBar('Pick up Successfully.');
      });
    } else {
      _showSnackBar('Something error! Please reflesh this page.');
    }
  }

  void Unpickup(deliveryid) async {
    Map data = await Domain.callApi(Domain.getdriverinfo, {
      'unpickup': '1',
      'deliveryid': deliveryid.toString(),
    });

    if (data['status'] == '1') {
      setState(() {
        fetchDelivery();
        fetchSystem();
        _showSnackBar('Cancel pick up Completed!');
      });
    }
  }

  void showDealerinfo(int dealerid, String deliverycode, String remark) async {
    Map data = await Domain.callApi(Domain.listdealer, {
      'reading': '1',
      'dealerid': dealerid.toString(),
    });

    if (data['status'] == '1') {
      List responseJson = data['Dealer'];
      dealers = [];

      dealers.addAll(responseJson.map((e) => DealerInfo.fromJson(e)));
    } else {
      _showSnackBar('Something error! Please reflesh this page.');
    }

    setState(() {});

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dealers[0].name + " ($deliverycode)"),
          // content: Text('Phone: ${dealers[0].phone}'
          //     '\nAddress: ${dealers[0].address} ${dealers[0].postcode} ${dealers[0].city} ${dealers[0].state} ${dealers[0].country}'),
          content: FlatButton(
            onPressed: () {
              launch(('tel://${dealers[0].phone}'));
            },
            child: Text('Phone: ${dealers[0].phone}'
                '\nRemark: $remark'),
          ),
          actions: [
            FlatButton(
              child: Text("Link GPS"),
              onPressed: () {
                Navigator.of(context).pop();
                String location = dealers[0].address +
                    dealers[0].postcode +
                    dealers[0].city +
                    dealers[0].state +
                    dealers[0].country;
                checkgps(location, dealers[0].name);
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

  void checkgps(String locations, String dealerName) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(locations);
    var first = addresses.first;
    //print("${first.coordinates.longitude} : ${first.coordinates.latitude}");

    Coords location =
    new Coords(first.coordinates.latitude, first.coordinates.longitude);
    final availableMaps = await MapLauncher.installedMaps;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: location,
                        title: dealerName,
                        description: dealerName,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
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
}
