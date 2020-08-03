import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models/item.dart';

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

  MyHomePage() {
    items = [];
    items.add(Item(title: "Item 1", done: false));
    items.add(Item(title: "Item 2", done: true));
    items.add(Item(title: "Item 3", done: true));
  }

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
    setState(() {
      widget.items.add(
        Item(title: newTaskCtrl.text, done: false),
      );
      newTaskCtrl.clear();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
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
            labelText: "New item",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      // body: ListView.builder(
      //   itemCount: widget.items.length,
      //   itemBuilder: (BuildContext ctxt, int index) {
      //     final item = widget.items[index];
      //     return Dismissible(
      //       key: Key(item.title),
      //       background: Container(
      //         color: Colors.red.withOpacity(0.2),
      //       ),
      //       onDismissed: (direction) {},
      //       child: CheckboxListTile(
      //         title: Text(item.title),
      //         value: item.done,
      //         onChanged: (value) {
      //           setState(() {
      //             item.done = value;
      //           });
      //         },
      //       ),
      //     );
      //   },
      // ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('items').snapshots(),
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
                    onDismissed: (direction) {},
                    child: CheckboxListTile(
                      title: Text("${item.data['name']}"),
                      value: false,
                      onChanged: (value) {},
                    ),
                  );
                },
              );
            // return Center(
            //   child: ListView(
            //     children: snapshot.data.documents
            //         .map<Widget>((DocumentSnapshot doc) {
            //       return ListTile(
            //         leading: Icon(Icons.people, size: 52),
            //         title: Text("${doc.data['name']}"),
            //       );
            //     }).toList(),
            //   ),
            // );
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
