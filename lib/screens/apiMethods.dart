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

  Future<int> login(String username, String password) async {
    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('login', {"text": "denis"});
      _message = result;
    } on PlatformException catch (e) {
      _message = "Can't do native stuff ${e.message}.";
    }
  }

  Future<String> registerDealer(String name, String address, String bussiness_hours, String description, String password) async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('registerDealer', {
        "name": name,
        "address": address,
        "bussiness_hours": bussiness_hours,
        "description": description,
        "password": password
        });
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }
  Future<String> registerUser(String first_name, String last_name, String email,
      String password) async {
    const platformMethodChannel = const MethodChannel('walkly/native');

    String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('registerUser', {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password
      });
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }
    return _message;
  }

  Future<int> deleteProfile(String email) async {
    String url = this.serverAddress + 'deleteProfile';
    var response = await http.post(Uri.parse(url), body: {'set-cookie': this.cookie});
    return jsonDecode(response.body);
  }
  Future<Map> getOffers() async {
    String url = this.serverAddress + 'getOffers';
    var response = await http.get(Uri.parse(url), body: {'set-cookie': this.cookie});
    return jsonDecode(response.body);
  }
  Future<Map> useOffer(int id) async {
    String url = this.serverAddress + 'useOffer';
    var response = await http.post(Uri.parse(url), body: {'set-cookie': this.cookie,
    'offerID': id});
    return jsonDecode(response.body);
  }
  Future<Map> makeOffer({int categoryID, String firmName, String describtion,
   String address, String price, int unitsPerOffer, String bussinessHours, String dateFromToDateDue}) async {
    String url = this.serverAddress + 'makeOffer';
    var response = await http.post(Uri.parse(url), body: {'set-cookie': this.cookie,
    "categoryID": categoryID,
    "firmName": firmName,
    "describtion": describtion,
    "address": address,
    "price": price,
    "unitsPerOffer": unitsPerOffer,
    "bussinessHours": bussinessHours,
    "dateFromToDateDue": dateFromToDateDue:
    });
    return jsonDecode(response.body);
  }
  Future<Map> deleteOffer(int offerID) async {
    String url = this.serverAddress + 'delteOffer';
    var response = await http.post(Uri.parse(url), body: {'set-cookie': this.cookie,
    "offerID": offerID});
    return jsonDecode(response.body);
  }
}
