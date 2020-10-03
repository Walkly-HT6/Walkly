import 'dart:convert';
import 'dart:io';
import 'package:Walkly/screens/apiMethods.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

var apiCommunicator;

class DatagridPage {
  DatagridPage(
      {this.context,
      this.tableName,
      this.tableData,
      this.tableProperties,
      this.cookie,
      this.serverAddress});
  String cookie;
  String serverAddress;
  BuildContext context;
  //TABLE STUFF
  String tableName;
  Map<String, dynamic> tableData, tableProperties;
  //DATAGRID
  List<DataRow> _rowList = [];
  List<DataColumn> _tableTemplate = [];

  List<Widget> _popupMenuContent = [];
  List<TextEditingController> _customControllers = [];
  Color buttonColors = Colors.lightBlue[100];
  Map selectedItem;

  Future<Map<String, dynamic>> updateTable(Map selectedItem) async {
    String table = this.tableName.replaceAll(new RegExp(r'_'), '');
    String url = 'http://192.168.101.42/devdb/api/$table/update';
    String body = json.encode(selectedItem);
    final answer = await http.put(Uri.parse(url),
        headers: {'Cookie': this.cookie},
        body: {'key': 'Ben10', 'values': body});
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    return jsonAnswer;
  }

  Future<int> addItem(String tableName, Map data) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = 'http://192.168.101.42/devdb/api/${table}/add';
    String body = json.encode(data);
    final answer = await http.post(Uri.parse(url),
        headers: {"Cookie": this.cookie}, body: {'values': body});

