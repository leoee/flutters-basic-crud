import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics/src/home/home-service.dart';

class HomeBloc extends BlocBase {
  HomeService homeService;

  HomeBloc() {
    homeService = HomeService();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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

  DismissDirection getValidDismissable(var item) {
    var value = item.data['status'];
    if (value == "new") {
      return DismissDirection.startToEnd;
    } else if (value == "done") {
      return DismissDirection.endToStart;
    } else {
      return DismissDirection.horizontal;
    }
  }
}
