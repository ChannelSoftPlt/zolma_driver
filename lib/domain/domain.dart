import 'dart:convert';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://zolmaorder.com/order/mobile/';

  static var getdelivery = domain + 'delivery/index.php';
  static var listdealer = domain + 'dealer/index.php';
  static var getdriverinfo = domain + 'driver/index.php';
  static var getsystem = domain + 'system/index.php';

  static callApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return jsonDecode(response.body);
  }
}

String filelink="https://zolmaorder.com/order/filename/";



