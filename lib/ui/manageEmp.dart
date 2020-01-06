import 'dart:async';
import 'dart:io';
import 'dart:math';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:the_gorgeous_login/style/CardItemModel.dart';
import 'package:the_gorgeous_login/sqllite/database_helper.dart';
import 'package:the_gorgeous_login/sqllite/model/fetchdata.dart';
import 'listtaikin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math show sin, pi;

class manageEmp extends StatefulWidget {
  @override
  State createState() => manageEmpState();
}

class Data {
  String ymdworkData;
  String enterwork;
  String outwork;
  Data({this.ymdworkData, this.enterwork, this.outwork});
}

class manageEmpState extends State<manageEmp> with TickerProviderStateMixin {
  var db = new DatabaseHelper();
  final Firestore _firestore = Firestore.instance;
  String _connectionStatus = 'Unknown';
  String idwifi = '';
  String imgdirenter = 'assets/img/enter.gif';
  String imgdirout = 'assets/img/out.gif';
  int id;
  var enterbutton = false;
  var outbutton = false;
  var clickicondeleteTask = false;
  var datetimenow;
  var nowhourenter = '';
  var nowminuenter = '';
  var nowhourout = '';
  var nowminuout = '';
  var nowWorkenter = '';
  var nowWorkout = '';
  String nowyear = '';
  String nowmonth = '';
  String nowday = '';
  String ymdWork = '';
  String stringalldatetimeSavedEnter = '';
  String stringalldatetimeNowEnter = '';
  String stringalldatetimeSavedOut = '';
  String stringalldatetimeNowOut = '';
  ScrollController scrollController;
  TextEditingController _textFieldSubject = new TextEditingController();
  TextEditingController _textFieldAssignee = new TextEditingController();
  TextEditingController _textFieldDescrip = new TextEditingController();
  var listtextField = [];

