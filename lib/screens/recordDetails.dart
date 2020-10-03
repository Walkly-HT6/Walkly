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
      {this.serverAddress,
      this.cookie,
      this.selectedItem,
      this.tableData,
      this.tableProperties,
      this.selectedTable,
      this.platform,
      this.themeData});
  String serverAddress;
  String cookie;
  Map selectedItem;
  Map<String, dynamic> tableData, tableProperties;
  String selectedTable = "index";
  final platform;
  BetterThemeData themeData;

  @override
  _RecordDetailsState createState() => new _RecordDetailsState(
      serverAddress: this.serverAddress,
      cookie: this.cookie,
      selectedItem: this.selectedItem,
      tableData: this.tableData,
      tableProperties: this.tableProperties,
      selectedTable: this.selectedTable,
      platform: this.platform,
      themeData: this.themeData);
}

class _RecordDetailsState extends State<RecordDetails> {
  _RecordDetailsState(
      {this.serverAddress,
      this.cookie,
      this.selectedItem,
      this.tableData,
      this.tableProperties,
      this.selectedTable,
      this.platform,
      this.themeData});
  String serverAddress;
  String cookie;
  Map selectedItem;
  Map<String, dynamic> tableData, tableProperties;
  String selectedTable = "index";
  String _localPath;
  ReceivePort _port = ReceivePort();
  final platform;
  List<_TaskInfo> _tasks;
  List<Widget> body = [];
  BetterThemeData themeData;
  List<_ItemHolder> _items;

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();
    apiCommunicator = apiCommunicator1(this.serverAddress);
    apiCommunicator.cookie = cookie;
    FlutterDownloader.registerCallback(downloadCallback);

