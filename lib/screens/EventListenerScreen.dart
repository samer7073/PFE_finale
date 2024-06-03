import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mercure_client/mercure_client.dart';

import '../services/sharedPreference.dart';

class MercureEventsPage extends StatefulWidget {
  const MercureEventsPage({Key? key}) : super(key: key);

  @override
  _MercureEventsPageState createState() => _MercureEventsPageState();
}

class _MercureEventsPageState extends State<MercureEventsPage> {
  late Mercure _mercure;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    _initializeMercure();
  }

  void _initializeMercure() async {
    try {
      print('Initializing Mercure...'); // Ajoutez ce log
      final token = await SharedPrefernce.getToken("token");
      print('Retrieved token: $token'); // Ajoutez ce log

      if (token == null) {
        print('Token is null, cannot initialize Mercure'); // Ajoutez ce log
        return;
      }

      // Initialize Mercure object
      _mercure = Mercure(
        url: 'https://spheremercuredev.cmk.biz:4443/.well-known/mercure',
        token:
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJtZXJjdXJlIjp7InN1YnNjcmliZSI6WyIvY2hhdC9kZXYvdXNlci80MjIiLCIvbm90aWZpY2F0aW9uL2Rldi91c2VyLzliZDY1YzBkLThiMWMtNGE0YS05YzFhLTJlZDU2ZTZjNTc3NiIsIi8ud2VsbC1rbm93bi9tZXJjdXJlL3N1YnNjcmlwdGlvbnMve3RvcGljfXsvc3Vic2NyaWJlcn0iXSwicGF5bG9hZCI6eyJ1c2VyX3VpZCI6IjliZDY1YzBkLThiMWMtNGE0YS05YzFhLTJlZDU2ZTZjNTc3NiIsImRhdGV0aW1lIjoiMjAyNC0wNi0wM1QxNTo1ODo1Ni4wMzI5OTlaIn19fQ.VA2LYoy24WnDM6nEXue3z2do3XKV5ID3gY6WIgdjJryUII9fIEketOfZpoLtiSn4c8czbtkZI5teflm6lz01xxQAtroNNy6YOTuLFowSxOUQU1NhvpBWDZGLprWzImggmZtOe9LFikjvwSg-rFU5202TMaGYZSihhTNMMhmoyURHJdXxQUSd_29jUt_eJe5zkwrOi1ikoVhN6GIme6_JWb0XCyspOwDiM4byymlB_iZJOlQtbSM_nTBm3RMlnJ_6tPBNoCBgfMIMbHaebfNjs3u7aRxfnOabJdf4PW5Hu2vPC3rUvEcShZ3ZOhGQM2MsiHpepRBEL7akSDLwpTbpsSjNzjQN0pXH5qD9-IYMSfpKnmEOwY4Q9QmD2iyMcIFFEq1wpWBYtan5ZzEeiRbN9-8BIRWqrGnqMYNcx1mjTGddYH9pUWe2UAOl33SGOpjpTZ66C1QXvA_NynZVZpyVDo3Q7yaXnJp4xCtyH9HU52aSQ0wdBGQhXPpvmTUkLA5zE9Q5kxz2-Y5doQ91QOI_Q0HWcJN4SFOTaY6fTB1fGC-3VkuYAU_rrlr8xfPbIhq9SLuBa9u8RCnM9cwX8ORBGPXLiFvpiE8mo-yM_O0S-QUaKFnisQZQ5p_wEJNd0l9s_z633ZAbItdm0-gLqAPVLM2hEV150dJXy243bG5BuZA",
        topics: [
          '/chat/dev/user/422',
          '/notification/dev/user/9bd65c0d-8b1c-4a4a-9c1a-2ed56e6c5776'
        ],
      );

      _mercure.listen((event) {
        if (event.data.contains('task')) {
          print('Received event with task: ${event.data}'); // Ajoutez ce log
          setState(() {
            _events.add(event.data);
            print(
                'New Mercure event with task: ${event.data}'); // Ajoutez ce log
          });
        }
      });
      print('Mercure connection established'); // Ajoutez ce log
    } catch (error) {
      print('Error initializing Mercure: $error'); // Ajoutez ce log
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mercure Events'),
      ),
      body: _events.isEmpty
          ? Center(child: Text('No events yet'))
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[index]),
                );
              },
            ),
    );
  }
}
