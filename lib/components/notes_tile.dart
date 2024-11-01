// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:to_to_list_application/pages/notes_page.dart';

class NotesTile extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final void Function(String groupName) onTap;
  final void Function(String newGroupName, String newDescription)
      onPressedGroups;

  NotesTile({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.onTap,
    required this.onPressedGroups,
  });

  final TextEditingController newGroupNameController = TextEditingController();
  final TextEditingController newDescriptionNameController =
      TextEditingController();

  void openEditGroupBox(
      BuildContext context,
      Function(String, String) newGroupName,
      String currentName,
      String currentDescription) {
    newGroupNameController.text = currentName;
    newDescriptionNameController.text = currentDescription;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 150),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'New group name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                controller: newGroupNameController,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'New Description',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                controller: newDescriptionNameController,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              newGroupName(newGroupNameController.text,
                  newDescriptionNameController.text);
              Navigator.pop(context);
            },
            child: Text('save!'),
          ),
        ],
      ),
    );
  }

  void openConfirmationBox(
      {String? groupName, Function? onTap, required BuildContext context}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to delete?',
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          onTap!(groupName);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(fontSize: 15, color: Colors.red),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Cancel',
                            style: TextStyle(
                              fontSize: 15,
                            ))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotesPage(
            groupName: groupName,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                        //delete group button
                        onTap: () => openConfirmationBox(
                            context: context,
                            groupName: groupName,
                            onTap: onTap),
                        child: const Icon(Icons.delete)),
                    const SizedBox(width: 10),
                    //edit group button
                    GestureDetector(
                      onTap: () => openEditGroupBox(
                        context,
                        (newGroupName, newDescription) {
                          onPressedGroups(newGroupName, newDescription);
                        },
                        groupName,
                        groupDescription,
                      ),
                      child: Icon(Icons.edit),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Text(groupDescription, style: const TextStyle(fontSize: 15))
          ],
        ),
      ),
    );
  }
}
