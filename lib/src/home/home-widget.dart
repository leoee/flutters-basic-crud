import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/models/task.dart';
import 'home-bloc.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String owner;
  HomeBloc homeBloc;
  var _textNameTask;
  GlobalKey _bottomNavigationKey;
  var _currentSnapshots;
  int _currentTabView = 0;

  _HomeState() {
    homeBloc = HomeBloc();
    owner = "leoe";
    _bottomNavigationKey = GlobalKey();
    _textNameTask = TextEditingController();
    _currentSnapshots = homeBloc.filterListByStatus(_currentTabView, owner);
  }

  void floatButtonAdd(TextEditingController _textNameTask) {
    if (_textNameTask.text.isEmpty) {
      dialog("Alert", "Name is empty");
      return;
    }

    var task = Task(
        title: _textNameTask.text,
        status: "new",
        owner: owner,
        description: "This is a description");

    homeBloc.homeService.add(task);
    _textNameTask.clear();
  }

  Widget _bottomButtons(int currentTabView) {
    return currentTabView == 0
        ? FloatingActionButton(
            onPressed: () => floatButtonAdd(_textNameTask),
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
          )
        : null;
  }

  dynamic dialog(String title, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
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
            setState(() {
              _currentSnapshots = homeBloc.filterListByStatus(tab, owner);
            });
          },
        ),
        appBar: AppBar(
          title: TextFormField(
            controller: _textNameTask,
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
                        direction: homeBloc.getValidDismissable(item),
                        key: Key(itemID),
                        background: Container(
                          color: Colors.green.withOpacity(0.2),
                        ),
                        onDismissed: (direction) {
                          String nextState =
                              homeBloc.getNextState(item, direction);
                          if (nextState.isNotEmpty) {
                            homeBloc.homeService
                                .update(itemID, "status", nextState);
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
        floatingActionButton: _bottomButtons(_currentTabView),
      ),
    );
  }
}
