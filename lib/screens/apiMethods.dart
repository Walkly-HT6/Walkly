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

  Future<String> registerUser(String first_name, String last_name, String email,
      String password) async {
    //const platformMethodChannel = const MethodChannel('walkly/native');

    /*String _message;
    try {
      final String result =
          await platformMethodChannel.invokeMethod('registerUser', {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password,
        "context": context
      });
      _message = result;
    } on PlatformException catch (e) {
      _message = "Unable to use native functions!";
    }*/
    var result =
        await http.post('http://192.168.1.9/walklyapp/register.php', body: {
      "first_name": first_name,
      "last_name": last_name,
      "email": email,
      "password": password,
    });
    print(result);
    return json.decode(result.body);
  }

  Future<int> deleteProfile(String email) async {
    String url = this.serverAddress + 'deleteProfile';
    var response = await http.post(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map> getOffers() {
    //TODO Da vzima spisuk s oferti
  }
  Future<Map> useOffer() {
    //TODO Da polzva oferta (user)
  }
  Future<Map> makeOffer() {
    //TODO Da pravi nova oferta (dealer)
  }
  Future<Map> deleteOffer() {
    //TODO Da trie sobstvena oferta (dealer)
  }
}
