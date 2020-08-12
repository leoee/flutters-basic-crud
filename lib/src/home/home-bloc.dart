import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics/shared/models/task.dart';
import 'package:flutter_basics/src/home/home-service.dart';

class HomeBloc extends BlocBase {
  HomeService _homeService;
  static const NEW = "New";
  static const IN_PROGRESS = "In Progress";
  static const DONE = "Done";

  HomeBloc() {
    _homeService = HomeService();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  String getNextState(var item, DismissDirection direction) {
    var value = item.data['status'];
    var forward = direction == DismissDirection.startToEnd ? true : false;
    if ((value == NEW && forward) || (value == DONE && !forward)) {
      return IN_PROGRESS;
    } else if (value == IN_PROGRESS && forward) {
      return DONE;
    } else if (value == IN_PROGRESS) {
      return DONE;
    } else {
      return "";
    }
  }

  DismissDirection getValidDismissable(var item) {
    var value = item.data['status'];
    if (value == NEW) {
      return DismissDirection.startToEnd;
    } else if (value == DONE) {
      return DismissDirection.endToStart;
    } else {
      return DismissDirection.horizontal;
    }
  }

  CollectionReference getCollectionReference(String collectionName) {
    return _homeService.getCollectionReference(collectionName);
  }

  Future<void> addTask(String collectionName, Task task) async {
    _homeService.addTask(collectionName, task);
  }

  Future<void> removeTask(AsyncSnapshot snapshot, int index) async {
    _homeService.removeTask(snapshot, index);
  }

  Future<void> updateTask(
      String collectionName, String itemID, String field, String value) async {
    _homeService.updateTask(collectionName, itemID, field, value);
  }

  Query retrieveDataByStatus(int tabIndex, String ownerName) {
    String filter = "";
    if (tabIndex == 0) {
      filter = NEW;
    } else if (tabIndex == 1) {
      filter = IN_PROGRESS;
    } else {
      filter = DONE;
    }

    CollectionReference collectionReference =
        _homeService.getCollectionReference("leoe");
    Query dataFilteredByOwner =
        retrieveDataByAttribute(collectionReference, "owner", ownerName);

    return _homeService.retrieveCollectionByAttribute(
        dataFilteredByOwner, "status", filter);
  }

  Query retrieveDataByAttribute(CollectionReference collectionReference,
      String attributeName, String attributeValue) {
    return _homeService.retrieveCollectionByAttribute(
        collectionReference, attributeName, attributeValue);
  }

  Future<String> validateTaskName(
      String taskName, String collectionName) async {
    String response = "";
    int numberOfNamesOnDB = await _homeService.getTasksLengthByAttribute(
        collectionName, "title", taskName);

    if (taskName.isEmpty) {
      response = "Task name cannot be empty.";
    } else if (taskName.length > 30) {
      response = "Task name must have less than 30 characters.";
    } else if (numberOfNamesOnDB > 0) {
      response =
          "Task name must be unique. You already have a task with this name.";
    }
    return response;
  }
}
