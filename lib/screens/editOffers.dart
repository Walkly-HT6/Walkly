import 'package:flutter/material.dart';
import 'package:Walkly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'betterThemeData.dart';

String selectedServerIp;

List<String> profileNameList = [];

class EditOffers extends StatefulWidget {
  EditOffers(this.themeData);
  BetterThemeData themeData;
  @override
  _EditOffersState createState() => new _EditOffersState(themeData);
}

class _EditOffersState extends State<EditOffers> {
  _EditOffersState(this.themeData);
  BetterThemeData themeData;
  final profileIPKey = TextEditingController();
  final profileNameKey = TextEditingController();

  final editprofileNameKey = TextEditingController();
  final editprofileIPKey = TextEditingController();

  String selectedServerName;
  String selectedServerIP;

  Map<int, dynamic> serverProfiles = {};
  List<Widget> savedProfiles = [];
  List<Widget> addMenu = [];
  final _formNameKey = GlobalKey<FormState>();
  final _formIPKey = GlobalKey<FormState>();
  bool isAddMenuOpened = true;
  Widget addPanel;
  double addPanelHeight;
  Widget profilesPanel;
  Widget body;
  String actionState;

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      value.getKeys().forEach((element) {
        //value.remove(element);
        print(value.getKeys());
      });
      //
      setState(() {
        this.getProfiles().then((value) {
          this.serverProfiles = value;
        });
        this.getProfilesNameList().then((value) {
          profileNameList = value;
        });
        getSelectedServer();
      });
    });
    prepare().then((value) {
      setState(() {
        body = value;
      });
    });
  }

  void clearKeys() {
    profileNameKey.text = "";
    profileIPKey.text = "";
    editprofileNameKey.text = "";
    editprofileIPKey.text = "";
  }

  void getSelectedServer() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    if (instance.containsKey('selectedServerName') &&
        instance.containsKey('selectedServerIP')) {
      setState(() {
        this.selectedServerName = instance.getString('selectedServerName');
        this.selectedServerIP = instance.getString('selectedServerIP');
      });
    } else {
      setSelectedServer(String profileName, String profileIP) {}
    }
  }

  Future<int> getProfileCount() async {
    var instance = await SharedPreferences.getInstance();
    if (instance.containsKey('totalCount')) {
      return instance.getInt('totalCount');
    } else {
      changeProfileCount(0);
      return 0;
    }
  }

  void changeProfileCount(int change) async {
    var instance = await SharedPreferences.getInstance();

    switch (change) {
      case 0:
        instance.setInt('totalCount', change);
        break;
      default:
        getProfileCount().then((value) {
          if (value + change >= 0) {
            instance.setInt('totalCount', value + change);
          }
        });

        break;
    }
  }

  void addProfile(String profileName, String profileIP) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    int totalCount = await this.getProfileCount();
    instance.setString('name' + (totalCount).toString(), profileName);
    instance.setString('ip' + (totalCount).toString(), profileIP);
    changeProfileCount(1);

    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.getProfiles().then((value) {
          this.serverProfiles = value;
        });
        this.getProfilesNameList().then((value) {
          profileNameList = value;
          this.selectedServerName = profileNameList[0];
        });
      });
      prepare().then((value) {
        body = value;
      });
    });
  }

  void deleteProfile(String profileName, String profileIP) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    int totalCount = await this.getProfileCount();
    for (int i = 0; i < totalCount; i++) {
      if (this.serverProfiles[i]['name'] == profileName &&
          this.serverProfiles[i]['ip'] == profileIP) {
        instance.remove('name' + i.toString());
        instance.remove('ip' + i.toString());
      }
    }
    refreshProfiles();
    changeProfileCount(-1);
    SharedPreferences.getInstance().then((value) {
      setState(() {
        this.getProfiles().then((value) {
          this.serverProfiles = value;
        });
        this.getProfilesNameList().then((value) {
          profileNameList = value;
          this.selectedServerName = profileNameList[0];
        });
      });
      prepare().then((value) {
        body = value;
      });
    });
  }

  void editProfile(int id, String profileName, String profileIP) async {
    setState(() {
      this.editprofileNameKey.text = '';
      this.editprofileIPKey.text = '';
    });
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setString('name' + id.toString(), profileName);
    instance.setString('ip' + id.toString(), profileIP);
  }

  Future<Map<int, dynamic>> getProfiles() async {
    var instance = await SharedPreferences.getInstance();
    int totalCount = instance.getInt('totalCount');
    Map<int, dynamic> myNames = {};
    if (totalCount != null) {
      for (int i = 0; i < totalCount; i++) {
        var myName = instance.getString('name' + i.toString());
        myNames[i] = {
          'name': instance.getString('name' + i.toString()),
          'ip': instance.getString('ip' + i.toString())
        };
      }
      return myNames;
    } else {
      return {
        0: {"None", "none"}
      };
    }
  }

  Future<List<String>> getProfilesNameList() async {
    var instance = await SharedPreferences.getInstance();
    int totalCount = instance.getInt('totalCount');
    List<String> myNames = [];
    //print("getProfilesNameList totalCount" + totalCount.toString());
    if (instance.containsKey('totalCount') && totalCount > 0) {
      for (int i = 0; i < totalCount; i++) {
        myNames.add(instance.getString('name' + i.toString()));
      }
      return myNames;
    } else {
      print("none");
      return ['None'];
    }
  }

  void refreshProfiles() async {
    SharedPreferences instance = await SharedPreferences.getInstance();

    int totalCount = await this.getProfileCount();
    int skipped = 0;
    for (int i = 0; i < totalCount; i++) {
      if (instance.getString('name' + i.toString()) == null) {
        skipped++;
      }
      instance.setString('name' + i.toString(),
          instance.getString('name' + (i + skipped).toString()));
      instance.setString('ip' + i.toString(),
          instance.getString('ip' + (i + skipped).toString()));
    }
    for (int i = totalCount - 1; i > totalCount - skipped - 1; i--) {
      instance.remove('name' + i.toString());
      instance.remove('ip' + i.toString());
    }
  }

  Widget createAddPanel(Map profiles) {
    Size size = MediaQuery.of(context).size;
    final platform = Theme.of(context).platform;
    var screenHeight = size.height;
    var screenWidth = size.width;

    if (actionState == 'add') {
      addPanelHeight = screenHeight / 3.78;
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: 5.5),
        child: Container(
            height: addPanelHeight,
            margin: EdgeInsets.all(10),
            decoration: new BoxDecoration(
              /*boxShadow: [
                BoxShadow(
                  color: themeData.secondaryLayerBoxColor.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],*/
              color: themeData.secondaryLayerBoxColor,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(children: [
                Text(
                  "Add new profile",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                )
              ]),
              Column(children: [
                Container(
                    width: screenWidth / 1.6,
                    child: Form(
                        key: _formNameKey,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          controller: profileNameKey,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.white),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            bool exists = false;
                            profiles.forEach((key, profile) {
                              print(value == profile['name']);
                              if (value == profile['name']) {
                                exists = true;
                              }
                            });
                            if (exists) {
                              return 'Name already exists!';
                            } else {
                              return null;
                            }
                          },
                        ))),
                Container(
                  width: screenWidth / 1.6,
                  child: Form(
                      key: _formIPKey,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        controller: profileIPKey,
                        decoration: const InputDecoration(
                          hintText: 'IP',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          bool exists = false;
                          profiles.forEach((key, profile) {
                            print(value == profile['ip']);
                            if (value == profile['ip']) {
                              exists = true;
                            }
                          });
                          if (exists) {
                            return 'IP already exists!';
                          } else {
                            return null;
                          }
                        },
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        if (_formNameKey.currentState.validate() &&
                            _formIPKey.currentState.validate()) {
                          setState(() {
                            addProfile(profileNameKey.text, profileIPKey.text);
                            actionState = "";
                            clearKeys();
                          });
                          build(context);
                          setState(() {
                            actionState = "";
                            clearKeys();
                          });

                          build(context);
                        }
                      },
                    ),
                    FlatButton(
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        setState(() {
                          actionState = "";
                          clearKeys();
                        });

                        build(context);
                      },
                    )
                  ],
                )
              ]),
            ])),
      );
    } else {
      addPanelHeight = screenHeight / 15;
      return GestureDetector(
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 5.5),
            child: Container(
              height: addPanelHeight,
              margin: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                /*boxShadow: [
                  BoxShadow(
                    color: themeData.secondaryLayerBoxColor.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],*/
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: themeData.secondaryLayerBoxColor,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 30,
                ),
                Text(
                  "Add new profile",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16),
                )
              ]),
            )),
        onTap: () {
          setState(() {
            clearKeys();
            actionState = 'add';
          });
          build(context);
        },
      );
    }
  }

  Widget createProfilePanel(Map profile, int id, Map profiles) {
    Size size = MediaQuery.of(context).size;
    final platform = Theme.of(context).platform;
    var screenHeight = size.height;
    var screenWidth = size.width;
    if (this.editprofileNameKey.text != profile['name'] ||
        this.editprofileIPKey.text != profile['ip']) {
      return Column(children: [
        Row(
          children: [
            GestureDetector(
                onTap: () {
                  setState(() {
                    this.editprofileNameKey.text = profile['name'];
                    this.editprofileIPKey.text = profile['ip'];
                    this.actionState = 'edit';
                  });
                  build(context);
                },
                child: Icon(
                  Icons.edit,
                  size: 25,
                  color: Colors.white,
                )),
            Spacer(),
            GestureDetector(
                child: Icon(Icons.delete, color: Colors.white),
                onTap: () {
                  return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Delete profile" + profile['name']),
                          content: Text(
                              "Are you sure you want to delete this profile?"),
                          actions: <Widget>[
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  deleteProfile(profile['name'], profile['ip']);
                                  SharedPreferences.getInstance().then((value) {
                                    setState(() {
                                      this.getProfiles().then((value) {
                                        this.serverProfiles = value;
                                      });
                                      this.getProfilesNameList().then((value) {
                                        profileNameList = value;
                                        this.selectedServerName =
                                            profileNameList[0];
                                      });
                                    });
                                  });
                                });
                                setState(() {
                                  build(context);
                                });

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
                }),
          ],
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Divider(
            height: 10,
            color: themeData.secondaryLayerBoxColor,
          ),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50.0),
              child: Text("Name: ",
                  style: TextStyle(color: Colors.white, fontSize: 16))),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50.0),
              child: Text(
                profile['name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              )),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50.0),
              child: Text("IP: ",
                  style: TextStyle(color: Colors.white, fontSize: 16))),
          ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 50.0),
              child: Text(profile['ip'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ])
      ]);
    } else {
      String backupName = editprofileNameKey.text;
      String backupIP = editprofileIPKey.text;
      return Container(
          child: Column(children: [
        Row(children: [
          Text(
            "Edit profile",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          )
        ]),
        Column(children: [
          Container(
              width: screenWidth / 1.6,
              child: Form(
                  key: _formNameKey,
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    controller: editprofileNameKey,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      bool exists = false;
                      profiles.forEach((key, profile) {
                        if (value == profile['name'] && key != id) {
                          exists = true;
                        }
                      });
                      if (exists) {
                        editprofileNameKey.text = backupName;
                        editprofileIPKey.text = backupIP;
                        return 'Name already exists!';
                      } else {
                        return null;
                      }
                    },
                  ))),
          Container(
            height: addPanelHeight,
            width: screenWidth / 1.6,
            child: Form(
                key: _formIPKey,
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: editprofileIPKey,
                  decoration: const InputDecoration(
                    hintText: 'IP',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    bool exists = false;
                    profiles.forEach((key, profile) {
                      print(value == profile['ip']);
                      if (value == profile['ip'] && key != id) {
                        exists = true;
                      }
                    });
                    if (exists) {
                      editprofileNameKey.text = backupName;
                      editprofileIPKey.text = backupIP;
                      return 'IP already exists!';
                    } else {
                      return null;
                    }
                  },
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Text('Save', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  print(editprofileNameKey);
                  if (_formNameKey.currentState.validate() &&
                      _formIPKey.currentState.validate()) {
                    setState(() {
                      editProfile(
                          id, editprofileNameKey.text, editprofileIPKey.text);
                      actionState = "";
                      clearKeys();
                    });
                    build(context);
                    setState(() {
                      actionState = "";
                      clearKeys();
                    });

                    build(context);
                  }
                },
              ),
              FlatButton(
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() {
                    actionState = "";
                    clearKeys();
                  });

                  build(context);
                },
              )
            ],
          )
        ]),
      ]));
    }
  }

  Future<Widget> prepare() async {
    Widget mybody;

    mybody = Container(
        margin: EdgeInsets.all(10),
        decoration: new BoxDecoration(
          color: themeData.firstLayerBoxColor,
          boxShadow: [
            BoxShadow(
              color: themeData.shadowColor.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [])));

    return mybody;
  }

  Widget build(BuildContext context) {
    prepare().then((value) {
      body = value;
    });
    return Scaffold(
        backgroundColor: themeData.canvasColor,
        appBar: AppBar(
          backgroundColor: themeData.appBarColor,
          automaticallyImplyLeading: false,
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, profileNameList);
                },
                child: Text(
                  "EXIT",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: body);
  }
}
