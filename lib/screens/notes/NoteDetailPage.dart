import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/note_models/note.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: removeHtmlTags(widget.note.content)); // Enlever les balises HTML
  }

  // Fonction pour enlever les balises HTML, ajouter des tabulations et conserver les sauts de ligne
  String removeHtmlTags(String htmlString) {
    // Remplacer les balises <div> par un saut de ligne suivi d'une tabulation
    String text = htmlString.replaceAllMapped(
      RegExp(r'<div[^>]*>(.*?)<\/div>'),
      (match) => '\t${match.group(1)}\n'
    );
    
    // Remplacer les balises <p> par des sauts de ligne également
   // text = text.replaceAll(RegExp(r'<\/?p[^>]*>'), '\n');

    // Enlever toutes les autres balises HTML
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          style: TextStyle(
            height: 2
          ),
          controller: _controller,
          maxLines: null, // Permettre plusieurs lignes
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
