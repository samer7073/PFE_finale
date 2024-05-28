import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  double availableScreenWidth = 0;
  int selectedIndex = 0;
  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;
  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    langueProvider = Provider.of<LangueProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    availableScreenWidth = MediaQuery.of(context).size.width - 50;
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              const Text(
                "Recently updated",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  buildFileColumn('sketch', 'desktop', '.sketch'),
                  SizedBox(
                    width: availableScreenWidth * .03,
                  ),
                  buildFileColumn('sketch', 'mobile', '.sketch'),
                  SizedBox(
                    width: availableScreenWidth * .03,
                  ),
                  buildFileColumn('sketch', 'interaction', '.sketch'),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }

  Column buildFileColumn(String image, String filename, String extension) {
    return Column(
      children: [
        Container(
          width: availableScreenWidth * .31,
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(38),
          height: 110,
          child: Image.asset('assets/$image.jpeg'),
        ),
        const SizedBox(
          height: 15,
        ),
        RichText(
          text: TextSpan(
              text: filename,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: extension,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ]),
        ),
      ],
    );
  }
}
