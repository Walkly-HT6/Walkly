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
import 'dart:convert' show json;

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
  final usernameKey = TextEditingController();
  final passwordKey = TextEditingController();
  double screenHeight;
  double screenWidth;
  String selectedServer;
  BetterThemeData themeData;
  List<DropdownMenuItem<String>> profileDropdownList = [];
  List<Widget> savedProfiles = [];
  Widget themeIcon;
  Future<int> status;
  final usernameValidationKey = GlobalKey<FormState>();
  final passwordValidationKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      value.getKeys().forEach((element) {
        //value.remove(element);
      });
    });
    status = setTheme();
  }

  Future<void> callNNMove() async {
    StarCoreFactory starcore = await Starflut.getFactory();
    StarServiceClass Service =
        await starcore.initSimple("test", "123", 0, 0, []);
    await starcore.regMsgCallBackP(
        (int serviceGroupID, int uMsg, Object wParam, Object lParam) async {
      print("$serviceGroupID  $uMsg   $wParam   $lParam");
      return null;
    });
    StarSrvGroupClass SrvGroup = await Service["_ServiceGroup"];

    /*---script python--*/
    bool isAndroid = await Starflut.isAndroid();
    if (isAndroid == true) {
      await Starflut.copyFileFromAssets(
          "nnMove.py", "flutter_assets/starfiles", "flutter_assets/starfiles");
      await Starflut.copyFileFromAssets("python3.6.zip",
          "flutter_assets/starfiles", null); //desRelatePath must be null
      await Starflut.copyFileFromAssets("zlib.cpython-36m.so", null, null);
      await Starflut.copyFileFromAssets(
          "unicodedata.cpython-36m.so", null, null);
      await Starflut.loadLibrary("libpython3.6m.so");
      await Starflut.loadLibrary("math");
      await Starflut.loadLibrary("random");
    }

    String resPath = await Starflut.getResourcePath();
    dynamic rr1 = await SrvGroup.initRaw("python36", Service);
    var Result = await SrvGroup.loadRawModule("python", "",
        resPath + "/flutter_assets/starfiles/" + "nnMove.py", false);
    print("loadRawModule = $Result");
    dynamic python = await Service.importRawContext("python", "", false, "");
    print("python = " + await python.getString());

    StarObjectClass neuralNet =
        await Service.importRawContext("python", "NeuralNet", true, "");

    List<dynamic> netBody = [
      [
        {
          "weights": [
            0.8715617014943798,
            0.8421103415589365,
            -0.0018121638755428187
          ],
          "output": 0.9999349919339816,
          "delta": 8.535201326506476e-08
        },
        {
          "weights": [
            -1.7021158124387235,
            2.0456873662482784,
            1.54441550647268
          ],
          "output": 0.012899222196390997,
          "delta": -6.035094596763093e-05
        },
        {
          "weights": [
            2.4083796600340097,
            -3.3868520208990414,
            -1.1882406605970994
          ],
          "output": 0.9955415354250226,
          "delta": 4.466138894645667e-05
        }
      ],
      [
        {
          "weights": [
            -1.1981122377374704,
            3.6363276391842994,
            -5.899586853901058,
            -1.2508576290618085
          ],
          "output": 0.02704793596050124,
          "delta": -0.000711802817541249
        },
        {
          "weights": [
            0.654878821715334,
            -3.0581597920621064,
            8.334296058561673,
            0.9623198707733448
          ],
          "output": 0.9731123702401314,
          "delta": 0.0007035063664451047
        }
      ]
    ];
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/nnStepsbody.txt');
    Map<String, dynamic> payload = {};
    payload["body"] = netBody;
    print('aaaaa');
    await file.writeAsString(payload
        .toString()
        .replaceAll('body', "\"body\"")
        .replaceAll('weights', "\"weights\"")
        .replaceAll('output', "\"output\"")
        .replaceAll('delta', "\"delta\""));

    String result = await file.readAsString();
    print('aaaaa');
    netBody = json.decode(result)["body"];
    print('aaaaa');
    //netBody = json
    //    .decode(await rootBundle.loadString("assets/neuralBody.json"))['body'];

    StarObjectClass neuralNet_inst =
        await neuralNet.newObject(["", "", netBody]);
    List<dynamic> dataset = [
      [2.7810836, 2.550537003, 0],
      [1.465489372, 2.362125076, 0],
      [3.396561688, 4.400293529, 0],
      [1.38807019, 1.850220317, 0],
      [3.06407232, 3.005305973, 0],
      [7.627531214, 2.759262235, 1],
      [5.332441248, 2.088626775, 1],
      [6.922596716, 1.77106367, 1],
      [8.675418651, -0.242068655, 1],
      [7.673756466, 3.508563011, 1]
    ];

    try {
      final directory = await getApplicationDocumentsDirectory();
      //netBody = json.decode(
      //  await new File(directory.path + '/neuralBody.json').readAsString());
      await new File(directory.path + '/neuralBody.json').writeAsString('test');
    } finally {
      print(await neuralNet_inst.call("train", [dataset, 0.5, 2000, 2]));
      for (int i = 0; i < dataset.length; i++) {
        print(await neuralNet_inst.call("predict", [dataset[i]]));
      }
    }

    //await SrvGroup.clearService();
    //await starcore.moduleExit();
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
    usernameKey.text = "admin";
    passwordKey.text = "dev";
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
                                          key: usernameValidationKey,
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: themeData.textColor),
                                            controller: usernameKey,
                                            decoration: InputDecoration(
                                                hintText: 'Login',
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
                                                  if (usernameValidationKey
                                                          .currentState
                                                          .validate() &&
                                                      passwordValidationKey
                                                          .currentState
                                                          .validate()) {
                                                    //print(serverAddress);
                                                    //var apiCommunicator =
                                                    //    new apiCommunicator1(
                                                    //        "INSERT URL HERE");
                                                    //apiCommunicator
                                                    //    .login(usernameKey.text,
                                                    //        passwordKey.text)
                                                    //    .then((Map value) async {
                                                    //if (apiCommunicator.cookie !=
                                                    //    null) {
                                                    //  if (apiCommunicator.cookie !=
                                                    //      'Error') {
                                                    //    String name =
                                                    //        value['FirstName'] +
                                                    //            ' ' +
                                                    //            value['LastName'];
                                                    //    var menu =
                                                    //        await apiCommunicator
                                                    //            .getJsonMenu();

                                                    //    print(apiCommunicator.cookie);
                                                    await Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                MenuDashboard(
                                                                    "cookie",
                                                                    "INSERT URL HERE",
                                                                    "Ivan Ivanov",
                                                                    context,
                                                                    platform,
                                                                    themeData)));
                                                  } else {
                                                    _scaffoldKey.currentState
                                                        .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      content: Text(
                                                          'Server host unreachable.'),
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ));
                                                  }
                                                  //dispose();

                                                  /*} else {
                                                print("login failed");

                                                _scaffoldKey.currentState
                                                    .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Username or password is incorrect.'),
                                                  duration:
                                                      Duration(seconds: 3),
                                                ));
                                              }*/
                                                  //});
                                                  usernameKey.text = "";
                                                  passwordKey.text = "";
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
                                  FlatButton(
                                    child: Text("TEST NeuNET"),
                                    onPressed: () async {
                                      callNNMove();
                                    },
                                  )
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