    print(answer.reasonPhrase);
    if (answer.statusCode == 200) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<Map<dynamic, dynamic>> createEditPopupWindow(
      BuildContext context, Map id) {
    tableName = this.tableName;
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      _customControllers.add(TextEditingController(
          text: id[this.tableProperties['data'][i]['NameField']].toString()));

      _popupMenuContent.add(Text(this.tableProperties['data'][i]['fCaption']));

      _popupMenuContent.add(TextField(
        controller: _customControllers[i],
      ));
      _popupMenuContent.add(Divider(
        color: Colors.white,
        height: 20,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ));
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Row"),
            content: Container(
                width: 1000,
                child: ListView(
                    scrollDirection: Axis.vertical,
                    children: _popupMenuContent)),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  var answerValues = new Map();
                  for (int i = 0;
                      i < this.tableProperties['data'].length;
                      i++) {
                    if (_customControllers[i].text !=
                        id[this.tableProperties['data'][i]['NameField']]) {
                      answerValues[this.tableProperties['data'][i]
                          ['NameField']] = _customControllers[i].text;
                    }
                    answerValues['RowVersion'] = id['RowVersion'];
                    print(answerValues);
                  }
                  updateTable(answerValues);
                  _popupMenuContent = [];
                  Navigator.of(context).pop(answerValues);
                  _customControllers = [];
                },
                child: Text("SAVE"),
              ),
              MaterialButton(
                onPressed: () {
                  _customControllers = [];
                  _popupMenuContent = [];
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL"),
              )
            ],
          );
        });
  }

  Future<Map<dynamic, dynamic>> createAddPopupWindow(BuildContext context) {
    tableName = this.tableName;
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      _customControllers.add(TextEditingController(text: ""));
      _popupMenuContent.add(Text(this.tableProperties['data'][i]['fCaption']));

      _popupMenuContent.add(TextField(
        controller: _customControllers[i],
      ));
      _popupMenuContent.add(Divider(
        color: Colors.white,
        height: 20,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ));
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Row"),
            content: Container(
                width: 1000,
                child: ListView(
                    scrollDirection: Axis.vertical,
                    children: _popupMenuContent)),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  var answerValues = new Map();
                  for (int i = 0;
                      i < this.tableProperties['data'].length;
                      i++) {
                    answerValues[this.tableProperties['data'][i]['NameField']] =
                        _customControllers[i].text;
                    //print(id[this.tableProperties['data'][i]['NameField']]);
                  }
                  _popupMenuContent = [];
                  Navigator.of(context).pop(answerValues);
                  _customControllers = [];
                },
                child: Text("ADD"),
              ),
              MaterialButton(
                onPressed: () {
                  _customControllers = [];
                  _popupMenuContent = [];
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL"),
              )
            ],
          );
        });
  }

  Future<Map<dynamic, dynamic>> createInfoPopupWindow(
      BuildContext context, Map id) {
    tableName = this.tableName;
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      _customControllers.add(TextEditingController(
          text: id[this.tableProperties['data'][i]['NameField']].toString()));

      _popupMenuContent.add(Text(this.tableProperties['data'][i]['fCaption']));

      _popupMenuContent.add(Text(_customControllers[i].text));
      _popupMenuContent.add(Divider(
        color: Colors.white,
        height: 20,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ));
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("View Row"),
            content: Container(
                width: 1000,
                child: ListView(
                    scrollDirection: Axis.vertical, children: _popupMenuContent
                    /*[
                  Text(
                    "Edit name",
                    textAlign: TextAlign.left,
                  ),
                  TextField(
                    controller: customController,
                  )
                ]*/
                    )),
            actions: <Widget>[
              MaterialButton(
                onPressed: () {
                  _customControllers = [];
                  _popupMenuContent = [];
                  Navigator.of(context).pop();
                },
                child: Text("CLOSE"),
              )
            ],
          );
        });
  }

  Future<Map<dynamic, dynamic>> createDeletePopupWindow(
      BuildContext context, Map id) {
    tableName = this.tableName;
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      _customControllers.add(TextEditingController(
          text: id[this.tableProperties['data'][i]['NameField']].toString()));

      _popupMenuContent.add(Text(this.tableProperties['data'][i]['fCaption']));

      _popupMenuContent.add(Text(_customControllers[i].text));
      _popupMenuContent.add(Divider(
        color: Colors.white,
        height: 20,
        thickness: 0,
        indent: null,
        endIndent: 0,
      ));
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Row"),
            content: Container(
                width: 1000,
                child: Text("Are you sure that you want to delete this row?")),
            actions: <Widget>[
              MaterialButton(
                onPressed: () async {
                  await apiCommunicator.deleteItem(
                      this.tableName,
                      selectedItem[this.tableProperties['data'][0]
                          ['NameField']]);
                  Navigator.of(context).pop();
                },
                child: Text("DELETE"),
              ),
              MaterialButton(
                onPressed: () {
                  _customControllers = [];
                  _popupMenuContent = [];
                  Navigator.of(context).pop();
                },
                child: Text("CANCEL"),
              )
            ],
          );
        });
  }

  void _addRow() {
    // Built in Flutter Method.
    _rowList = [];
    int rowCount;
    if (this.tableData['totalCount'] > 19) {
      rowCount = 19;
    } else {
      rowCount = this.tableData['totalCount'];
    }

    for (int i = 0; i < rowCount; i++) {
      //this.tableData['totalCount']
      List<DataCell> currRow = [];

      for (int k = 0; k < this.tableProperties['data'].length; k++) {
        bool showEdIcon = false;
        for (int k = 0; k < this.tableProperties['data'].length; k++) {
          if (this.tableData['data'][i] == this.selectedItem ? true : false) {
            showEdIcon = true;
          }
        }

        currRow.add(DataCell(
            Text(this
                .tableData['data'][i]
                    [this.tableProperties['data'][k]['NameField']]
                .toString()), onTap: () {
          this.buttonColors = Colors.blue;
          this.selectedItem = this.tableData['data'][i];
          print(this.selectedItem);
          build(context);

          /*createEditPopupWindow(context, this.tableData['data'][i])
                .then((value) {
              updateTable(value);
              //}
            });*/
        }, showEditIcon: showEdIcon));
      }
      _rowList.add(DataRow(cells: currRow));
      //alabala  22
    }
  }

  void buildTabletemplate() {
    _tableTemplate = [];
    tableName = this.tableName;
    _tableTemplate = [];
    for (int i = 0; i < this.tableProperties['data'].length; i++) {
      //print(this.tableProperties['data'][i]['fCaption']);
      _tableTemplate.add(
          DataColumn(label: Text(this.tableProperties['data'][i]['fCaption'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    apiCommunicator = new apiCommunicator1(this.serverAddress);
    Size size = MediaQuery.of(context).size;
    var screenHeight = size.height;
    var screenWidth = size.width;
    apiCommunicator.cookie = this.cookie;
    if (this.selectedItem != null) {
      this.buttonColors = Colors.blue;
    }
    _addRow();
    buildTabletemplate();

    //print(this.tableData);
    return Column(children: <Widget>[
      /*StickyHeadersTable(
          columnsLength: titleColumn.length,
          rowsLength: titleRow.length,
          columnsTitleBuilder: (i) => Text(titleColumn[i]),
          rowsTitleBuilder: (i) => Text(titleRow[i]),
          contentCellBuilder: (i, j) => Text(data[i][j]),
          legendCell: Text('Sticky Legend'),
        ),*/

      Flex(direction: Axis.horizontal, children: [
        Wrap(spacing: -(screenWidth / 18), children: [
          RawMaterialButton(
            onPressed: () {
              createAddPopupWindow(context).then((Map value) async {
                //Map<String, dynamic> data = value;
                addItem(tableName, value);
                //await apiCommunicator.addItem(tableName, data);
              });
            },
            elevation: 2.0,
            fillColor: Colors.blue,
            child: Icon(
              Icons.add,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          RawMaterialButton(
            onPressed: () {
              createEditPopupWindow(context, selectedItem);
            },
            elevation: 2.0,
            fillColor: buttonColors,
            child: Icon(
              Icons.edit,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          RawMaterialButton(
            onPressed: () async {
              createDeletePopupWindow(context, selectedItem);
            },
            elevation: 2.0,
            fillColor: buttonColors,
            child: Icon(
              Icons.delete,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          RawMaterialButton(
            onPressed: () {
              createInfoPopupWindow(context, selectedItem);
            },
            elevation: 2.0,
            fillColor: buttonColors,
            child: Icon(
              Icons.info_outline,
              size: 25.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          ),
          RawMaterialButton(
            onPressed: () async {
              final _picker = ImagePicker();
              /*PickedFile image =
                  await _picker.getImage(source: ImageSource.camera);
              File image =
                  (await _picker.getImage(source: ImageSource.gallery)) as File;*/

              List<File> files = await FilePicker.getMultiFile();

              files.forEach((file) async {
                await apiCommunicator.uploadFile(
                    this.tableName,
                    selectedItem[this.tableProperties['data'][0]['NameField']],
                    file);
              });
            },
            elevation: 2.0,
            fillColor: buttonColors,
            child: Icon(
              Icons.add_a_photo,
              size: 15.0,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(15.0),
            shape: CircleBorder(),
          ),
        ])
      ]),
      Divider(
        color: Color(0xFFD3D3D3), //Color(0xFF333333),
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
      SizedBox(
          height: MediaQuery.of(context).size.height / 1.22211,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(columns: _tableTemplate, rows: _rowList))))
    ]);
  }
}
