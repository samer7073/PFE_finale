import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/KanbanModels/Element.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';



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
  late Future<String> imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
  }

  String familyName(String famille) {
    if (famille == "6") {
      return "Ticket";
    } else if (famille == "7") {
      return "Project";
    } else {
      return "Deal";
    }
  }

  void _onPopupMenuSelected(
    String value,
  ) {
    switch (value) {
      case 'edit':
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
        break;
      case 'delete':
        widget.deleteFunction(widget.element);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.blue,
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading image URL');
        }

        String baseUrl = snapshot.data ?? "";

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1), // Bordure grise de 1 pixel de large
              borderRadius:
                  BorderRadius.circular(15), // Coins arrondis (facultatif)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.ref + " ",
                              ),
                          Text(widget.element.labelData,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  )),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          _onPopupMenuSelected(value);
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Delete'),
                              ),
                            ),
                          ];
                        },
                        icon: Icon(Icons.more_horiz_outlined,
                            ),
                      ),
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
                          
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      widget.element.creator.avatar.length == 1
                          ? CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 15,
                              child: Text(
                                widget.element.creator.avatar,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "$baseUrl${widget.element.creator.avatar}"),
                              radius: 15,
                            ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                
                ]
                ,
              ),
            ),
          ),
        );
      },
    );
  }
}
