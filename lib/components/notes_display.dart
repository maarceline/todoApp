import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:to_to_list_application/services/firestore.dart';

class NotesDisplay extends StatefulWidget {
  final String notes;
  final Timestamp timestamp;
  void Function(BuildContext) onPressed;
  void Function(BuildContext) onPressedUpdate;
  final void Function(bool) onToggleDone;
  final bool isDone;

  NotesDisplay(
      {super.key,
      required this.notes,
      required this.timestamp,
      required this.onPressed,
      required this.onPressedUpdate,
      required this.onToggleDone,
      required this.isDone});

  @override
  State<NotesDisplay> createState() => _NotesDisplayState();
}

class _NotesDisplayState extends State<NotesDisplay> {
  bool isDone = false;
  final FirestoreServiceNotes firestoreServiceNotes = FirestoreServiceNotes();

  @override
  void initState() {
    super.initState();
    isDone = widget.isDone;
  }

  void toggleDoneStatus() {
    setState(() {
      isDone = !isDone;
    });
    widget.onToggleDone(isDone);
  }

  String formatTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, ' ' h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 15),
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: widget.onPressed,
              backgroundColor: const Color.fromARGB(255, 250, 123, 114),
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
            SlidableAction(
              onPressed: widget.onPressedUpdate,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: toggleDoneStatus,
          child: Row(
            children: [
              isDone
                  ? Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notes,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    formatTimeStamp(widget.timestamp),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
