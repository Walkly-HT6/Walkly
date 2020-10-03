import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Walkly/screens/apiMethods.dart';
import 'package:Walkly/screens/recordDetails.dart';
//import 'package:myCactusApp/screens/datatable.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'betterThemeData.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:http/http.dart' as http;

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';

GlobalKey _keyRed = GlobalKey();
var apiCommunicator;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class MenuDashboard extends StatefulWidget {
  String cookie;
  String serverAddress;
  String name;
  BuildContext myContext;
  final platform;
  BetterThemeData themeData;
  MenuDashboard(this.cookie, this.serverAddress, this.name, this.myContext,
      this.platform, this.themeData);
  @override
  _MenuDashboardPageState createState() => _MenuDashboardPageState(
      this.cookie,
      this.serverAddress,
      this.name,
      this.myContext,
      this.platform,
      this.themeData);
}

class _MenuDashboardPageState extends State<MenuDashboard>
    with SingleTickerProviderStateMixin {
  _MenuDashboardPageState(this.cookie, this.serverAddress, this.name,
      this.context, this.platform, this.themeData);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //MUST
  BetterThemeData themeData;
  String cookie;
  String serverAddress;
  String name;
  List jsonMenu = ['test'];
  BuildContext context;
  //final flutterWebViewPlugin = FlutterWebviewPlugin();
  final platform;

  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();
  Widget themeIcon;
  double points = 33333;
  //MENU ANIMATION
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  String selectedTable = "index";

  String tableScreenName = "dsd";
  List<Marker> allMarkers = [];

  GoogleMapController _mapscontroller;
  //DATATABLE
  List<DataRow> _rowList = [];
  List<DataColumn> _tableTemplate = [];

  List<Widget> gridItemList = [];

  Color buttonColors = Colors.lightBlue[100];
  Map selectedItem;
  int selectedItemID;
  Map<String, dynamic> tableData, tableProperties;
  final filterKey = TextEditingController();
  String oldfilterKey;
  int currentPage = 1;
  int recordsPerLoad = 20;
  int currentPageRowCount;
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();
    apiCommunicator = new apiCommunicator1(this.serverAddress);

    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);

    setTheme();
    _isLoading = true;
    _permissionReady = false;
    slides.add(Slide(
      title: "Main",
    ));
    slides.add(Slide(
      title: "Maps",
    ));
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(40.7128, -74.0060)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRow() {
    _rowList = [];

    for (int i = 0; i < currentPageRowCount; i++) {
      //this.tableData['totalCount']
      List<DataCell> currRow = [];
      bool isSelected = false;
      for (int k = 0; k < this.tableProperties['data'].length; k++) {
        isSelected = false;
        for (int k = 0; k < this.tableProperties['data'].length; k++) {
          if (this.tableData['data'][i] == this.selectedItem ? true : false) {
            isSelected = true;
          }
        }

        currRow.add(
          DataCell(
            Text(this
                .tableData['data'][i]
                    [this.tableProperties['data'][k]['NameField']]
                .toString()),
            //showEditIcon: isSelected,
            onTap: () {
              setState(() {
                this.buttonColors = Colors.blue;
                this.selectedItem = this.tableData['data'][i];
                this.selectedItemID = i;
                build(context);
              });
            },
          ),
        );
      }
      _rowList.add(DataRow(
        cells: currRow,
        selected: isSelected,
      ));
    }
  }

  void buildTabletemplate() {
    _tableTemplate = [];
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      //print(this.tableProperties['data'][i]['fCaption']);
      _tableTemplate.add(DataColumn(
          label: GestureDetector(
              child: Row(children: [
                Text(this.tableProperties['data'][i]['fCaption']),
                //Icon(Icons.search, color: Colors.grey[700])
              ]),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Филтрирай по " +
                          this.tableProperties['data'][i]['fCaption']),
                      content: Stack(children: [
                        TextField(
                          controller: filterKey,
                          decoration: InputDecoration(
                            hintText: this.tableProperties['data'][i]
                                ['fCaption'],
                          ),
                        )
                      ]),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () async {
                            //this.buttonColors = Colors.lightBlue[100];
                            //this.selectedItem = {};
                            this.tableData = await apiCommunicator
                                .filterTableByField(
                                    this.selectedTable,
                                    this.tableProperties['data'][i]
                                        ['NameField'],
                                    filterKey.text)
                                .then((Map<String, dynamic> value) {
                              setState(() {
                                build(context);
                              });
                            });
                            setState(() {
                              build(context);
                            });

                            Navigator.of(context).pop();
                          },
                          child: Text("GO"),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: Text("CANCEL"),
                        )
                      ],
                    );
                  },
                );
              })));
    }
  }

  Future<int> setTheme() async {
    var instance = await SharedPreferences.getInstance();
    if (instance.getKeys().contains('theme')) {
      switch (instance.getString('theme')) {
        case 'light':
          themeData = BetterThemeData(
              logoColor: Color.fromRGBO(3, 169, 244, 1),
              canvasColor: Color.fromARGB(255, 242, 242, 242),
              textColor: Colors.black,
              appBarLabelColor: Color.fromRGBO(3, 169, 244, 1),
              shadowColor: Colors.grey[600],
              secondaryTextColor: Colors.grey[700],
              firstLayerBoxColor: Color.fromRGBO(3, 169, 244, 1),
              appBarColor: Color.fromRGBO(3, 169, 244, 1),
              secondaryLayerBoxColor: Colors.lightBlue[700]);
          this.themeIcon = Icon(Icons.brightness_7, color: Colors.grey);
          break;
        case 'dark':
          themeData = BetterThemeData(
              logoColor: Color.fromRGBO(3, 169, 244, 1),
              canvasColor: Colors.grey[850],
              textColor: Colors.white,
              appBarLabelColor: Color.fromRGBO(3, 169, 244, 1),
              shadowColor: Colors.grey[800],
              secondaryTextColor: Colors.grey[400],
              //firstLayerBoxColor: Color.fromRGBO(3, 169, 244, 1),
              appBarColor: Colors.grey[850],
              firstLayerBoxColor: Colors.lightBlue[800],
              secondaryLayerBoxColor: Colors.lightBlue[700]);

          this.themeIcon = Icon(Icons.brightness_3, color: Colors.grey);
          break;
      }
    } else {
      instance.setString('theme', 'light');
      setTheme();
    }
    return 1;
  }

  void changeTheme() async {
    var instance = await SharedPreferences.getInstance();
    if (instance.getString('theme') == 'light') {
      instance.setString('theme', 'dark');
      setState(() {
        setTheme();
      });
      return;
    }
    if (instance.getString('theme') == 'dark') {
      instance.setString('theme', 'light');
      setState(() {
        setTheme();
      });
      return;
    }
  }

  void fillMenu(context) {
    navigationMenu = [];
    navigationMenu.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: FlatButton(
            child: Align(
                alignment: Alignment.topLeft,
                child: Text("Account",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400))),
            onPressed: () async {
              this.tableScreenName = "Account";
              this.buttonColors = Colors.lightBlue[100];
              this.selectedItem = {};
              this.filterKey.clear();
              this.currentPage = 1;

              Map<String, dynamic> tableInfoLocal;
              print("1");
              apiCommunicator.cookie = cookie;
              print("1");
              setState(() {
                _controller.reverse();
                isCollapsed = !isCollapsed;
                build(context);
              });
            })));
    navigationMenu.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: FlatButton(
            child: Align(
                alignment: Alignment.topLeft,
                child: Text("Marketplace",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400))),
            onPressed: () async {
              this.tableScreenName = "Marketplace";
              this.buttonColors = Colors.lightBlue[100];
              this.selectedItem = {};
              this.filterKey.clear();
              this.currentPage = 1;

              Map<String, dynamic> tableInfoLocal;
              print("1");
              apiCommunicator.cookie = cookie;

              print("1");
              setState(() {
                _controller.reverse();
                isCollapsed = !isCollapsed;
                build(context);
              });
            })));
    navigationMenu.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          //color: Colors.grey
        ),
        //width: 240,
        child: FlatButton(
          //backgroundColor: Colors.blue,
          //color: Colors.cyan,
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                  "Theme: " +
                      (themeData.canvasColor ==
                              Color.fromARGB(255, 242, 242, 242)
                          ? "Light"
                          : "Dark"),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400))),
          onPressed: () {
            changeTheme();
          },
        )));
    navigationMenu.add(Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          //color: Colors.grey
        ),
        //width: 240,
        child: FlatButton(
          //backgroundColor: Colors.blue,
          //color: Colors.cyan,
          child: Align(
              alignment: Alignment.topLeft,
              child: Text("Log out",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400))),
          onPressed: () {},
        )));
  }

  void getAccountDetails(String name, context) {
    Size size = MediaQuery.of(context).size;
    var screenHeight = size.height;
    var screenWidth = size.width;
    userAccount = [];
    /*userAccount.add(Container(
      height: 72,
      alignment: Alignment.bottomLeft,
      child: Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 24.0,
      )));
  userAccount.add(Container(
      height: 75,
      alignment: Alignment.bottomLeft,
      child: Text(" " + name,
          style: TextStyle(color: Colors.white, fontSize: 22))));*/
    userAccount.add(Container(
        height: screenHeight / 6.1,
        alignment: Alignment.bottomLeft,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.account_circle,
                color: Colors.white,
                size: screenHeight / 10,
              )
            ])));
    userAccount.add(Container(
        height: screenHeight / 7,
        alignment: Alignment.bottomLeft,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(" " + name.split(" ")[0],
                  style: TextStyle(color: Colors.white, fontSize: 22)),
              Text(" " + name.split(" ")[1],
                  style: TextStyle(color: Colors.white, fontSize: 22))
            ])));
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding..");
    fillMenu(this.context);
    getAccountDetails(name, this.context);
    Size size = MediaQuery.of(this.context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    //if (apiCommunicator.cookie != null) {

    return WillPopScope(
        onWillPop: () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Color(0xFF333333),
            body: PageView(
              controller: null,
              children: [
                Stack(
                  children: <Widget>[
                    menu(this.context),
                    dashboard(this.context),
                  ],
                ), //WebView()
              ],
            ) /*Stack(
            children: <Widget>[
              menu(this.context),
              dashboard(this.context),
            ],
          ),*/
            ));
    //}
    /* else {
      print("MenuDashboard");
      return Scaffold(
        backgroundColor: Color(0xFF333333),
        body: Stack(
          children: <Widget>[
            dashboard(context),
          ],
        ),
      );
    }*/
  }

  void _addGrid() {
    this.gridItemList = [];

    for (int i = 0; i < currentPageRowCount; i++) {
      //this.tableData['totalCount']
      List<Widget> currRow = [];
      bool isSelected = false;
      for (int k = 0; k < this.tableProperties['data'].length; k++) {
        isSelected = false;
        for (int j = 0; j < this.tableProperties['data'].length; j++) {
          if (this.tableData['data'][i] == this.selectedItem ? true : false) {
            isSelected = true;
          }
        }
        currRow.add(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            this.tableProperties['data'][k]['fCaption'] + ": ",
            style: TextStyle(fontSize: 16, color: themeData.textColor),
          ),
          Text(
              this
                  .tableData['data'][i]
                      [this.tableProperties['data'][k]['NameField']]
                  .toString(),
              //showEditIcon: isSelected,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: themeData.textColor))
        ]));
      }
      gridItemList.add(GestureDetector(
          child: Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
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
              //padding: const EdgeInsets.all(8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: currRow)),
          onTap: () {
            setState(() {
              this.buttonColors = Colors.blue;
              this.selectedItem = this.tableData['data'][i];
              this.selectedItemID = i;
              build(context);
            });
            print("details");
            print(selectedItem);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => RecordDetails(
                    serverAddress: this.serverAddress,
                    cookie: this.cookie,
                    selectedItem: this.selectedItem,
                    tableData: this.tableData,
                    tableProperties: this.tableProperties,
                    selectedTable: this.selectedTable,
                    themeData: this.themeData)));
          }));
    }
  }

  Widget datagridPageBuild(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var screenHeight = size.height;
    var screenWidth = size.width;
    apiCommunicator.cookie = apiCommunicator.cookie;
    print("Updating datatable");
    _addGrid();
    _addRow();
    buildTabletemplate();
    Widget dataSpot;
    if (this.gridItemList.length > 0) {
      dataSpot = ListView(
        primary: false,
        //childAspectRatio: 1.6,
        padding: const EdgeInsets.all(5),
        //crossAxisSpacing: 10,
        //mainAxisSpacing: 10,
        //crossAxisCount: 1,
        children: this.gridItemList,
      );
    } else {
      dataSpot = Container(
          padding: EdgeInsets.fromLTRB(0, screenHeight / 3, 0, 0),
          child: Text("Няма намерени данни",
              style: TextStyle(color: Colors.grey)));
    }
    return Column(children: <Widget>[
      Row(children: [
        SizedBox(width: (screenWidth - screenWidth / 1.5) / 2),
        SizedBox(
          height: screenHeight / 12.75,
          width: screenWidth / 1.5,
          child: TextField(
            style: TextStyle(color: themeData.textColor),
            controller: filterKey,
            cursorColor: Colors.lightBlue,
            onChanged: (change) {
              oldfilterKey = change;
              Timer(Duration(milliseconds: 1500), () async {
                if (change == oldfilterKey) {
                  var apiCom = apiCommunicator1(this.serverAddress);
                  apiCom.cookie = this.cookie;
                  this.currentPage = 1;
                  /*await apiCom
                      .getOffers(this.selectedTable, this.currentPage,
                          this.recordsPerLoad,
                          filter: change, fields: this.tableProperties['data'])
                      .then((value) {
                    this.tableData = value;

                    if (this.tableData['totalCount'] >
                        (this.currentPage) * recordsPerLoad) {
                      this.currentPageRowCount = this.recordsPerLoad;
                    } else {
                      this.currentPageRowCount = this.tableData['totalCount'] -
                          (this.currentPage - 1) * recordsPerLoad;
                    }
                  });*/
                  setState(() {
                    build(context);
                  });
                }
              });
            },
            autofocus: false,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.lightBlue,
              ),
              labelStyle: TextStyle(color: Colors.lightBlue),
              labelText: 'Filter',
              fillColor: themeData.textColor,
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.lightBlue, width: 2.0),
                  borderRadius: BorderRadius.circular(25.0)),
            ),
          ),
        ),
        SizedBox(width: (screenWidth - screenWidth / 1.5) / 2),
      ]),
      Divider(
        color: themeData.canvasColor, //Color(0xFF333333),
        height: 10,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ),
      Divider(
        color: Colors.lightBlue, //Color(0xFF333333),
        height: 2,
        thickness: 2,
        indent: null,
        endIndent: 0,
      ),
      Container(
          key: _keyRed,
          height: MediaQuery.of(context).size.height / 1.4679,
          child:
              /*SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              // dragStartBehavior: DragStartBehavior.down,
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: _tableTemplate, rows: _rowList),
            )),*/
              dataSpot),
      Divider(
        color: Colors.lightBlue, //Color(0xFF333333),
        height: 2,
        thickness: 2,
        indent: null,
        endIndent: 0,
      ),
      Divider(
        color: themeData.canvasColor, //Color(0xFF333333),
        height: 10,
        thickness: 2,
        indent: null,
        endIndent: 0,
      ),
      pager(this.currentPage)
    ]);
  }

  Widget pager(int currentPage) {
    List<Widget> pages = [];
    var apiCom = apiCommunicator1(this.serverAddress);
    apiCom.cookie = this.cookie;

    if (currentPage > 2) {
      pages.add(SizedBox(
          width: screenWidth / 5,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(-10, 0, -10, 0),
            onPressed: () async {
              setState(() {
                this.currentPage -= 2;
              });
              /*await apiCom
                  .getTableContent(
                      this.selectedTable, this.currentPage, this.recordsPerLoad)
                  .then((Map<String, dynamic> value) {
                this.tableData = value;
                if (this.tableData['totalCount'] >
                    (this.currentPage) * recordsPerLoad) {
                  this.currentPageRowCount = this.recordsPerLoad;
                } else {
                  this.currentPageRowCount = this.tableData['totalCount'] -
                      (this.currentPage - 1) * recordsPerLoad;
                }
              });*/
              print("1");
              setState(() {
                build(context);
              });
            },
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Text((currentPage - 2).toString(),
                style: TextStyle(color: Colors.white)),
            shape: CircleBorder(),
            constraints: const BoxConstraints(minWidth: 68.0, minHeight: 36.0),
          )));
    } else {
      pages.add(SizedBox(
        width: screenWidth / 5,
      ));
    }
    if (currentPage > 1) {
      pages.add(SizedBox(
          width: screenWidth / 5,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(-10, 0, -10, 0),
            onPressed: () async {
              setState(() {
                this.currentPage -= 1;
              });
              /*await apiCom
                  .getTableContent(
                      this.selectedTable, this.currentPage, this.recordsPerLoad)
                  .then((Map<String, dynamic> value) {
                this.tableData = value;
                if (this.tableData['totalCount'] >
                    (this.currentPage) * recordsPerLoad) {
                  this.currentPageRowCount = this.recordsPerLoad;
                } else {
                  this.currentPageRowCount = this.tableData['totalCount'] -
                      (this.currentPage - 1) * recordsPerLoad;
                }
              });*/
              print("1");
              setState(() {
                build(context);
              });
            },
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Text((currentPage - 1).toString(),
                style: TextStyle(color: Colors.white)),
            shape: CircleBorder(),
            constraints: const BoxConstraints(minWidth: 68.0, minHeight: 36.0),
          )));
    } else {
      pages.add(SizedBox(
        width: screenWidth / 5,
      ));
    }
    pages.add(SizedBox(
        width: screenWidth / 5,
        child: RawMaterialButton(
          padding: EdgeInsets.fromLTRB(-10, 0, -10, 0),
          onPressed: () {},
          elevation: 2.0,
          fillColor: Colors.blue,
          child: Text((currentPage).toString(),
              style: TextStyle(color: Colors.white)),
          shape: CircleBorder(),
          constraints: const BoxConstraints(minWidth: 68.0, minHeight: 46.0),
        )));

    if (this.tableData['totalCount'] > (this.currentPage) * recordsPerLoad) {
      pages.add(SizedBox(
          width: screenWidth / 5,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(-10, 0, -10, 0),
            onPressed: () async {
              setState(() {
                this.currentPage += 1;
              });
              /*await apiCom
                  .getTableContent(
                      this.selectedTable, this.currentPage, this.recordsPerLoad)
                  .then((Map<String, dynamic> value) {
                this.tableData = value;
                if (this.tableData['totalCount'] >
                    (this.currentPage) * recordsPerLoad) {
                  this.currentPageRowCount = this.recordsPerLoad;
                } else {
                  this.currentPageRowCount = this.tableData['totalCount'] -
                      (this.currentPage - 1) * recordsPerLoad;
                }
              });*/
              print("1");
              setState(() {
                build(context);
              });
            },
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Text((currentPage + 1).toString(),
                style: TextStyle(color: Colors.white)),
            shape: CircleBorder(),
            constraints: const BoxConstraints(minWidth: 68.0, minHeight: 36.0),
          )));
    } else {
      pages.add(SizedBox(
        width: screenWidth / 5,
      ));
    }
    if (this.tableData['totalCount'] >
        (this.currentPage + 1) * recordsPerLoad) {
      pages.add(SizedBox(
          width: screenWidth / 5,
          child: RawMaterialButton(
            padding: EdgeInsets.fromLTRB(-10, 0, -10, 0),
            onPressed: () async {
              setState(() {
                this.currentPage += 2;
              });
              /*await apiCom
                  .getTableContent(
                      this.selectedTable, this.currentPage, this.recordsPerLoad)
                  .then((Map<String, dynamic> value) {
                this.tableData = value;
                if (this.tableData['totalCount'] >
                    (this.currentPage) * recordsPerLoad) {
                  this.currentPageRowCount = this.recordsPerLoad;
                } else {
                  this.currentPageRowCount = this.tableData['totalCount'] -
                      (this.currentPage - 1) * recordsPerLoad;
                }
              });*/
              print("1");
              setState(() {
                build(context);
              });
            },
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Text((currentPage + 2).toString(),
                style: TextStyle(color: Colors.white)),
            shape: CircleBorder(),
            constraints: const BoxConstraints(minWidth: 68.0, minHeight: 36.0),
          )));
    } else {
      pages.add(SizedBox(
        width: screenWidth / 5,
      ));
    }

    return SizedBox(
      width: screenWidth,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: pages),
    );
  }

  Widget menu(context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _menuScaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                //height: 683.0,
                height: screenHeight,
                width: screenWidth / 1.65,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: userAccount,
                      ),
                      SizedBox(
                        height: screenHeight / 17,
                      ),
                      Container(
                        height: screenHeight / 1.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: navigationMenu,
                          /*Row(
                              children: [
                                FlatButton(
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      changeTheme();
                                    },
                                    child: themeIcon),
                                FlatButton(
                                    //backgroundColor: Colors.blue,
                                    //color: Colors.cyan,
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text("Log out",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400))),
                                    onPressed: () {
                                      cookie = "";

                                      Navigator.of(context).pop();
                                    })
                              ],
                            )*/
                        ),
                      )

                      /*Container(
                          //height: 683.0,
                          height: screenHeight / 2.6,
                          width: screenWidth / 1.65,
                          child: ),
                      Container(
                          //height: 683.0,
                          height: screenHeight / 2.6,
                          width: screenWidth / 1.65,
                          child: SizedBox(
                              height: screenHeight / 10.6,
                              //width: 240,
                              child: )),*/
                    ]),
              ),
            ),
          ),
        ));
  }

  Widget dashboard(context) {
    this.points = 43;
    if (this.selectedTable == "index") {
      return AnimatedPositioned(
          duration: duration,
          top: 0,
          bottom: 0,
          left: isCollapsed ? 0 : 0.6 * screenWidth,
          right: isCollapsed ? 0 : -0.2 * screenWidth,
          child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                  animationDuration: duration,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  elevation: 8,
                  shadowColor: themeData.textColor,
                  color: themeData.canvasColor,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 48),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    //APPBAR
                                    Container(
                                        child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              child: Icon(Icons.menu,
                                                  color: Colors.lightBlue),
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                setState(() {
                                                  if (isCollapsed)
                                                    _controller.forward();
                                                  else
                                                    _controller.reverse();

                                                  isCollapsed = !isCollapsed;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Walkly",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color:
                                                          themeData.textColor))
                                            ]),

                                        //Icon(Icons.settings, color: Colors.white),
                                      ],
                                    )),
                                    Divider(
                                      color:
                                          Colors.lightBlue, //Color(0xFF333333),
                                      height: screenHeight / 370 * 4,
                                      thickness: screenHeight / 370,
                                      indent: 3,
                                      endIndent: 3,
                                    ),
                                    Container(
                                        child: Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Divider(
                                              color: Colors
                                                  .lightBlue, //Color(0xFF333333),
                                              height: screenHeight / 370 * 4,
                                              thickness: screenHeight / 370,
                                              indent: 3,
                                              endIndent: 3,
                                            ),
                                            Divider(
                                              height: screenHeight / 6.5,
                                              color: themeData.canvasColor,
                                            ),
                                            Text(
                                              "Welcome, Denis Zahariev",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Divider(
                                              height: screenHeight / 22.5,
                                              color: themeData.canvasColor,
                                            ),
                                            SizedBox(
                                                height: screenHeight / 2.5,
                                                child: CircleAvatar(
                                                    backgroundColor: themeData
                                                        .firstLayerBoxColor,
                                                    radius: 65 +
                                                        this
                                                                .points
                                                                .toString()
                                                                .length *
                                                            this
                                                                .points
                                                                .toString()
                                                                .length *
                                                            1.0 +
                                                        (this.points % 10) *
                                                            1.5,
                                                    child: CircleAvatar(
                                                        backgroundColor:
                                                            themeData
                                                                .canvasColor,
                                                        radius: 63 +
                                                            this
                                                                    .points
                                                                    .toString()
                                                                    .length *
                                                                this
                                                                    .points
                                                                    .toString()
                                                                    .length *
                                                                1.0 +
                                                            (this.points % 10) *
                                                                1.5,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              themeData
                                                                  .logoColor,
                                                          radius: 60 +
                                                              this
                                                                      .points
                                                                      .toString()
                                                                      .length *
                                                                  this
                                                                      .points
                                                                      .toString()
                                                                      .length *
                                                                  1.0 +
                                                              (this.points %
                                                                      10) *
                                                                  1.5,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  this
                                                                      .points
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          50,
                                                                      color: themeData
                                                                          .textColor),
                                                                ),
                                                                Text(' points',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        color: themeData
                                                                            .textColor))
                                                              ]),
                                                        )))),
                                          ],
                                        )),
                                      ],
                                    )),

                                    /*SizedBox(
                                        height: screenHeight / 2.3,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text("Home",
                                                softWrap: false,
                                                style: TextStyle(
                                                    fontSize: 74,
                                                    color:
                                                        themeData.textColor)),
                                          ],
                                        )),

                                    SizedBox(
                                        child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text("Welcome to Кактус Консулт ЕООД!",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: themeData.textColor)),
                                      ],
                                    )),*/
                                    /*Container(
                                        height: 200,
                                        width: 200,
                                        margin: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueAccent)),
                                        child: InAppWebView(
                                          initialUrl:
                                              'http://192.168.101.42/devdb/api/FileUploader/download?fileID=1141',
                                          initialHeaders: {'Cookie': cookie},
                                          onDownloadStart: (a, b) {
                                            print("Downloading..");
                                          },
                                        ))*/
                                  ])),

                          /*Builder(
                              builder: (context) => RaisedButton(
                                    child: Text("Test Snackbar"),
                                    onPressed: () {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              duration:
                                                  Duration(milliseconds: 4400),
                                              backgroundColor: Colors.red,
                                              content: Row(children: [
                                                Text(
                                                    "Username or password is incorrect.")
                                              ])));
                                    },
                                  )),*/
                        ],
                      )))));
      //}

    } else {
      return AnimatedPositioned(
          duration: duration,
          top: 0,
          bottom: 0,
          left: isCollapsed ? 0 : 0.6 * screenWidth,
          right: isCollapsed ? 0 : -0.2 * screenWidth,
          child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                  animationDuration: duration,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  elevation: 8,
                  color: themeData.canvasColor,
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 48),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //APPBAR
                                Container(
                                    child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    InkWell(
                                      child: Icon(Icons.menu,
                                          color: Colors.lightBlue),
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          if (isCollapsed)
                                            _controller.forward();
                                          else
                                            _controller.reverse();

                                          isCollapsed = !isCollapsed;
                                        });
                                      },
                                    ),
                                    Text(this.tableScreenName,
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: themeData.textColor)),

                                    //Icon(Icons.settings, color: Colors.white),
                                  ],
                                )),
                                Divider(
                                  color: Colors.lightBlue, //Color(0xFF333333),
                                  height: screenHeight / 370 * 4,
                                  thickness: screenHeight / 370,
                                  indent: 3,
                                  endIndent: 3,
                                ),
                                Divider(
                                  color: themeData
                                      .canvasColor, //Color(0xFF333333),
                                  height: screenHeight / 370 * 6,
                                  thickness: screenHeight / 370,
                                  indent: 3,
                                  endIndent: 3,
                                ),
                              ])),
                      datagridPageBuild(context)
                    ],
                  ))));
      //}

    }
  }
}

_getPositions() {
  final RenderBox renderBoxRed = _keyRed.currentContext.findRenderObject();
  final positionRed = renderBoxRed.localToGlobal(Offset.zero);
  return positionRed.distance;
}