    _prepare().then((value) {
      prepare().then((value) {
        setState(() {
          body = value;
        });
      });
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      final task = _tasks?.firstWhere((task) => task.taskId == id);
      if (task != null) {
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
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

    Map files = await apiCommunicator.getUploadedFiles(this.selectedTable,
        selectedItem[this.tableProperties['data'][0]['NameField']].toString());
    print(files);

    List<Widget> recordDetails = [];
    //CREATE DETAILS
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      recordDetails.add(Text(
        this.tableProperties['data'][i]['fCaption'],
        style: TextStyle(fontSize: 16, color: themeData.textColor),
      ));

      recordDetails.add(Text(
        selectedItem[this.tableProperties['data'][i]['NameField']].toString(),
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeData.textColor),
      ));
      recordDetails.add(Divider(
        color: themeData.firstLayerBoxColor,
        height: 10,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ));
    }
    recordDetails.add(Text(
      "Прикачени файлове",
      style: TextStyle(fontSize: 16, color: themeData.textColor),
    ));
    recordDetails.add(Divider(
      color: themeData.secondaryLayerBoxColor,
      height: 2,
      thickness: 2,
      indent: 10,
      endIndent: 10,
    ));
    List<Widget> currContainer = [];
    if (files['data'].isNotEmpty) {
      currContainer = [];

      for (int i = 0; i < files['data'].length; i++) {
        List<Widget> currRow = [];

        currRow.add(Row(children: [
          GestureDetector(
              child: Icon(Icons.delete, color: themeData.textColor),
              onTap: () async {
                prepare().then((value) {
                  setState(() {
                    body = value;
                  });
                  build(context);
                });
                var waiter = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Delete uploaded file"),
                        content: Text("Are you sure you want to delete " +
                            files['data'][i]['FileName'] +
                            "?"),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () async {
                              print(files['data'][i]['UploadedFileID']
                                  .toString());
                              apiCommunicator.deleteUploadedFile(files['data']
                                      [i]['UploadedFileID']
                                  .toString());
                              body = await prepare();
                              build(context);

                              Navigator.of(context).pop();
                            },
                            child: Text("CONFIRM"),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("CANCEL"),
                          )
                        ],
                      );
                    });
                prepare().then((value) {
                  setState(() {
                    body = value;
                  });
                  build(context);
                });
              }),
          Spacer(),
          GestureDetector(
            child: Icon(Icons.file_download, color: themeData.textColor),
            onTap: () {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Download uploaded file"),
                      content: Text("Are you sure you want to download " +
                          files['data'][i]['OriginalName'] +
                          "?"),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () async {
                            PermissionHandler()
                                .requestPermissions([PermissionGroup.storage]);
                            String path = await ExtStorage
                                .getExternalStoragePublicDirectory(
                                    ExtStorage.DIRECTORY_DOWNLOADS);

                            _ItemHolder data;

                            var taskId = await FlutterDownloader.enqueue(
                              url: this.serverAddress +
                                  'api/FileUploader/download?fileID=' +
                                  files['data'][i]['UploadedFileID'].toString(),
                              savedDir: path,
                              headers: {'Cookie': cookie},
                              fileName:
                                  files['data'][i]['OriginalName'].toString(),
                              showNotification:
                                  true, // show download progress in status bar (for Android)
                              openFileFromNotification:
                                  true, // click on notification to open downloaded file (for Android)
                            );

                            //print("taskId");
                            //print(taskId);
                            Navigator.of(context).pop();
                          },
                          child: Text("CONFIRM"),
                        ),
                        MaterialButton(
                          onPressed: () {
                            // flutterWebViewPlugin.dispose();
                            Navigator.of(context).pop();
                          },
                          child: Text("CANCEL"),
                        )
                      ],
                    );
                  });
            },
          )
        ]));

        currRow.add(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Name",
            style: TextStyle(fontSize: 16, color: themeData.textColor),
          ),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50.0),
              child: Text(files['data'][i]['OriginalName'].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: themeData.textColor))),
          Text(
            "Дата качване",
            style: TextStyle(fontSize: 16, color: themeData.textColor),
          ),
          Text(files['data'][i]['SCDateTime'].toString().substring(0, 10),
              //showEditIcon: isSelected,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: themeData.textColor)),
        ]));

        currContainer.add(Container(
            margin: EdgeInsets.all(10),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: themeData.firstLayerBoxColor,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: currRow,
            )));
      }
    } else {
      currContainer.add(Center(
          child: Text("Няма намерени прикачени файлове",
              style: TextStyle(color: themeData.textColor))));
    }
    recordDetails.add(Container(
        color: themeData.firstLayerBoxColor,
        height: MediaQuery.of(context).size.height / 1.84,
        child: ListView(
          primary: false,
          //childAspectRatio: 2.5,
          padding: const EdgeInsets.all(10),
          //crossAxisSpacing: 10,
          //mainAxisSpacing: 10,
          //crossAxisCount: 1,
          children: _items
              .map((item) => item.task == null
                  ? _buildListSection(item.name)
                  : Container(
                      margin: EdgeInsets.all(10),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: themeData.secondaryLayerBoxColor,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DownloadItem(
                              data: item,
                              onItemClick: (task) {
                                _openDownloadedFile(task).then((success) {
                                  if (!success) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content:
                                            Text('Cannot open this file')));
                                  }
                                });
                              },
                              onAtionClick: (task) {
                                if (task.status ==
                                    DownloadTaskStatus.undefined) {
                                  _requestDownload(task);
                                } else if (task.status ==
                                    DownloadTaskStatus.running) {
                                  _pauseDownload(task);
                                } else if (task.status ==
                                    DownloadTaskStatus.paused) {
                                  _resumeDownload(task);
                                } else if (task.status ==
                                    DownloadTaskStatus.complete) {
                                  _delete(task);
                                } else if (task.status ==
                                    DownloadTaskStatus.failed) {
                                  _retryDownload(task);
                                }
                              },
                              themeData: themeData,
                            )
                          ]),
                    ))
              .toList(),
        )));

    mybody.add(Container(
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
        actions: [
          FlatButton(
            onPressed: () async {
              //final _picker = ImagePicker();
              /*PickedFile image =
                  await _picker.getImage(source: ImageSource.gallery);
                  PickedFile image =
                      await _picker.getImage(source: ImageSource.gallery);*/

              List<File> files = await FilePicker.getMultiFile();

              files.forEach((file) async {
                var answer = await apiCommunicator.uploadFile(
                    this.selectedTable,
                    selectedItem[this.tableProperties['data'][0]['NameField']]
                        .toString(),
                    file);
                if (answer == 1) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('File Uploaded Successfully'),
                    duration: Duration(seconds: 3),
                  ));
                }
                prepare().then((value) {
                  setState(() {
                    body = value;
                  });
                  build(context);
                });
              });
            },
            child: Icon(
              Icons.add_a_photo,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(15.0),
            shape: CircleBorder(),
          ),
        ],
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

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                  onPressed: () {
                    _checkPermission().then((hasGranted) {
                      setState(() {});
                    });
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  void _requestDownload(_TaskInfo task) async {
    PermissionHandler().requestPermissions([PermissionGroup.storage]);
    String path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {'Cookie': cookie},
        savedDir: path,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    return true;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];
    Map files = await apiCommunicator.getUploadedFiles(this.selectedTable,
        selectedItem[this.tableProperties['data'][0]['NameField']].toString());

    for (int i = count; i < files['data'].length; i++) {
      _tasks.add(_TaskInfo(
          name: files['data'][i]['OriginalName'],
          link: this.serverAddress +
              'api/FileUploader/download?fileID=' +
              files['data'][i]['UploadedFileID'].toString()));
    }
    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(
          name: _tasks[i].name,
          dateUploaded:
              files['data'][i]['SCDateTime'].toString().substring(0, 10),
          task: _tasks[i]));
      count++;
    }
    tasks?.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder data;
  final Function(_TaskInfo) onItemClick;
  final Function(_TaskInfo) onAtionClick;
  BetterThemeData themeData;
  DownloadItem(
      {this.data, this.onItemClick, this.onAtionClick, this.themeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(
                        'Име:',
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: themeData.textColor),
                      ),
                      Text(
                        data.name,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor),
                      ),
                      Text(
                        'Дата на качване:',
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: themeData.textColor),
                      ),
                      Text(
                        data.dateUploaded,
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeData.textColor),
                      ),
                      Divider(
                        color: themeData.secondaryLayerBoxColor,
                        height: 10,
                      ),
                    ])),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildActionForTask(data.task),
                ),
              ],
            ),
          ),
          data.task.status == DownloadTaskStatus.running ||
                  data.task.status == DownloadTaskStatus.paused
              ? Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: data.task.progress / 100,
                        )
                      ]),
                )
              : Container()
        ].where((child) => child != null).toList(),
      ),
    );
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick(task);
        },
        child: Icon(Icons.file_download),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          onAtionClick(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FlatButton(
            color: Colors.white,
            onPressed: data.task.status == DownloadTaskStatus.complete
                ? () {
                    onItemClick(data.task);
                  }
                : null,
            child: Text(
              'Отвори',
              style: TextStyle(color: Colors.green),
            ),
          ),
          RawMaterialButton(
            onPressed: () {
              onAtionClick(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              width: 85,
              child: Text('Неуспешно сваляне',
                  style: TextStyle(color: Colors.red))),
          RawMaterialButton(
            onPressed: () {
              onAtionClick(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final String dateUploaded;
  final _TaskInfo task;

  _ItemHolder({this.name, this.dateUploaded, this.task});
}
