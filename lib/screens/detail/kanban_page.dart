// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage1.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage2.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage3.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage4.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage5.dart';
import 'package:flutter_application_stage_project/core/constants/shared/stages/stage6.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';

import 'package:provider/provider.dart';

import '../CustomSearchDelegate.dart';
import '../notifications/notifications_page.dart';
import '../ticket/addTicket.dart';

class KanbanPage1 extends StatefulWidget {
  @override
  _KanbanPage1State createState() => _KanbanPage1State();
}

class _KanbanPage1State extends State<KanbanPage1> {
  late ThemeProvider themeProvider;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _pageController = PageController(initialPage: _currentIndex);
  }

  late PageController _pageController;
  int _currentIndex = 0;
  int selectedIndex = 0;

  List<Widget> stages = [
    Stage1Content(),
    Stage2Content(),
    Stage3Content(),
    Stage4Content(),
    Stage5Content(),
    Stage6Content(),
  ];

  List<String> stageTitles = [
    "To Do",
    "Done",
    "Blocked",
    "Rejected",
    "Review",
    "In Progress",
  ];
  List<String> stageTitles2 = [
    "5",
    "20",
    "30",
    "40",
    "50",
    "10",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTicket(
                      family_id: "3",
                      titel: "Affaire",
                    )),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: CustomSearchDelegate("6"));
              },
              icon: Icon(
                Icons.search,
                size: 30,
              )),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return NotificationsPage();
                },
              ));
            },
            icon: Icon(
              Icons.notifications_none_sharp,
              size: 30,
            ),
          )
        ],
        centerTitle: true,
        title: Text("Sphere Board"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < stages.length; i++)
                      InkWell(
                        splashColor: Colors.white,
                        overlayColor: MaterialStateProperty.all(Colors.white),
                        onTap: () {
                          setState(() {
                            _currentIndex = i;
                            _pageController.animateToPage(
                              _currentIndex,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: themeProvider.isDarkMode == true
                                ? _currentIndex == i
                                    ? Colors.deepPurple[100]
                                    : Colors.black
                                : _currentIndex == i
                                    ? Colors.deepPurple[100]
                                    : Colors.white,
                          ),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: stageTitles2[i],
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  TextSpan(
                                    text: '\n',
                                  ),
                                  TextSpan(
                                    text: stageTitles[i],
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: stages,
            ),
          ),
        ],
      ),
    );
  }
}
