import 'package:Walkly/screens/apiMethods.dart';
import 'package:Walkly/screens/datatable.dart';
import 'package:flutter/material.dart';
import 'package:Walkly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'betterThemeData.dart';

final GlobalKey<ScaffoldState> _scaffoldKeyReg = new GlobalKey<ScaffoldState>();

class Registration extends StatefulWidget {
  Registration(this.themeData);
  BetterThemeData themeData;
  @override
  _RegistrationState createState() => new _RegistrationState(themeData);
}

class _RegistrationState extends State<Registration> {
  _RegistrationState(this.themeData);
  BetterThemeData themeData;
  double screenWidth, screenHeight;
  Widget body;
  String accountType = "User";
  //USER
  final userFirstNameValidationKey = GlobalKey<FormState>();
  final userLastNameValidationKey = GlobalKey<FormState>();
  final userEmailValidationKey = GlobalKey<FormState>();
  final userPasswordValidationKey = GlobalKey<FormState>();
  final userConfirmPasswordValidationKey = GlobalKey<FormState>();

  final userFirstNameKey = TextEditingController();
  final userLastNameKey = TextEditingController();
  final userEmailKey = TextEditingController();
  final userPasswordKey = TextEditingController();
  final userConfirmPasswordKey = TextEditingController();

  //DEALER
  final dealerCompanyNameValidationKey = GlobalKey<FormState>();
  final dealerBussinessHoursValidationKey = GlobalKey<FormState>();
  final dealerFirstNameValidationKey = GlobalKey<FormState>();
  final dealerLastNameValidationKey = GlobalKey<FormState>();
  final dealerPhoneNumberValidationKey = GlobalKey<FormState>();
  final dealerDescriptionValidationKey = GlobalKey<FormState>();
  final dealerEmailValidationKey = GlobalKey<FormState>();
  final dealerPasswordValidationKey = GlobalKey<FormState>();
  final dealerConfirmPasswordValidationKey = GlobalKey<FormState>();
  final dealerCityValidationKey = GlobalKey<FormState>();
  final dealerStreetNameValidationKey = GlobalKey<FormState>();
  final dealerPostCodeValidationKey = GlobalKey<FormState>();
  final dealerBuiltNumberValidationKey = GlobalKey<FormState>();

