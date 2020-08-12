import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_basics/shared/models/task.dart';

class HomeService {
  Future<void> addTask(String collectionName, Task task) async {
    CollectionReference dbReplies =
        Firestore.instance.collection(collectionName);
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await dbReplies.add(task.toJson());
    });
  }

  Future<void> removeTask(AsyncSnapshot snapshot, int index) async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(snapshot.data.documents[index].reference);
    });
  }

  Future<void> updateTask(
      String collectionName, String itemID, String field, String value) async {
    await Firestore.instance
        .collection(collectionName)
        .document(itemID)
        .updateData(<String, dynamic>{field: value});
  }

  CollectionReference getCollectionReference(String collectionName) {
    return Firestore.instance.collection(collectionName);
  }

  Query retrieveCollectionByAttribute(
      Query collectionReference, String attributeName, String attributeValue) {
    return collectionReference.where(attributeName, isEqualTo: attributeValue);
  }

  Future<int> getTasksLengthByAttribute(String collectionName,
      String attributeName, String attributeValue) async {
    QuerySnapshot documentsFiltered = await Firestore.instance
        .collection(collectionName)
        .where(attributeName, isEqualTo: attributeValue)
        .getDocuments();

    return documentsFiltered.documents.length;
  }
}
