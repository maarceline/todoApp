import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceGroups {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //CREATE
  Future<void> createGroup(String groupName, {String description = ''}) {
    //reference to the groups collection
    DocumentReference groupRef = _firestore.collection('groups').doc(groupName);

    //set the data for the group document
    return groupRef.set({
      'name': groupName,
      'description': description,
      'creation': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getGroups() {
    return _firestore
        .collection('groups')
        .orderBy('creation', descending: true)
        .snapshots();
  }

  //UPDATE
  Future<void> updateGroup(
      String groupName, String newDescription, String newGroupName) {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupName);

    return groupRef.update({
      'description': newDescription,
      'name': newGroupName,
    });
  }

  //DELETE: deleting the group AND the notes
  Future<void> deleteGroup(String groupName) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupName);
    CollectionReference notesRef = groupRef.collection('notes');

    QuerySnapshot notesSnapshot = await notesRef.get();

    for (DocumentSnapshot doc in notesSnapshot.docs) {
      await doc.reference.delete();
    }

    return await groupRef.delete();
  }
}

class FirestoreServiceNotes {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //CREATE
  Future<void> addNoteToGroup(String groupName, String note) {
    //group reference
    DocumentReference groupRef = _firestore.collection('groups').doc(groupName);

    //set the data/add to collection
    return groupRef.collection('notes').add({
      'note': note,
      'creation': Timestamp.now(),
    });
  }

  //READ
  Stream<QuerySnapshot> getNotes(String groupName) {
    return _firestore
        .collection('groups')
        .doc(groupName)
        .collection('notes')
        .snapshots();
  }

  //UPDATE: edit notes
  Future<void> updateNote(String groupName, String newNote, String noteID,
      {required String newName}) {
    DocumentReference noteRef = _firestore
        .collection('groups')
        .doc(groupName)
        .collection('notes')
        .doc(noteID);

    return noteRef.update({
      'note': newNote,
      'creation': Timestamp.now(),
    });
  }

  //UPDATE: is done?
  Future<void> toggleDoneStatus(
      String groupName, String noteID, bool isDone) async {
    await _firestore
        .collection('groups')
        .doc(groupName)
        .collection('notes')
        .doc(noteID)
        .update({'isDone': isDone});
  }

  //DELETE
  Future<void> deleteNote(String groupName, String noteID) {
    DocumentReference noteRef = _firestore
        .collection('groups')
        .doc(groupName)
        .collection('notes')
        .doc(noteID);

    return noteRef.delete();
  }
}
