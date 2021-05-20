import 'package:flutter/material.dart';
import 'package:zolma_driver/pages/login.dart';
import 'package:zolma_driver/pages/home.dart';
import 'package:zolma_driver/pages/delivery.dart';
import 'package:zolma_driver/pages/processdelivery.dart';
import 'package:zolma_driver/pages/Editprofile.dart';
import 'package:zolma_driver/pages/setting.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/',

  routes: {
    '/': (context) => login(),
    '/Home': (context) => MyBottomNavigationBar(),
    '/Delivery': (context) => DeliveryPage(),
    '/ProcessDelivery': (context) => ProcessDelivery(),
    '/EditProfile': (context) => EditProfile(),
    '/Setting': (context) => Setting(),
  },

));