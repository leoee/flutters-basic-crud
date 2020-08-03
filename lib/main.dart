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
  var items = new List<Item>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) {
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
    setState(() async {
      var item = Item(title: newTaskCtrl.text, done: false);
      CollectionReference dbReplies = Firestore.instance.collection('tasks');
      await Firestore.instance
          .runTransaction((Transaction myTransaction) async {
        await dbReplies.add(item.toJson());
      });
      newTaskCtrl.clear();
    });
  }

  void remove(AsyncSnapshot snapshot, int index) {
    setState(() async {
      await Firestore.instance
          .runTransaction((Transaction myTransaction) async {
        await myTransaction.delete(snapshot.data.documents[index].reference);
      });
    });
  }

  void update(String itemID, bool value) {
    setState(() async {
      await Firestore.instance
          .collection('tasks')
          .document(itemID)
          .updateData(<String, dynamic>{'done': value});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
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
        stream: Firestore.instance.collection('tasks').snapshots(),
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
    );
  }
}
