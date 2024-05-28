import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/detail/activityPage.dart';
import 'package:flutter_application_stage_project/screens/chat_page.dart';
import 'package:flutter_application_stage_project/screens/detail/infoPage.dart';
import 'package:provider/provider.dart';

class TeamFolderPage extends StatefulWidget {
  const TeamFolderPage({Key? key}) : super(key: key);

  @override
  State<TeamFolderPage> createState() => _TeamFolderPageState();
}

class _TeamFolderPageState extends State<TeamFolderPage> {
  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;

  late PageController _pageController;
  int _currentIndex = 0;

  List<Widget> stages = [
    InfoPage(),
    ActivityPage(),
    ChatPage(),
  ];

  List<String> stageTitles = [
    "Info",
    "Activity",
    "Chat",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);
    langueProvider = Provider.of<LangueProvider>(context);
    double availableScreenWidth = MediaQuery.of(context).size.width - 50;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Pop the current route
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              size: 28,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Riotters",
            ),
            Text(
              "Team folder",
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Storage",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("37/40 GB"),
                  ],
                ),
                Text(
                  "Upgrade",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                buildFileSizeChart(
                    " Blocked", Colors.blue, .3, availableScreenWidth),
                const SizedBox(
                  width: 2,
                ),
                buildFileSizeChart(
                    "In Progress", Colors.red, .25, availableScreenWidth),
                const SizedBox(
                  width: 2,
                ),
                buildFileSizeChart(
                    "Review", Colors.yellow, .20, availableScreenWidth),
                const SizedBox(
                  width: 2,
                ),
                buildFileSizeChart(
                    "", Colors.grey[200], .23, availableScreenWidth),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            height: 3,
            color: Colors.purple,
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < stages.length; i++)
                    InkWell(
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
                        width: 100, // Ajustez au besoin
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
                          child: Text(
                            stageTitles[i],
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ),
                ],
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

  Widget buildFileSizeChart(
      String title, Color? color, double widthPercentage, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * widthPercentage,
          height: 4,
          color: color,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
