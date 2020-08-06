import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_basics/shared/models/task.dart';

class HomeService {
  Future<void> add(Task task) async {
    CollectionReference dbReplies = Firestore.instance.collection('tasks');
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await dbReplies.add(task.toJson());
    });
  }

  Future<void> remove(AsyncSnapshot snapshot, int index) async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(snapshot.data.documents[index].reference);
    });
  }

  Future<void> update(String itemID, String field, String value) async {
    await Firestore.instance
        .collection('tasks')
        .document(itemID)
        .updateData(<String, dynamic>{field: value});
  }
}
