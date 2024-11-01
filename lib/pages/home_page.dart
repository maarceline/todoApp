import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_to_list_application/components/my_drawer.dart';
import 'package:to_to_list_application/components/notes_tile.dart';
import 'package:to_to_list_application/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirestoreServiceGroups firestoreServiceGroups =
      FirestoreServiceGroups();
  final FirestoreServiceNotes firestoreServiceNotes = FirestoreServiceNotes();

  void deleteGroup(String groupName) {
    firestoreServiceGroups.deleteGroup(groupName);
  }

  void editGroups(
      String groupName, String newDescription, String newGroupName) {
    firestoreServiceGroups.updateGroup(groupName, newDescription, newGroupName);
  }

  void createGroupBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Name your new list',
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                  ),
                  controller: groupNameController,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Give it a description',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  controller: descriptionController,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //create a new group
              if (docID == null) {
                firestoreServiceGroups.createGroup(groupNameController.text,
                    description: descriptionController.text);
              }
              groupNameController.clear();
              descriptionController.clear();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('My ToDos')),
      drawer: const MyDrawer(),

      //add button
      floatingActionButton: FloatingActionButton(
        onPressed: createGroupBox,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreServiceGroups.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List groupList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = groupList[index];
                //String docID = document.id;

                //get group
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String groupName = data['name'];
                String groupDescription = data['description'];

                //
                return NotesTile(
                  groupName: groupName,
                  groupDescription: groupDescription,
                  onTap: (context) => deleteGroup(groupName),
                  onPressedGroups: (newGroupName, newDescription) {
                    editGroups(groupName, newDescription, newGroupName);
                  },
                );
              },
            );
          } else {
            return const Text('no groups yet...');
          }
        },
      ),
    );
  }
}
