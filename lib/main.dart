import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:Walkly/screens/betterThemeData.dart';
import 'package:Walkly/screens/registration.dart';

import 'package:Walkly/screens/menuDashboard.dart';
import 'package:Walkly/screens/apiMethods.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starflut/starflut.dart';

import 'dart:io' show File;
import 'dart:convert' show json, jsonDecode;

List<Widget> navigationMenu = [];
List<Widget> userAccount = [];
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
const debug = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(debug: debug);
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

//themeData.colorScheme.primary

class MyApp extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<MyApp> with SingleTickerProviderStateMixin {
  final emailKey = TextEditingController();
  final passwordKey = TextEditingController();
  double screenHeight;
  double screenWidth;
  String selectedServer;
  BetterThemeData themeData;
  List<DropdownMenuItem<String>> profileDropdownList = [];
  List<Widget> savedProfiles = [];
  Widget themeIcon;
  Future<int> status;
  final emailValidationKey = GlobalKey<FormState>();
  final passwordValidationKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      value.getKeys().forEach((element) {
        //value.remove(element);
      });
    });
    SharedPreferences.getInstance().then((value) {});
    status = setTheme();
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

  @override
  Widget build(BuildContext context) {
    //callNNMove();
    Size size = MediaQuery.of(context).size;
    this.screenHeight = size.height;
    this.screenWidth = size.width;
    final platform = Theme.of(context).platform;
    return FutureBuilder(
      future: status,
      builder: (BuildContext context, AsyncSnapshot<int> status) {
        if (status.hasData) {
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: themeData.canvasColor,
              body: Stack(children: <Widget>[
                Container(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 48),
                    child: Center(
                        child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 300),
                            child: SizedBox(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                  FlatButton(
                                      shape: CircleBorder(),
                                      onPressed: () {
                                        changeTheme();
                                      },
                                      child: themeIcon),
                                  Text("Walkly",
                                      style: TextStyle(
                                          color: themeData.logoColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32)),
                                  Text(
                                    "Sign in to your account",
                                    style: TextStyle(
                                        color: themeData.secondaryTextColor),
                                  ),
                                  Container(
                                    width: screenWidth / 1.7,
                                    child: Column(children: [
                                      Form(
                                          key: emailValidationKey,
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: themeData.textColor),
                                            controller: emailKey,
                                            decoration: InputDecoration(
                                                hintText: 'Email',
                                                hintStyle: TextStyle(
                                                    color: themeData
                                                        .secondaryTextColor)),
                                            validator: (value) {
                                              if (value.length < 1) {
                                                return "Field required!";
                                              }
                                              return null;
                                            },
                                          )),
                                      Form(
                                        key: passwordValidationKey,
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: themeData.textColor),
                                          obscureText: true,
                                          controller: passwordKey,
                                          decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: TextStyle(
                                                  color: themeData
                                                      .secondaryTextColor)),
                                          validator: (value) {
                                            if (value.length < 1) {
                                              return "Field required!";
                                            }
                                            return null;
                                          },
                                        ),
                                      )
                                    ]),
                                  ),
                                  Divider(
                                    color: themeData.canvasColor,
                                    height: 20,
                                    thickness: 0,
                                    indent: null,
                                    endIndent: 0,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: screenWidth / 1.6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      //padding: EdgeInsets.only(right: 10),
                                      children: [
                                        ButtonTheme(
                                            minWidth: screenWidth / 3.4,
                                            child: RaisedButton(
                                                hoverColor: Color.fromRGBO(
                                                    2, 139, 201, 1),
                                                color: themeData.logoColor,
                                                child: Text(
                                                  'LOGIN',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () async {
                                                  var apiCommunicator =
                                                      new apiCommunicator1(
                                                          "192.168.1.9/walklyapp/");
                                                  apiCommunicator
                                                      .login(emailKey.text,
                                                          passwordKey.text)
                                                      .then(
                                                          (String value) async {
                                                    if (value.length == 20) {
                                                      dynamic userDetails =
                                                          await apiCommunicator
                                                              .getAccountDetails(
                                                                  emailKey
                                                                      .text);
                                                      while (
                                                          userDetails.length <
                                                              1) {
                                                        userDetails =
                                                            await apiCommunicator
                                                                .getAccountDetails(
                                                                    emailKey
                                                                        .text);
                                                      }
                                                      userDetails = jsonDecode(
                                                          userDetails);
                                                      String accountType;
                                                      if (userDetails[
                                                              "is_business"] ==
                                                          "true") {
                                                        accountType = 'dealer';
                                                      } else {
                                                        accountType = 'user';
                                                      }
                                                      await Navigator.of(context).push(MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              MenuDashboard(
                                                                  value,
                                                                  "192.168.1.9",
                                                                  userDetails[
                                                                          "first_name"] +
                                                                      " " +
                                                                      userDetails[
                                                                          "last_name"],
                                                                  context,
                                                                  platform,
                                                                  themeData,
                                                                  accountType,
                                                                  emailKey
                                                                      .text)));
                                                      print(value);
                                                    } else {
                                                      _scaffoldKey.currentState
                                                          .showSnackBar(
                                                              SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                            'Login failed.'),
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ));
                                                    }
                                                  });
                                                })),
                                        ButtonTheme(
                                            minWidth: screenWidth / 3.4,
                                            child: RaisedButton(
                                                hoverColor: Color.fromRGBO(
                                                    2, 139, 201, 1),
                                                color: themeData.logoColor,
                                                child: Text(
                                                  'REGISTER',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () async {
                                                  var answer = await Navigator
                                                          .of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Registration(
                                                                  themeData)));
                                                })),
                                      ],
                                    ),
                                  ),
                                  /*FlatButton(
                                    child: Text("makeOffer"),
                                    onPressed: () async {
                                      var apiCommunicator =
                                          new apiCommunicator1("alabala");
                                      String result =
                                          await apiCommunicator.makeOffer(
                                              "today", 2, 2, "free fries", 3);
                                      print(result);
                                    },
                                  ),*/
                                  /*FlatButton(
                                    child: Text("details"),
                                    onPressed: () async {
                                      var apiCommunicator =
                                          new apiCommunicator1("alabala");
                                      String result = await apiCommunicator
                                          .getAccountDetails("den@bat");
                                      print(result);
                                    },
                                  )*/
                                ])))))
              ]));
        } else {
          //print(setTheme());
          return Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        }
      },
    );
  }
}
