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
  AppBarWidget appBarWidget;
  BodyWidget bodyWidget;
  var _textNameTask;
  GlobalKey _bottomNavigationKey;
  var _currentSnapshots;
  int _currentTabView = 0;

  _HomeState() {
    homeBloc = HomeBloc();
    appBarWidget = AppBarWidget();
    bodyWidget = BodyWidget();
    owner = "leoe";
    _bottomNavigationKey = GlobalKey();
    _textNameTask = TextEditingController();
    _currentSnapshots = homeBloc.filterListByStatus(_currentTabView, owner);
  }

  void buttonAddTask(TextEditingController _textNameTask) {
    String text = _textNameTask.text;
    if (text.isEmpty) {
      return dialog("Alert", "Task name is empty");
    } else if (text.length > 30) {
      return dialog("Alert", "Task name must have less than 30 characters.");
    }

    var task = Task(
        title: text,
        status: homeBloc.newMessage,
        owner: owner,
        description: "This is a description");

    homeBloc.homeService.add(task);
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
              homeBloc.newMessage,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              homeBloc.inProgressMessage,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              homeBloc.doneMessage,
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
        appBar:
            appBarWidget.getAppBar(homeBloc, _currentTabView, _textNameTask),
        body: bodyWidget.getBody(homeBloc, _currentSnapshots),
        backgroundColor: Colors.orangeAccent,
        floatingActionButton: _bottomButtons(_currentTabView),
      ),
    );
  }
}
