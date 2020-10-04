import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:Walkly/screens/betterThemeData.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:Walkly/screens/apiMethods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

var apiCommunicator;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class RecordDetails extends StatefulWidget {
  RecordDetails(
      {this.serverAddress, this.cookie, this.selectedItem, this.themeData});
  String serverAddress;
  String cookie;
  Map selectedItem;
  Map<String, dynamic> tableData, tableProperties;
  String selectedTable = "index";
  BetterThemeData themeData;

  @override
  _RecordDetailsState createState() => new _RecordDetailsState(
      serverAddress: this.serverAddress,
      cookie: this.cookie,
      selectedItem: this.selectedItem,
      themeData: this.themeData);
}

class _RecordDetailsState extends State<RecordDetails> {
  _RecordDetailsState(
      {this.serverAddress,
      this.cookie,
      this.selectedItem,
      this.tableData,
      this.themeData});
  String serverAddress;
  String cookie;
  Map selectedItem;
  Map<String, dynamic> tableData, tableProperties;
  String selectedTable = "index";
  String _localPath;
  ReceivePort _port = ReceivePort();
  List<Widget> body = [];
  BetterThemeData themeData;

  @override
  void initState() {
    super.initState();

    apiCommunicator = apiCommunicator1(this.serverAddress);
    apiCommunicator.cookie = cookie;
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Future<List<Widget>> prepare() async {
    List<Widget> mybody = [];
    print(selectedItem);
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.height;
    double screenWidth = size.width;
    List<Widget> recordDetails = [];
    recordDetails.add(Divider(height: screenHeight / 20));
    recordDetails.add(Text(
      "Company name: ",
      style: TextStyle(fontSize: 16, color: themeData.textColor),
    ));
    var apiCommunicator = new apiCommunicator1(this.serverAddress);
    print(selectedItem);
    recordDetails.add(Text(
        this.selectedItem["business_user_id"]['company_name'],
        //showEditIcon: isSelected,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: themeData.textColor)));
    recordDetails.add(Text(
      "Working hours: ",
      style: TextStyle(fontSize: 16, color: themeData.textColor),
    ));
    //var apiCommunicator = new apiCommunicator1(this.serverAddress);
    print(selectedItem);
    recordDetails.add(Text(
        'this.selectedItem["business_user_id"][\'business_hours\']',
        //showEditIcon: isSelected,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: themeData.textColor)));
    recordDetails.add(Text(
      "Contact: ",
      style: TextStyle(fontSize: 16, color: themeData.textColor),
    ));
    //var apiCommunicator = new apiCommunicator1(this.serverAddress);
    print(selectedItem);
    recordDetails.add(Text(
        this.selectedItem["business_user_id"]['phone_number'],
        //showEditIcon: isSelected,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: themeData.textColor)));

    //CREATE DETAILS

    List<Widget> currContainer = [];

    mybody.add(Container(
        height: screenHeight,
        width: screenWidth,
        margin: EdgeInsets.all(10),
        decoration: new BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: themeData.shadowColor.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: themeData.firstLayerBoxColor,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recordDetails)));

    return mybody;
  }

  @override
  Widget build(BuildContext context) {
    prepare().then((value) {
      body = value;
    });
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeData.canvasColor,
      appBar: AppBar(
        backgroundColor: themeData.appBarColor,
        title: const Text('View Row'),
        actions: [],
      ),
      body: body[0],
    );
  }

  Widget _buildListSection(String title) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
        ),
      );
}
