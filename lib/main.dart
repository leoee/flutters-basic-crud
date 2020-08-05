import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'models/task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _newTaskCtrl = TextEditingController();
  GlobalKey _bottomNavigationKey = GlobalKey();
  var _currentSnapshots = Firestore.instance
      .collection('tasks')
      .where("owner", isEqualTo: "leoe")
      .where("status", isEqualTo: "new")
      .snapshots();
  int _currentTabView = 0;

  Widget _bottomButtons() {
    return _currentTabView == 0
        ? FloatingActionButton(
            onPressed: add,
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
          )
        : null;
  }

  Future<void> add() async {
    if (_newTaskCtrl.text.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Alert"),
              content: Text("Name is empty."),
              actions: <Widget>[
                FloatingActionButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return;
    }
    var task = Task(
        title: _newTaskCtrl.text,
        status: "new",
        owner: "leoe",
        description: "This is a description");
    CollectionReference dbReplies = Firestore.instance.collection('tasks');
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await dbReplies.add(task.toJson());
    });
    _newTaskCtrl.clear();
  }

  Future<void> remove(AsyncSnapshot snapshot, int index) async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(snapshot.data.documents[index].reference);
    });
  }

  Future<void> update(String itemID, String value) async {
    await Firestore.instance
        .collection('tasks')
        .document(itemID)
        .updateData(<String, dynamic>{'status': value});
  }

  String getNextState(var item, DismissDirection direction) {
    var value = item.data['status'];
    var forward = direction == DismissDirection.startToEnd ? true : false;
    if ((value == "new" && forward) || (value == "done" && !forward)) {
      return "progress";
    } else if (value == "progress" && forward) {
      return "done";
    } else if (value == "progress") {
      return "new";
    } else {
      return "";
    }
  }

  DismissDirection _getValidDismissable(var item) {
    var value = item.data['status'];
    if (value == "new") {
      return DismissDirection.startToEnd;
    } else if (value == "done") {
      return DismissDirection.endToStart;
    } else {
      return DismissDirection.horizontal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.orangeAccent,
            key: _bottomNavigationKey,
            items: <Widget>[
              Text(
                "New",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                "In Progress",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              Text(
                "Done",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
            onTap: (tab) {
              _currentTabView = tab;
              var filter = "";
              if (tab == 0) {
                filter = "new";
              } else if (tab == 1) {
                filter = "progress";
              } else {
                filter = "done";
              }
              setState(() {
                _currentSnapshots = Firestore.instance
                    .collection('tasks')
                    .where("owner", isEqualTo: "leoe")
                    .where("status", isEqualTo: filter)
                    .snapshots();
              });
            },
          ),
          appBar: AppBar(
            title: TextFormField(
              controller: _newTaskCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                labelText: "Task Name",
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            backgroundColor: Colors.white,
          ),
          body: StreamBuilder(
            stream: _currentSnapshots,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return LinearProgressIndicator();
                  break;
                default:
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    padding: EdgeInsets.all(5),
                    itemBuilder: (BuildContext ctxt, int index) {
                      final item = snapshot.data.documents[index];
                      final itemID = snapshot.data.documents[index].documentID;

                      return Dismissible(
                          direction: _getValidDismissable(item),
                          key: Key(itemID),
                          background: Container(
                            color: Colors.green.withOpacity(0.2),
                          ),
                          onDismissed: (direction) {
                            String nextState = getNextState(item, direction);
                            if (nextState.isNotEmpty) {
                              update(itemID, nextState);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "${item.data['title']}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: Icon(Icons.info),
                                  onPressed: () {},
                                ),
                              )
                            ],
                          ));
                    },
                  );
              }
            },
          ),
          backgroundColor: Colors.orangeAccent,
          floatingActionButton: _bottomButtons()),
    );
  }
}
