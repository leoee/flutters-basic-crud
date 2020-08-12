import 'package:flutter/material.dart';
import 'package:flutter_basics/src/home/home-bloc.dart';

class AppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

AppBar getAppBar(HomeBloc homeBloc, int _currentTabView,
    TextEditingController textNameTask) {
  if (_currentTabView == 0) {
    return AppBar(
      title: TextFormField(
        controller: textNameTask,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          labelText: "Tap to enter task name",
          hintText: "Task name",
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
    );
  } else if (_currentTabView == 1) {
    return AppBar(
      title: Text(HomeBloc.IN_PROGRESS),
      backgroundColor: Colors.white,
    );
  } else {
    return AppBar(
      title: Text(HomeBloc.DONE),
      backgroundColor: Colors.white,
    );
  }
}