  var cardsList = [
    // CardItemModel("Task 1 ", Icons.account_circle, 9, 0.83),
    // CardItemModel("Task 2", Icons.work, 12, 0.24),
    // CardItemModel("Task 3", Icons.home, 7, 0.32)
  ];
  var appColors = [];
  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;
  var cardIndex = 0;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // model.createDB();
    scrollController = new ScrollController();
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      return;
    }

    _updateConnectionStatus(result);
  }

  Future<void> createtask() async {
    await _firestore.collection('stack').add({
      'subject': _textFieldSubject.text,
      'assignee': _textFieldAssignee.text,
      'descrip': _textFieldDescrip.text,
      'timecreate': FieldValue.serverTimestamp()
    });
    // TextFieldList textlist = new TextFieldList();
    // textlist.textFieldSubject = _textFieldSubject.text;
    // textlist.textFieldAssignee = _textFieldAssignee.text;
    // textlist.textFieldDescrip = _textFieldDescrip.text;
    // listtextField.add(textlist);
    // appColors.add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    // cardsList
    //     .add(CardItemModel(textlist.textFieldSubject, Icons.work, 9, 0.83));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      appColors
          .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    });
    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: currentColor,
      appBar: AppBar(
        title: const Text('勤怠'),
        backgroundColor: currentColor,
        actions: <Widget>[
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red)),
            color: Colors.yellowAccent,
            child: Text('勤怠一覧'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => listtaikin()));
            },
          )
        ],
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height >= 775.0
              ? MediaQuery.of(context).size.height
              : 775.0,
          child: _goingtoWork(context)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showdialogTask();
        },
        child: Icon(Icons.add),
        backgroundColor: currentColor,
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
          idwifi = wifiIP;
        });

        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
          idwifi = result.toString();
        });
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  Widget showimg(imgdir) {
    return Container(
      height: 350.0,
      width: 350.0,
      child: Image.asset(imgdir),
    );
  }

  Widget _workingcheck(sldata) {
    if (sldata != null) {
      var todaydatetime = nowyear + nowmonth + nowday;
      for (var data in sldata) {
        if (data.ymdWork == todaydatetime) {
          id = data.id;
          enterbutton = data.enterbutton;
          outbutton = data.outbutton;
          imgdirout = data.imgdirout;
          nowWorkenter = data.nowWorkenter;
          nowWorkout = data.nowWorkout;
        }
      }
    }
  }

  Future<void> _dialogCall(BuildContext context, img) {
    return showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            title: Image.asset(img),
          );
        });
  }

  Widget _goingtoWork(BuildContext context) {
    datetimenow = new DateTime.now();
    nowyear = datetimenow.year.toString();
    nowmonth = (datetimenow.month < 10
        ? '0' + datetimenow.month.toString()
        : datetimenow.month.toString());
    nowday = (datetimenow.day < 10
        ? '0' + datetimenow.day.toString()
        : datetimenow.day.toString());

    ymdWork = nowyear + nowmonth + nowday;
    // _getsharedPreEnterbutton();
    // _getsharedPreOutbutton();
    // scenes wifi ip android : 192.168.8.82
    // scenes wifi ip ios : 192.168.8.113
    // home my wifi ip : 172.20.10.11
    // print('ip wifi day ne ' + idwifi.toString());
    if (idwifi != 'ConnectivityResult.none') {
      // print('wifi : on');
      db.getManager().then((results) {
        print(results);
        for (var result in results) {
          if (ymdWork == result.ymdWork) {
            _workingcheck(results);
          }
        }
      });
      return Container(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
              // mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 60.0,
                    child: Card(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 10.0),
                              child: timeToWork(nowWorkenter, nowWorkout),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 120.0,
                              padding: EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    width: 114,
                                    height: 48,
                                    child: RaisedButton(
                                      color: Colors.greenAccent,
                                      shape: StadiumBorder(),
                                      child: const Text('出勤'),
                                      onPressed: enterbutton
                                          ? null
                                          : () async {
                                              int score = await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 1000),
                                                  () => 42);
                                              setState(() {
                                                datetimenow =
                                                    new DateTime.now();
                                                enterbutton = !enterbutton;

                                                nowhourenter = (datetimenow
                                                                .hour <
                                                            10
                                                        ? '0' +
                                                            datetimenow.hour
                                                                .toString() +
                                                            '時'
                                                        : datetimenow.hour
                                                            .toString()) +
                                                    '時';
                                                nowminuenter =
                                                    (datetimenow.minute < 10
                                                        ? '0' +
                                                            datetimenow.minute
                                                                .toString() +
                                                            '分'
                                                        : datetimenow.minute
                                                                .toString() +
                                                            '分');
                                                nowWorkenter =
                                                    nowhourenter + nowminuenter;
                                                var setdata =
                                                    FetchDatafromSQLite(
                                                        id,
                                                        ymdWork,
                                                        enterbutton,
                                                        outbutton,
                                                        imgdirenter,
                                                        imgdirout,
                                                        nowWorkenter,
                                                        nowWorkout);
                                                db.insertManager(setdata);
                                                _dialogCall(
                                                    context, imgdirenter);
                                              });
                                            },
                                    ),
                                  ),
                                  // SizedBox(width: 20.0,),
                                  SizedBox(
                                    width: 114,
                                    height: 48,
                                    child: RaisedButton(
                                      color: Colors.greenAccent,
                                      shape: StadiumBorder(),
                                      child: const Text('退勤'),
                                      onPressed: outbutton
                                          ? null
                                          : () async {
                                              int score = await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 1000),
                                                  () => 42);
                                              setState(() {
                                                datetimenow =
                                                    new DateTime.now();
                                                outbutton = !outbutton;

                                                nowhourout = (datetimenow.hour <
                                                            10
                                                        ? '0' +
                                                            datetimenow.hour
                                                                .toString() +
                                                            '時'
                                                        : datetimenow.hour
                                                            .toString()) +
                                                    '時';
                                                nowminuout =
                                                    (datetimenow.minute < 10
                                                        ? '0' +
                                                            datetimenow.minute
                                                                .toString() +
                                                            '分'
                                                        : datetimenow.minute
                                                                .toString() +
                                                            '分');
                                                nowWorkout =
                                                    nowhourout + nowminuout;
                                                // _setSharedPreOutbutton();
                                                var db = new DatabaseHelper();
                                                _dialogCall(context, imgdirout);
                                                var setdata =
                                                    FetchDatafromSQLite(
                                                        id,
                                                        ymdWork,
                                                        enterbutton,
                                                        outbutton,
                                                        imgdirenter,
                                                        imgdirout,
                                                        nowWorkenter,
                                                        nowWorkout);
                                                db.updateManager(setdata);
                                              });
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    decoration: new BoxDecoration(
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.grey,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                  flex: 2,
                ),
                Flexible(
                  child: bottomlistTask(),
                  flex: 3,
                ),
              ]));
    } else {
      return Center(
          child: Text(
        '会社のネットに接続してください',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
      ));
    }
  }

  Widget timeToWork(nowWorkenter, nowWorkout) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            decoration: myBoxDecoration(),
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width - 100.0,
              padding: EdgeInsets.only(top: 15.0),
              child: Text(
                '本日、$nowyear年$nowmonth月$nowday日',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: 80.0, top: 10.0, bottom: 10.0, right: 10.0),
                child: Text('出勤の時間　：    ' + nowWorkenter),
              ),
              Container()
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: 80.0, top: 10.0, bottom: 10.0, right: 10.0),
                child: Text('退勤の時間　：    ' + nowWorkout),
              ),
              Container()
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }

  bottomlistTask() {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('stack')
              .orderBy('timecreate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else{
            listtextField = [];
            List<DocumentSnapshot> docs = snapshot.data.documents;
            docs.map((doc) async {
              initializeDateFormatting("ja_JP");
              TextFieldList textlist = new TextFieldList();
              textlist.textFieldSubject = doc.data['subject'];
              textlist.textFieldAssignee = doc.data['assignee'];
              textlist.textFieldDescrip = doc.data['descrip'];
              var secondsdatetime = doc.data['timecreate'].microsecondsSinceEpoch;
              DateTime credatetime = DateTime.fromMicrosecondsSinceEpoch(secondsdatetime);
              var formatter = new DateFormat('yyyy年MM月dd(E) HH:mm', "ja_JP");
              textlist.datetimecreate = formatter.format(credatetime);
              listtextField.add(textlist);
            }).toList();
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: listtextField.length,
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, position) {
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Container(
                        width: 250.0,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, left: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Icon(
                                          Icons.work,
                                          color: appColors[position],
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if(clickicondeleteTask){
                                                  _firestore.collection('stack').document(snapshot.data.documents[position].documentID).delete();
                                                }
                                                clickicondeleteTask = true;
                                              });
                                            },
                                            icon: clickicondeleteTask ? 
                                            Icon(
                                              Icons.remove_circle,
                                              color: Colors.red, size: 40.0,
                                            ):
                                            Icon(
                                              Icons.more_vert,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                          child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            "題名 : ${listtextField[position].textFieldSubject}",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 18.0),
                                            maxLines: 2,
                                          ),
                                        ),
                                        flex: 2,
                                        ),
                                        Flexible(
                                          child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          child: Text(
                                            "担当者：${listtextField[position].textFieldAssignee}",
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12.0),
                                          ),
                                        ),
                                        flex: 1,
                                        ),
                                        Flexible(
                                          child: Container(
                                          width:MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            child: Text(
                                              "${listtextField[position].textFieldDescrip}",
                                              style: TextStyle(
                                                  color: Colors.black87),
                                              maxLines: 8,
                                            ),
                                          ),
                                        ),
                                        flex: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  flex: 11,
                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(2.0),
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      listtextField[position]
                                          .datetimecreate
                                          .toString(),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  flex: 1,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  onHorizontalDragEnd: (details) {
                    animationController = AnimationController(
                        vsync: this, duration: Duration(milliseconds: 500));
                    curvedAnimation = CurvedAnimation(
                        parent: animationController,
                        curve: Curves.fastOutSlowIn);
                    animationController.addListener(() {
                      setState(() {
                        currentColor = colorTween.evaluate(curvedAnimation);
                      });
                    });
                    if (details.primaryVelocity != 0.0) {
                      if (details.velocity.pixelsPerSecond.dx > 0) {
                        if (cardIndex > 0) {
                          cardIndex--;
                          colorTween = ColorTween(
                              begin: currentColor, end: appColors[cardIndex]);
                        }
                      } else {
                        if (cardIndex < listtextField.length) {
                          cardIndex++;
                          colorTween = ColorTween(
                              begin: currentColor, end: appColors[cardIndex]);
                        }
                      }
                    } else {
                      clickicondeleteTask = false;
                    }
                    setState(() {
                      scrollController.animateTo((cardIndex) * 256.0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn);
                    });

                    colorTween.animate(curvedAnimation);

                    animationController.forward();
                  },
                );
              },
            );
          }
          }
        ));
  }

  _showdialogTask() async {
    _textFieldAssignee.clear();
    _textFieldSubject.clear();
    _textFieldDescrip.clear();
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: AlertDialog(
            title: Container(
              decoration: BoxDecoration(
                 color: Color(0xff00bfa5),
                 borderRadius: BorderRadius.circular(10.0)
              ),
              child: Text('チケット作成',style: TextStyle(color: Colors.white),textAlign: TextAlign.center),
                         ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0)
            )),
            content: Container(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('題名'),
                            TextField(
                              controller: _textFieldSubject,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(hintText: ""),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('担当'),
                            TextField(
                              controller: _textFieldAssignee,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(hintText: ""),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('説明'),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(border: Border.all()),
                              child: TextField(
                                maxLines: 8,
                                controller: _textFieldDescrip,
                                keyboardType: TextInputType.text,
                                decoration:
                                    InputDecoration.collapsed(hintText: ""),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                padding: new EdgeInsets.all(5.0),
                decoration: new BoxDecoration(
                  color: const Color(0xFFffb304),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: new FlatButton(
                child: new Text('作成',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  setState(() {
                    createtask();
                    Navigator.of(context).pop();
                  });
                },
              ),
              ),
              Container(
                padding: new EdgeInsets.all(5.0),
                decoration: new BoxDecoration(
                  color: const Color(0xFFffb304),
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: new FlatButton(
                child: new Text('キャンセル',style: TextStyle(color: Colors.white),),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
              ),
              ),
                  ],
                ),
              )
            ],
          )
          );
        });
  }
}

class DelayTween extends Tween<double> {
  DelayTween({
    double begin,
    double end,
    this.delay,
  }) : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class TextFieldList {
  String textFieldSubject;
  String textFieldAssignee;
  String textFieldDescrip;
  String datetimecreate;
  TextFieldList(
      {this.textFieldSubject,
      this.textFieldAssignee,
      this.textFieldDescrip,
      this.datetimecreate});
}
