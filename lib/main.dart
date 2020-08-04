import 'package:cloud_firestore/cloud_firestore.dart';
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
        primarySwatch: Colors.blue,
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
  var _currentSnapshots = Firestore.instance
      .collection('tasks')
      .where("status", isEqualTo: "new")
      .snapshots();
  int _currentTabView = 0;

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
    var task = Task(title: _newTaskCtrl.text, done: false);
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

  Future<void> update(String itemID, bool value) async {
    await Firestore.instance
        .collection('tasks')
        .document(itemID)
        .updateData(<String, dynamic>{'done': value});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
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
                    .where("status", isEqualTo: filter)
                    .snapshots();
              });
            },
            tabs: <Widget>[
              Text(
                "New",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "In Progress",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "Done",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          title: TextFormField(
            controller: _newTaskCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              labelText: "New Task",
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
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
                  itemBuilder: (BuildContext ctxt, int index) {
                    final item = snapshot.data.documents[index];
                    final itemID = snapshot.data.documents[index].documentID;

                    return Dismissible(
                      key: Key(itemID),
                      background: Container(
                        color: Colors.red.withOpacity(0.2),
                      ),
                      onDismissed: (direction) {
                        remove(snapshot, index);
                      },
                      child: CheckboxListTile(
                        title: Text("${item.data['title']}"),
                        value: item.data['done'],
                        onChanged: (value) {
                          update(itemID, value);
                        },
                      ),
                    );
                  },
                );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: add,
          child: Icon(Icons.add),
          backgroundColor: Colors.pink,
        ),
      ),
    );
  }
}
