import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:Walkly/screens/betterThemeData.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sensors/sensors.dart';
import 'package:starflut/starflut.dart';

var apiCommunicator;
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class Walker extends StatefulWidget {
  Walker({this.themeData});
  BetterThemeData themeData;

  @override
  _WalkerState createState() => new _WalkerState(themeData: this.themeData);
}

class _WalkerState extends State<Walker> {
  _WalkerState({this.themeData});
  String serverAddress;
  List<Widget> body = [];

  BetterThemeData themeData;
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  String _status = '?';
  int apiStepsTotal = 0;
  int startingSteps = -1;
  int netSteps = 0;

  int apiSteps = 0;
  int timeInSecs = 0;
  //double avgUserAcc;
  List<List<double>> storeAccData = [];
  bool nn = true;
  StarServiceClass Service;
  int prevSec = 0;
  int prevStepsCount = 0;
  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    initPlatformState();
    if (nn) {
      startNN();
      nn = false;
    }
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      //_steps = event.steps.toString();
      apiStepsTotal = event.steps;
      if (startingSteps == -1) {
        startingSteps = apiStepsTotal;
      }
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      //_steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  List<double> avgUserAcc(List<List<double>> accData) {
    List<double> avgAccData = [0, 0, 0];
    for (int i = 0; i < accData.length; i++) {
      avgAccData[0] += accData[i][0];
      avgAccData[1] += accData[i][1];
      avgAccData[2] += accData[i][2];
    }
    for (int i = 0; i < avgAccData.length; i++) {
      avgAccData[i] /= accData.length;
    }
    //print(avgAccData);
    //var speed = pow(avgAccData[0], 2) + pow(avgAccData[1], 2);
    //speed = sqrt(speed);
    return avgAccData;
  }

  Future<void> callNNMove(int steps, int timeInSecs, double avgSpeed) async {
    StarObjectClass neuralNet =
        await Service.importRawContext("python", "NeuralNet", true, "");

    StarObjectClass neuralNet_inst =
        await neuralNet.newObject(["", "", 3, 3, 1]);
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
    print(await neuralNet_inst.call("train", [
      [
        [steps * 1.0, timeInSecs * 1.0, avgSpeed, 0]
      ],
      0.5,
      50
    ]));
    print(await neuralNet_inst.call("predict", [
      [steps * 1.0, timeInSecs * 1.0, avgSpeed]
    ]));
    //print(await neuralNet_inst.call("train", [dataset, 0.5, 2000, 2]));
    /*for (int i = 0; i < dataset.length; i++) {
      print(await neuralNet_inst.call("train", [
        [steps * 1.0, timeInSecs * 1.0, avgSpeed, 0]
      ]));
    }*/
    //  await SrvGroup.clearService();
    //await starcore.moduleExit();
  }

  void startNN() async {
    StarCoreFactory starcore = await Starflut.getFactory();
    Service = await starcore.initSimple("test", "123", 0, 0, []);
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
    }

    String resPath = await Starflut.getResourcePath();
    dynamic rr1 = await SrvGroup.initRaw("python36", Service);
    var Result = await SrvGroup.loadRawModule("python", "",
        resPath + "/flutter_assets/starfiles/" + "nnMove.py", false);
    print("loadRawModule = $Result");
    dynamic python = await Service.importRawContext("python", "", false, "");
    print("python = " + await python.getString());
  }

  @override
  Widget build(BuildContext context) {
//LISTEN FOR MOVING
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    if (prevSec != DateTime.now().second) {
      storeAccData.add(_userAccelerometerValues);
      //print(storeAccData.length);
      //print(DateTime.now().second);
      if (DateTime.now().second % 10 == 0) {
        storeAccData.remove(null);
        //callNNMove(apiSteps, 10, avgSpeed(storeAccData));
        print("NEW SET====================");
        print(apiSteps - prevStepsCount);
        print(10);
        print(avgUserAcc(storeAccData));
        setState(() {
          prevStepsCount = apiSteps;
        });
        storeAccData.clear();
      }
    }
    prevSec = DateTime.now().second;
    //COUNT STEPS
    apiSteps = apiStepsTotal - startingSteps;
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Walkly AI Pedometer'),
        actions: [
          FlatButton(
            child: Text("Exit"),
            onPressed: () {
              Navigator.of(context).pop(netSteps);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Steps taken API: ' + apiSteps.toString(),
              style: TextStyle(fontSize: 25),
            ),
            Text(
              'Pedestrian status:',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('UserAccelerometer: $userAccelerometer'),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 30)
                    : TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            FlatButton(
              child: Text("TEST NeuNET"),
              onPressed: () async {
                //callNNMove(apiSteps, 10, avgUserAcc);
              },
            ),
          ],
        ),
      ),
    ));
  }
}
