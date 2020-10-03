import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class apiCommunicator1 {
  apiCommunicator1(this.serverAddress);

  String serverAddress;
  String cookie;

  Future<Map> login(String username, String password) async {
    String url = serverAddress +
        'api/ApplicationUser/authenticate?username=' +
        username +
        "&password=" +
        password;

    try {
      final answer =
          await http.post(Uri.parse(url)).timeout(Duration(seconds: 6));
      this.cookie = answer.headers['set-cookie'];

      //userAccount = answer.body[3] + answer.body[4];
      Map jsonanswer = jsonDecode(answer.body);
      jsonanswer['set-cookie'] = answer.headers['set_cookie'];

      return jsonanswer;
    } catch (e) {
      this.cookie = 'Error';
      return {};
    }
  }

  Future<Map> register(String username, String password) async {
    String url = serverAddress +
        'api/ApplicationUser/authenticate?username=' +
        username +
        "&password=" +
        password;

    try {
      final answer =
          await http.post(Uri.parse(url)).timeout(Duration(seconds: 6));
      this.cookie = answer.headers['set-cookie'];

      //userAccount = answer.body[3] + answer.body[4];
      Map jsonanswer = jsonDecode(answer.body);
      jsonanswer['set-cookie'] = answer.headers['set_cookie'];

      return jsonanswer;
    } catch (e) {
      this.cookie = 'Error';
      return {};
    }
  }

  Future<List<dynamic>> getJsonMenu() async {
    String url = serverAddress + 'api/admmenu/getJsonMenu';
    final answer = await http.get(Uri.parse(url), headers: {'Cookie': cookie});
    List<dynamic> jsonAnswer = jsonDecode(answer.body);
    print("Navigation menu updated.");
    return jsonAnswer;
  }

  Future<Map<String, dynamic>> getTableInfo(String tableName) async {
    String addOnUrl = "";

    String url = serverAddress +
        'api/ADMERPBotTable/getAllbyTableName?TableName=' +
        tableName;
    final answer = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    print(jsonAnswer);
    return jsonAnswer;
  }

  Future<Map<String, dynamic>> getTableContent(
      String tableName, int page, int recordsPerLoad,
      {String filter, List fields}) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = serverAddress + 'api/$table/getAll';
    String filterPayload = "";

    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    if (filter != null && fields != null) {
      filterPayload = "[";
      for (int i = 0; i < fields.length; i++) {
        filterPayload +=
            '["' + fields[i]['NameField'] + '","contains","' + filter + '"]';
        if (i < fields.length - 1) {
          filterPayload += ',"or",';
        } else {
          filterPayload += ']';
        }
      }
      print(filterPayload);
      print(cookie);
    }

    request.bodyFields = {
      'skip': ((page - 1) * recordsPerLoad).toString(),
      'take': recordsPerLoad.toString(),
      'requireTotalCount': 'true',
      'sort': '[{"selector":"ServiceOrderID","desc":true}]',
      'filter': filterPayload
    };

    var answer = await http.Client().send(request);
    print(answer.reasonPhrase);
    var body = await answer.stream.bytesToString();
    Map<String, dynamic> jsonAnswer = jsonDecode(body);
    return jsonAnswer;
  }

  Future<Map<String, dynamic>> getTableProperties(int tableID) async {
    String url = serverAddress +
        'api/ADMERPBotTableField/getAllbyERPBotTableID?ErpBotTableID=' +
        tableID.toString();
    final answer = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    //print(tableID);
    return jsonAnswer;
  }

  Future<int> deleteItem(String tableName, String id) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = serverAddress + 'api/${table}/delete';
    var request = http.Request('DELETE', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    request.bodyFields = {
      'key': id,
    };
    var answer = await http.Client().send(request);

    if (answer.statusCode == 200) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<Map> addItem(String tableName, Map data) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = serverAddress + 'api/$table/add';
    String body = json.encode(data);
    final answer = await http.post(Uri.parse(url),
        headers: {"Cookie": this.cookie}, body: {'values': body});
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    print(answer.reasonPhrase);
    if (answer.statusCode == 200) {
      return jsonAnswer;
    } else {
      return null;
    }
  }

  Future<Map> findForeignTableID(String id) async {
    String url = serverAddress +
        'api/ADMERPBotTableField/getAll?skip=0&take=20&requireTotalCount=true&filter=%5B%5B%22NameField%22%2C%22%3D%22%2C%22' +
        id.toString().toLowerCase() +
        '%22%5D%2C%22and%22%2C%5B%22KeySpecification%22%2C%22%3D%22%2C%22PK%22%5D%5D';

    final answer = await http.get(Uri.parse(url), headers: {'Cookie': cookie});
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    var tableID;
    for (int i = 0; i < jsonAnswer['totalCount']; i++) {
      tableID = jsonAnswer['data'][i]['ERPBotTableID'];
      print(jsonAnswer['data'][i]['ERPBotTableID']);
    }
    var tableProperties = await getTableProperties(tableID);

    print(tableProperties);
    return jsonAnswer;
  }

  Future<Map<String, dynamic>> updateTable(
      String tableName, Map selectedItem) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = serverAddress + 'api/${table}/update';
    String body = json.encode(selectedItem);
    print(body);
    final answer = await http.put(Uri.parse(url),
        headers: {'Cookie': this.cookie},
        body: {'key': selectedItem['key'], 'values': body});
    Map<String, dynamic> jsonAnswer = jsonDecode(answer.body);
    print(answer.reasonPhrase);
    if (answer.statusCode == 200) {
      return jsonAnswer;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> filterTableByKeyWord(
      String tableName, List fields, String filter, int recordsPerLoad) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    String url = serverAddress + 'api/${table}/getAll';
    String filterPayload = "[";
    for (int i = 0; i < fields.length; i++) {
      filterPayload +=
          '["' + fields[i]['NameField'] + '","contains","' + filter + '"]';
      if (i < fields.length - 1) {
        filterPayload += ',"or",';
      } else {
        filterPayload += ']';
      }
    }
    print(filterPayload);
    print(cookie);
    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    request.bodyFields = {
      'skip': '0',
      'take': recordsPerLoad.toString(),
      'requireTotalCount': 'true',
      'sort': '[{"selector":"ServiceOrderID","desc":false}]',
      'filter': filterPayload
    };

    var answer = await http.Client().send(request);
    print(answer.reasonPhrase);
    var body = await answer.stream.bytesToString();
    Map<String, dynamic> jsonAnswer = jsonDecode(body);
    return jsonAnswer;
  }

  Future<int> uploadFile(String tableName, String id, File file) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    print("uploading file on table $table");
    String url = serverAddress +
        'api/FileUploader/Upload?keyId=' +
        id +
        "&tableName=" +
        table;

    var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();
    print(file.path);
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.headers['Cookie'] = cookie;
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(file.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.reasonPhrase);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    if (response.statusCode == 200) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<Map<String, dynamic>> filterTableByField(
      String tableName, String namefield, String filter) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    //String url =
    //'http://192.168.101.42/devdb/api/${table}/getAll?skip=0&take=20&filter=%5B%5B%22ServiceOrderID%22%2C%22%3D%22%2C1%5D%2C%22and%22%2C%5B%22VIN%22%2C%22contains%22%2C%2211%22%5D%5D&_=1597313680266';
    //final answer = await http.get(Uri.parse(url), headers: {'Cookie': cookie});
    String url = serverAddress + 'api/${table}/getAll';
    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    request.bodyFields = {
      'skip': '0',
      'take': '20',
      'requireTotalCount': 'true',
      'sort': '[{"selector":"ServiceOrderID","desc":false}]',
      'filter': '["' + namefield + '","contains","' + filter + '"]'
    };
    var answer = await http.Client().send(request);
    var body = await answer.stream.bytesToString();
    Map<String, dynamic> jsonAnswer = jsonDecode(body);
    return jsonAnswer;
  }

  Future<Map<String, dynamic>> getUploadedFiles(
      String tableName, String id) async {
    String table = tableName.replaceAll(new RegExp(r'_'), '');
    //String url =
    //'http://192.168.101.42/devdb/api/${table}/getAll?skip=0&take=20&filter=%5B%5B%22ServiceOrderID%22%2C%22%3D%22%2C1%5D%2C%22and%22%2C%5B%22VIN%22%2C%22contains%22%2C%2211%22%5D%5D&_=1597313680266';
    //final answer = await http.get(Uri.parse(url), headers: {'Cookie': cookie});
    String url = serverAddress + 'api/ADMUploadedFile/getAllByTableAndKeyID';
    var request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    request.bodyFields = {'tableName': table, 'keyId': id};

    var answer = await http.Client().send(request);
    print(answer.reasonPhrase);
    var body = await answer.stream.bytesToString();
    Map<String, dynamic> jsonAnswer = jsonDecode(body);
    //print(jsonAnswer);
    return jsonAnswer;
  }

  Future<int> deleteUploadedFile(String fileId) async {
    print(fileId);
    String url = serverAddress + 'api/ADMUploadedFile/delete';
    var request = http.Request('DELETE', Uri.parse(url))
      ..headers.addAll({
        'Cookie': cookie,
      });
    request.bodyFields = {
      'key': fileId,
    };
    var answer = await http.Client().send(request);
    print(answer.reasonPhrase);
    if (answer.statusCode == 200) {
      return 1;
    } else {
      return 0;
    }
  }

  /*Future<int> downloadFile(String id) async {
    Dio dio = new Dio();
    String url =
        'http://192.168.101.42/devdb/api/FileUploader/download?fileID=' + id;
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String fullPath = appDocDirectory.path + "/test.jpg'";
    print(fullPath);
    http.get(url).then((response) {
      new File(fullPath).writeAsBytes(response.bodyBytes);
    });
  }*/
  Future<int> downloadFile(String id, String path) async {
    //print(localPath);
    String url = serverAddress + 'api/FileUploader/download?fileID=' + id;

    FlutterDownloader.enqueue(
        url: url,
        fileName: "test.jpg",
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: path,
        showNotification: true,
        openFileFromNotification: true);
  }
}
