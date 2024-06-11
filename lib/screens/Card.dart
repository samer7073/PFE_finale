// ignore_for_file: prefer_const_constructors

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/KanbanModels/Element.dart';

import '../services/ApiDeleteElment.dart';
import 'EditElment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Cardwidget extends StatefulWidget {
  final KanbanElement element;
  final String familyId;

  final Function(KanbanElement) deleteFunction;

  Cardwidget({
    required this.element,
    required this.deleteFunction,
    required this.familyId,
  });

  @override
  State<Cardwidget> createState() => _CardwidgetState();
}

class _CardwidgetState extends State<Cardwidget> {
  @override
  void initState() {
    super.initState();
  }

  String familyName(String famille) {
    if (famille == "6") {
      return "Ticket";
    } else {
      if (famille == "7") {
        return "Project";
      } else {
        return "Deal";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 245, 244, 244),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(AppLocalizations.of(context).ref + " ",
                    style: TextStyle(color: Colors.black)),
                SizedBox(
                  width: 5,
                ),
                Text(widget.element.reference,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget.element.creator.label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                widget.element.creator.avatar.length == 1
                    ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25, // Choisissez une couleur de fond appropriée
                        child: Text(
                          widget.element.creator.avatar,
                          style: TextStyle(
                              color: Colors
                                  .white), // Choisissez une couleur de texte appropriée
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://spherebackdev.cmk.biz:4543/storage/uploads/${widget.element.creator.avatar}"),
                        radius: 15,
                      ),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.note_alt_rounded,
                    size: 28,
                    color: Color.fromARGB(255, 28, 175, 9),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditElment(
                          Element_id: widget.element.elementId,
                          family_id: widget.familyId,
                          title: familyName(widget.familyId),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    size: 28,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                  tooltip: 'Chat',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 28,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete"),
                          content: Text(
                              "Are you sure you want to delete this ticket ?"),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                // User confirmed deletion
                                widget.deleteFunction(widget.element);
                              },
                              child: Text("Yes"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // User cancelled deletion
                              },
                              child: Text("No"),
                            )
                          ],
                        );
                      },
                    );
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
