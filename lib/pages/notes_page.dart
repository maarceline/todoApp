import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:to_to_list_application/components/notes_display.dart';
import 'package:to_to_list_application/components/notes_tile.dart';
import 'package:to_to_list_application/services/firestore.dart';

class NotesPage extends StatelessWidget {
  final String groupName;
  NotesPage({super.key, required this.groupName});
  final FirestoreServiceGroups firestoreServiceGroups =
      FirestoreServiceGroups();
  final FirestoreServiceNotes firestoreServiceNotes = FirestoreServiceNotes();

  final TextEditingController notesNameController = TextEditingController();
  final TextEditingController newNotesNameController = TextEditingController();

  void deleteNoteU(String groupName, String noteID) {
    firestoreServiceNotes.deleteNote(groupName, noteID);
  }

  void editNote(String docID, String currentNote, BuildContext context) {
    newNotesNameController.text = currentNote;

    openEditBox(
        context: context,
        onSave: () {
          //update note in firestore
          firestoreServiceNotes.updateNote(
              groupName, newNotesNameController.text, docID,
              newName: newNotesNameController.text);
        });
  }

  void openEditBox({required BuildContext context, required Function onSave}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Change To Do Name',
            hintStyle: TextStyle(color: Colors.grey.shade700),
          ),
          controller: newNotesNameController,
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                onSave();
                if (Navigator.of(context).mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('save'))
        ],
      ),
    );
  }

  void createGroupBox({String? docID, required String groupName, context}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Add a To Do ;)',
                hintStyle: TextStyle(color: Colors.grey.shade700)),
            controller: notesNameController,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //create a new group
              if (docID == null) {
                firestoreServiceNotes.addNoteToGroup(
                    groupName, notesNameController.text);
              }
              notesNameController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'add',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createGroupBox(groupName: groupName, context: context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreServiceNotes.getNotes(groupName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List groupList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = groupList[index];
                String docID = document.id;

                //get group
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String notes = data['note'];
                Timestamp timestamp = data['creation'];
                bool isDone = data['isDone'] ?? false;

                //
                return NotesDisplay(
                  notes: notes,
                  timestamp: timestamp,
                  onPressed: (context) => deleteNoteU(groupName, docID),
                  onPressedUpdate: (context) => editNote(docID, notes, context),
                  onToggleDone: (isDone) => firestoreServiceNotes
                      .toggleDoneStatus(groupName, docID, isDone),
                  isDone: isDone,
                );
              },
            );
          } else {
            return const Text('no notes yet...');
          }
        },
      ),
    );
  }
}
