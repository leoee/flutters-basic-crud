import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics/src/home/home-service.dart';

class HomeBloc extends BlocBase {
  HomeService homeService;
  final String newMessage = "New";
  final String inProgressMessage = "In Progress";
  final String doneMessage = "Done";

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
    if ((value == newMessage && forward) ||
        (value == doneMessage && !forward)) {
      return inProgressMessage;
    } else if (value == inProgressMessage && forward) {
      return doneMessage;
    } else if (value == inProgressMessage) {
      return newMessage;
    } else {
      return "";
    }
  }

  DismissDirection getValidDismissable(var item) {
    var value = item.data['status'];
    if (value == newMessage) {
      return DismissDirection.startToEnd;
    } else if (value == doneMessage) {
      return DismissDirection.endToStart;
    } else {
      return DismissDirection.horizontal;
    }
  }

  Query filterDataByStatus(int tabIndex, String ownerName) {
    String filter = "";
    if (tabIndex == 0) {
      filter = newMessage;
    } else if (tabIndex == 1) {
      filter = inProgressMessage;
    } else {
      filter = doneMessage;
    }
    // return Firestore.instance
    //     .collection('tasks')
    //     .where("owner", isEqualTo: owner)
    //     .where("status", isEqualTo: filter)
    //     .snapshots();
    CollectionReference collectionReference =
        homeService.getCollectionReference("tasks");
    Query dataFilteredByOwner =
        filterDataByAttribute(collectionReference, "owner", ownerName);

    return homeService.filterCollectionByAttribute(
        dataFilteredByOwner, "status", filter);
  }

  Query filterDataByAttribute(CollectionReference collectionReference,
      String attributeName, String attributeValue) {
    return homeService.filterCollectionByAttribute(
        collectionReference, attributeName, attributeValue);
  }
}
