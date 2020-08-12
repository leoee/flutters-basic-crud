import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics/src/home/widgets/body-widget.dart';

import '../../shared/models/task.dart';
import 'home-bloc.dart';
import 'widgets/appBar-widget.dart';

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
    _currentSnapshots =
        homeBloc.retrieveDataByStatus(_currentTabView, owner).snapshots();
  }

  Future<void> buttonAddTask(TextEditingController _textNameTask) async {
    String taskName = _textNameTask.text;
    String responseValidateTaskName =
        await homeBloc.validateTaskName(taskName, owner);

    if (responseValidateTaskName.isNotEmpty) {
      return dialog("Alert", responseValidateTaskName);
    }

    var task = Task(
        title: taskName,
        status: HomeBloc.NEW,
        owner: owner,
        description: "This is a description");

    homeBloc.addTask("leoe", task);
    _textNameTask.clear();
  }

  Widget _bottomButtons(int currentTabView) {
    return currentTabView == 0
        ? FloatingActionButton(
            onPressed: () => buttonAddTask(_textNameTask),
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
            backgroundColor: Colors.orangeAccent,
            actions: <Widget>[
              FloatingActionButton(
                child: Text("Ok"),
                backgroundColor: Colors.white,
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
              HomeBloc.NEW,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              HomeBloc.IN_PROGRESS,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              HomeBloc.DONE,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
          onTap: (tab) {
            _currentTabView = tab;
            setState(() {
              _currentSnapshots =
                  homeBloc.retrieveDataByStatus(tab, owner).snapshots();
            });
          },
        ),
        appBar: getAppBar(homeBloc, _currentTabView, _textNameTask),
        body: getBody(homeBloc, _currentSnapshots),
        backgroundColor: Colors.orangeAccent,
        floatingActionButton: _bottomButtons(_currentTabView),
      ),
    );
  }
}