  final dealerCompanyNameKey = TextEditingController();
  final dealerBussinessHoursKey = TextEditingController();
  final dealerFirstNameKey = TextEditingController();
  final dealerLastNameKey = TextEditingController();
  final dealerPhoneNumberKey = TextEditingController();
  final dealerDescriptionKey = TextEditingController();
  final dealerEmailKey = TextEditingController();
  final dealerPasswordKey = TextEditingController();
  final dealerConfirmPasswordKey = TextEditingController();
  final dealerCityKey = TextEditingController();
  final dealerStreetNameKey = TextEditingController();
  final dealerPostCodeKey = TextEditingController();
  final dealerBuiltNumberKey = TextEditingController();
  ////TODO photos

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) {
      value.getKeys().forEach((element) {
        //value.remove(element);
        print(value.getKeys());
      });
      //
    });
  }

  void clearKeys() {}

  Widget userRegistration() {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    print("aaaaa");
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
              key: userFirstNameValidationKey,
              child: TextFormField(
                style: TextStyle(color: themeData.textColor),
                controller: userFirstNameKey,
                decoration: InputDecoration(
                    hintText: 'First name',
                    hintStyle: TextStyle(color: themeData.textColor)),
                validator: (value) {
                  if (value.length < 1) {
                    return "Field required!";
                  }
                  return null;
                },
              )),
          Form(
              key: userLastNameValidationKey,
              child: TextFormField(
                style: TextStyle(color: themeData.textColor),
                controller: userLastNameKey,
                decoration: InputDecoration(
                    hintText: 'Last name',
                    hintStyle: TextStyle(color: themeData.textColor)),
                validator: (value) {
                  if (value.length < 1) {
                    return "Field required!";
                  }
                  return null;
                },
              )),
          Form(
              key: userEmailValidationKey,
              child: TextFormField(
                style: TextStyle(color: themeData.textColor),
                controller: userEmailKey,
                decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: themeData.textColor)),
                validator: (value) {
                  if (!value.contains('@')) {
                    return "Field required or wrong!";
                  }
                  return null;
                },
              )),
          Form(
              key: userPasswordValidationKey,
              child: TextFormField(
                style: TextStyle(color: themeData.textColor),
                controller: userPasswordKey,
                decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: themeData.textColor)),
                validator: (value) {
                  if (value.length < 1) {
                    return "Field required!";
                  }
                  return null;
                },
              )),
          Form(
              key: userConfirmPasswordValidationKey,
              child: TextFormField(
                style: TextStyle(color: themeData.textColor),
                controller: userConfirmPasswordKey,
                decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: TextStyle(color: themeData.textColor)),
                validator: (value) {
                  if (value.length < 1) {
                    return "Field required!";
                  }
                  return null;
                },
              )),
          Divider(height: 30, color: themeData.firstLayerBoxColor),
          ButtonTheme(
              minWidth: screenWidth / 3.4,
              child: RaisedButton(
                  hoverColor: Color.fromRGBO(2, 139, 201, 1),
                  color: themeData.canvasColor,
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                        color: themeData.firstLayerBoxColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (userFirstNameValidationKey.currentState.validate() &&
                        userPasswordValidationKey.currentState.validate() &&
                        userPasswordKey.text == userConfirmPasswordKey.text) {
                      var apiCommunicator = new apiCommunicator1("alabala");
                      String result = await apiCommunicator.registerUser(
                        userFirstNameKey.text,
                        userLastNameKey.text,
                        userEmailKey.text,
                        userPasswordKey.text,
                      );
                      if (result == "1") {
                        _scaffoldKeyReg.currentState.showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Registration successful.'),
                          duration: Duration(seconds: 3),
                        ));
                      } else {
                        _scaffoldKeyReg.currentState.showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Server host unreachable.'),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    }
                  }))
        ]);
  }

  Widget dealerRegistration() {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return SizedBox(
        height: screenHeight / 2,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  height: screenHeight / 2.6,
                  child: ListView(children: [
                    Form(
                        key: dealerCompanyNameValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerCompanyNameKey,
                          decoration: InputDecoration(
                              hintText: 'Company name',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: null,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          decoration: InputDecoration(
                              hintText: 'Category ID',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerBussinessHoursValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerBussinessHoursKey,
                          decoration: InputDecoration(
                              hintText: 'Bussiness Hours',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerFirstNameValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerFirstNameKey,
                          decoration: InputDecoration(
                              hintText: 'First Name',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerLastNameValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerLastNameKey,
                          decoration: InputDecoration(
                              hintText: 'Last Name',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerPhoneNumberValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerPhoneNumberKey,
                          decoration: InputDecoration(
                              hintText: 'Phone Number',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerDescriptionValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerDescriptionKey,
                          decoration: InputDecoration(
                              hintText: 'Describtion',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerEmailValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerEmailKey,
                          decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerPasswordValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerPasswordKey,
                          decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerConfirmPasswordValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerConfirmPasswordKey,
                          decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerCityValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerCityKey,
                          decoration: InputDecoration(
                              hintText: 'City',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerStreetNameValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerStreetNameKey,
                          decoration: InputDecoration(
                              hintText: 'Street',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerPostCodeValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerPostCodeKey,
                          decoration: InputDecoration(
                              hintText: 'Postal Code',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                    Form(
                        key: dealerBuiltNumberValidationKey,
                        child: TextFormField(
                          style: TextStyle(color: themeData.textColor),
                          controller: dealerBuiltNumberKey,
                          decoration: InputDecoration(
                              hintText: 'Built Number',
                              hintStyle: TextStyle(color: themeData.textColor)),
                          validator: (value) {
                            if (value.length < 1) {
                              return "Field required!";
                            }
                            return null;
                          },
                        )),
                  ])),
              Divider(height: 30, color: themeData.firstLayerBoxColor),
              ButtonTheme(
                  minWidth: screenWidth / 3.4,
                  child: RaisedButton(
                      hoverColor: Color.fromRGBO(2, 139, 201, 1),
                      color: themeData.canvasColor,
                      child: Text(
                        'REGISTER',
                        style: TextStyle(
                            color: themeData.firstLayerBoxColor,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (dealerFirstNameValidationKey.currentState
                                .validate() &&
                            dealerPasswordValidationKey.currentState
                                .validate() &&
                            dealerPasswordKey.text ==
                                dealerConfirmPasswordKey.text) {
                          var apiCommunicator = new apiCommunicator1("alabala");
                          String result = await apiCommunicator.registerDealer(
                            dealerCompanyNameKey.text,
                            2,
                            dealerBussinessHoursKey.text,
                            dealerFirstNameKey.text,
                            dealerLastNameKey.text,
                            dealerPhoneNumberKey.text,
                            dealerDescriptionKey.text,
                            dealerEmailKey.text,
                            dealerPasswordKey.text,
                            dealerCityKey.text,
                            dealerStreetNameKey.text,
                            dealerPostCodeKey.text,
                            dealerBuiltNumberKey.text,
                          );
                          if (result == "1") {
                            _scaffoldKeyReg.currentState.showSnackBar(SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Registration successful.'),
                              duration: Duration(seconds: 3),
                            ));
                          } else {
                            _scaffoldKeyReg.currentState.showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Server host unreachable.'),
                              duration: Duration(seconds: 3),
                            ));
                          }
                        }
                      }))
            ]));
  }

  Widget prepare() {
    Widget mybody;
    Widget registrationType;
    switch (this.accountType) {
      case "User":
        registrationType = userRegistration();
        break;
      case "Dealer":
        registrationType = dealerRegistration();
        break;
    }

    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    mybody = SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(children: [
          Container(
              margin: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                color: themeData.canvasColor,
              ),
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      child: Text(
                        "User",
                        style:
                            TextStyle(color: themeData.textColor, fontSize: 23),
                      ),
                      onPressed: () {
                        setState(() {
                          this.accountType = "User";
                        });
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Dealer",
                        style:
                            TextStyle(color: themeData.textColor, fontSize: 23),
                      ),
                      onPressed: () {
                        setState(() {
                          this.accountType = "Dealer";
                        });
                      },
                    ),
                  ])),
          Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
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
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              //padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: registrationType,
              )),
        ]));

    return mybody;
  }

  Widget build(BuildContext context) {
    print("aaaaa");
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
        key: _scaffoldKeyReg,
        backgroundColor: themeData.canvasColor,
        appBar: AppBar(
          backgroundColor: themeData.appBarColor,
          automaticallyImplyLeading: false,
          title: Text(
            "Registration",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "EXIT",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: prepare());
  }
}
