import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class apiCommunicator1 {
  apiCommunicator1(this.serverAddress);

  String serverAddress = 'http://192.168.1.9/walklyapp/';
  String cookie;
  static const platformMethodChannel = const MethodChannel('walkly/native');
  String nativeMessage = '';

  Future<String> login(String email, String password) async {
    String _message = "error";
    try {
      final String result = await platformMethodChannel
          .invokeMethod('logIn', {"email": email, "password": password});
      _message = result;
    } on PlatformException catch (e) {
      _message = "Can't do native stuff ${e.message}.";
    }
    print(_message);
    cookie = _message;
    return _message;
  }

  Future<String> registerUser(String first_name, String last_name, String email,
      String password) async {
    //const platformMethodChannel = const MethodChannel('walkly/native');

    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('registerUser', {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password,
      });
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    print(_message);
    return _message;
  }

  Future<int> deleteProfile(String email) async {
    String url = this.serverAddress + 'deleteProfile';
    var response = await http.post(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<String> registerDealer(
      String company_name,
      int category_id,
      String bussiness_hours,
      String first_name,
      String last_name,
      String phone_number,
      String description,
      String email,
      String password,
      String city,
      String street_name,
      String post_code,
      String built_number) async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('registerDealer', {
        "company_name": company_name,
        "category_id": category_id,
        "business_hours": bussiness_hours,
        "first_name": first_name,
        "last_name": last_name,
        "phone_number": phone_number,
        "description": description,
        "email": email,
        "password": password,
        "city": city,
        "street_name": street_name,
        "post_code": post_code,
        "built_number": built_number
      });
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }

  Future<String> getOffers() async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    dynamic _message;
    try {
      final dynamic result =
          await platformMethodChannel.invokeMethod('getOffers');
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }

  Future<String> getAccountDetails() async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    dynamic _message;
    try {
      final dynamic result =
          await platformMethodChannel.invokeMethod('details_user');
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }

  Future<Map> useOffer() async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    dynamic _message;
    try {
      final dynamic result =
          await platformMethodChannel.invokeMethod('getOffers');
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }

  Future<String> makeOffer(String date_from_to, int coupon_count,
      int business_user_id, String description, int points) async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    dynamic _message;
    try {
      final dynamic result =
          await platformMethodChannel.invokeMethod('makeOffer', {
        "date_from_to": date_from_to,
        "coupon_count": coupon_count.toString(),
        "business_user_id": description.toString(),
        "points": points.toString(),
        "description": description
      });
      print(result);
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }
}
