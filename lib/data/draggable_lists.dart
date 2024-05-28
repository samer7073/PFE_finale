// ignore_for_file: prefer_const_constructors

import '../models/draggable_list.dart';

List<DraggableList> allLists = [
  DraggableList(
    //header: 'To Do',
    items: [
      DraggableListItem(
          title: 'Problème de connexion', urlImage: "assets/face4.jpg"),
      DraggableListItem(
          title: "Problème d'impression ", urlImage: "assets/face3.jpg"),
      DraggableListItem(title: "Demande d'accès", urlImage: "assets/face2.jpg"),
    ],
  ),
  DraggableList(
    //header: "In Progress",
    items: [
      DraggableListItem(
          title: 'Demande de formation', urlImage: "assets/face5jpg.jpg"),
      DraggableListItem(title: 'Melon', urlImage: "assets/face3.jpg"),
      DraggableListItem(
          title: 'Problème matériel', urlImage: "assets/face2.jpg"),
    ],
  ),
  DraggableList(
   // header: 'Testing',
    items: [
      DraggableListItem(
          title: 'Demande de support technique ', urlImage: "assets/face2.jpg"),
      DraggableListItem(
          title: "Demande d'information", urlImage: "assets/face3.jpg"),
      DraggableListItem(
          title: 'Demande de configuration', urlImage: "assets/img3.jpeg"),
    ],
  ),
  DraggableList(
    //header: 'Done',
    items: [
      DraggableListItem(
          title: 'Demande de support technique ', urlImage: "assets/img2.jpeg"),
      DraggableListItem(
          title: "Demande d'information", urlImage: "assets/img1.jpeg"),
      DraggableListItem(
          title: 'Demande de configuration', urlImage: "assets/face5jpg.jpg"),
    ],
  ),
];
