import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/models/chatUserModel/chatUserModel.dart';
import 'package:flutter_application_stage_project/models/note_models/note.dart';
import 'package:flutter_application_stage_project/models/note_models/shared_with.dart';
import 'package:flutter_application_stage_project/screens/notes/NoteDetailPage.dart';
import 'package:flutter_application_stage_project/services/chat/chat.dart';
import 'package:flutter_application_stage_project/services/notes/notes_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart'; // Importer le package

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  bool _showExtraButtons = false;

  @override
  void initState() {
    super.initState();
    fetchNotes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchMoreNotes();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchController.text;
        page = 1;
        notes.clear();
        fetchNotes();
      });
    });
  }

  Future<void> fetchNotes() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Note> fetchedNotes = await NoteService.getAllNotes(
          page: page); // Suppression de l'argument search
      setState(() {
        notes.addAll(fetchedNotes);
        isLoading = false;
        hasMore = fetchedNotes.length == 10;
      });
    } catch (error) {
      log('Error fetching Notes: $error');
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  Future<void> fetchMoreNotes() async {
    if (!isLoading && hasMore) {
      page++;
      await fetchNotes();
    }
  }

  void _toggleExtraButtons() {
    setState(() {
      _showExtraButtons = !_showExtraButtons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /*
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Organisation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
              ),
            ),
          ),
          */
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    _scrollController.position.extentAfter == 0 &&
                    hasMore) {
                  fetchMoreNotes();
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: notes.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < notes.length) {
                    final note = notes[index];
                    return NoteTile(note: note);
                  } else {
                    return Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : SizedBox.shrink(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteTile extends StatefulWidget {
  final Note note;

  const NoteTile({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  late Future<String> imageUrlFuture;
  late List<ChatUser> Users = [];
  Future<void> fetchUsers() async {
    try {
      final userResponse = await ChatRomm.fetchAllUsers();
      setState(() {
        Users = userResponse;
        log("users ${Users.length}");
      });
    } catch (e) {
      log('Failed to fetch Users: $e');
    }
  }

  @override
  void initState() {
    imageUrlFuture = Config.getApiUrl("urlImage");
    fetchUsers();
    // TODO: implement initState
    super.initState();
  }

  Widget _buildAvatars(List<ChatUser> users, List<SharedWith> sharedList) {
    List<Widget> avatars = [];
    Set<String> sharedUuids = sharedList.map((shared) => shared.uuid).toSet();
    List<ChatUser> usersToDisplay =
        users.where((user) => sharedUuids.contains(user.uuid)).toList();

    // Limiter à 4 avatars
    int displayLimit = 4;
    int remainingUsers = usersToDisplay.length - displayLimit;

    for (int i = 0; i < usersToDisplay.length && i < displayLimit; i++) {
      final user = usersToDisplay[i];
      avatars.add(
        Positioned(
          left: i * 20.0, // Décalage horizontal
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            verticalOffset: 48,
            height: 50,
            textStyle: TextStyle(color: Colors.white),
            message: "${user.name}",
            child: _buildAvatar(user.image, user.name),
          ),
        ),
      );
    }

    // Si plus de 4 utilisateurs, afficher un avatar supplémentaire avec "+X"
    if (remainingUsers > 0) {
      // Créer une chaîne avec les noms des utilisateurs restants
      String remainingUsersNames =
          usersToDisplay.skip(displayLimit).map((user) => user.name).join("\n");

      avatars.add(
        Positioned(
          left: displayLimit * 20.0,
          child: Tooltip(
            triggerMode:
                TooltipTriggerMode.tap, // Active le tooltip au tap (ou survol)
            verticalOffset: 48,
            height: 50,
            textStyle: TextStyle(color: Colors.white),
            message: "Et ${remainingUsers} autres: $remainingUsersNames \n",
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blueGrey,
              child: Text(
                "+$remainingUsers",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: (displayLimit + 1) *
          30.0, // Ajuster la largeur pour les avatars + "+X"
      height: 40,
      color: Colors.transparent,
      child: Stack(children: avatars),
    );
  }

  String formatDate(String dateString, Locale locale) {
    DateTime date = DateTime.parse(dateString);
    String formattedDate =
        DateFormat.yMMMMd(locale.languageCode).add_Hm().format(date);
    return formattedDate;
  }

  Widget _buildAvatar(String? avatar, String label) {
    if (avatar == null || avatar.length == 1) {
      String initial = avatar != null && avatar.length == 1
          ? avatar
          : (label.isNotEmpty ? label[0].toUpperCase() : '?');
      return CircleAvatar(
        radius: 15, // Ajuster la taille du CircleAvatar
        backgroundColor:
            Colors.blueGrey, // Définir une couleur de fond si nécessaire
        child: Text(
          initial,
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 30, // Ajuster la taille du CircleAvatar
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          String baseUrl = snapshot.data ?? "";
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 15, // Ajuster la taille du CircleAvatar
            child: CachedNetworkImage(
              imageUrl: "$baseUrl$avatar",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      30), // Ajuster la bordure du conteneur
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(
                color: Colors.blue,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //log("length users ${Users[0].email}");
    Locale currentLocale = Localizations.localeOf(context);
    // Extraire le premier div du contenu HTML
    String firstDivContent = '';
    RegExp regExp = RegExp(r'<div[^>]*>(.*?)<\/div>');
    Match? match = regExp.firstMatch(widget.note.content);
    if (match != null) {
      firstDivContent = match.group(1) ?? '';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        onTap: () {
          // Naviguer vers la page de détails de la note
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(note: widget.note),
            ),
          );
        },
        title: Html(
            data:
                firstDivContent), // Afficher le contenu du premier div dans le titre
        subtitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligner à gauche
            children: [
              Text(formatDate(widget.note.createdAt.toString(),
                  currentLocale)), // Formater et afficher la date
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      verticalOffset: 48,
                      height: 50,
                      textStyle: TextStyle(color: Colors.white),
                      message: widget.note.dataUser.labelData,
                      child: _buildAvatar(widget.note.dataUser.avatar.path,
                          widget.note.dataUser.labelData)),
                  _buildAvatars(Users, widget.note.sharedWith)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
