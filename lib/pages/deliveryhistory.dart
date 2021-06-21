import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:zolma_driver/domain/domain.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zolma_driver/object/Delivery.dart';

import 'delivery_history_detail.dart';

class DeliveryHistory extends StatefulWidget {
  @override
  _DeliveryHistoryState createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController _textController = TextEditingController();

  List<Delivery> deliveries = [];
  //List<Delivery> deliveryinfo = [];

  //Pagination purpose
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  bool itemFinish = false;
  int currentPage = 1;
  int itemPerPage = 50;

  String query = '';
  Timer _debounce;

  Future fetchDelivery() async {

    dynamic getdriver = await FlutterSession().get("driverid");
    Map data = await Domain.callApi(Domain.getdelivery,
        {'readhistory': '1', 'query': query, 'driverid': getdriver.toString(), 'itemPerPage': itemPerPage.toString(), 'page': currentPage.toString()});

    deliveries = [];
    if (data['status'] == '1') {
      List responseJson = data['getdelivery'];

      deliveries.addAll(responseJson.map((e) => Delivery.fromJson(e)));
    } else {
      _refreshController.loadNoData();
      itemFinish = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchDelivery();
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
          ],
        ),
      ),
      body: mainContent(),
    );
  }

  Widget mainContent() {
    // print(deliveries.length.toString());
    return deliveries.length > 0
        ? SmartRefresher(
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
      child: customListView(),
    )
        : Container(
      child: Center(child: Text("No Data")),
    );
  }

  Widget customListView() {
    return ListView.builder(
      itemBuilder: (c, i) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              //showDeliveryinfo(deliveries[i].id);
              navigateToNextActivity(context, deliveries[i].id);
            },
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ListTile(
                  leading: Icon(Icons.arrow_back_ios),
                  title: GestureDetector(
                    child: Text(deliveries[i].name,
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ),
                  subtitle: GestureDetector(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            "Collection: " +
                                deliveries[i].collection.toString(),
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                            )),
                        Text(
                            "Document Code: "+deliveries[i].deliverycode,
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 14,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      itemCount: deliveries.length,
    );
  }

  _onRefresh() async {
    // monitor network fetch
    if (mounted)
      setState(() {
        deliveries.clear();
        currentPage = 1;
        itemFinish = false;
        fetchDelivery();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    if (mounted && !itemFinish) {
      setState(() {
        currentPage++;
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
    });
  }

  navigateToNextActivity(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DeliveryHistoryDetail(
        deliveryid: dataHolder.toString(),
      ),
    ));
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 500),
      content: new Text(message),
    ));
  }
}
