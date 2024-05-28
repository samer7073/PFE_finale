import 'package:flutter/material.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticketListRow.dart';

class AppflowyBoard extends StatefulWidget {
  @override
  _AppflowyBoardState createState() => _AppflowyBoardState();
}

class _AppflowyBoardState extends State<AppflowyBoard> {
  final AppFlowyBoardController controller = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
    },
  );

  @override
  void initState() {
    final group1 = AppFlowyGroupData(
      id: "To Do",
      items: [
       
        TextItem("Card 2"),
      ],
      name: 'ccc',
    );
    final group2 = AppFlowyGroupData(
      id: "In Progress",
      items: [
        TextItem("Card 3"),
        TextItem("Card 4"),
      ],
      name: 'ddd',
    );

    final group3 = AppFlowyGroupData(
      id: "Done",
      items: [],
      name: 'bbb',
    );

    controller.addGroup(group1);
    controller.addGroup(group2);
    controller.addGroup(group3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppFlowy Board Demo'),
      ),
      body: Center(
        child: AppFlowyBoard(
          config: AppFlowyBoardConfig(
              headerPadding: EdgeInsets.all(10),
              cardPadding: EdgeInsets.all(10),
              cornerRadius: 5,
              groupBackgroundColor: Colors.grey.shade200),
          headerBuilder: (context, groupData) {
            // You can customize the look of each group's header here.
            return Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                groupData.id!,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            );
          },
          footerBuilder: (context, groupData) {
            if (groupData.id == "Done") {
              // Only show the done button for the "Done" column
              return IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {},
              );
            } else {
              // Show an empty container for other columns
              return Container();
            }
          },
          // En-tête personnalisé

          controller: controller,
          cardBuilder: (context, group, groupItem) {
            final textItem = groupItem as TextItem;
            return AppFlowyGroupCard(
              decoration: BoxDecoration(color: Colors.amber),
              margin: EdgeInsets.all(10),
              key: ObjectKey(textItem),
              child: Text(textItem.s),
            );
          },
          groupConstraints: const BoxConstraints.tightFor(width: 240),
        ),
      ),
    );
  }
}

class TextItem extends AppFlowyGroupItem {
  final String s;
  TextItem(this.s);

  @override
  String get id => s;
}
