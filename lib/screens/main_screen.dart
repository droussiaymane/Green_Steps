import 'dart:io';

import 'package:app/custom_widgets/custom_widgets.dart';
import 'package:app/models/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import '../providers.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static MaterialPage page() {
    return const MaterialPage(
      name: '/mainScreen',
      key: ValueKey('/mainScreen'),
      child: MainScreen(),
    );
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  List<Widget> pages = const [
    Historique(),
    MainPage(),
    Text("Map"),
    MessageList(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
    setupRecievingMessages();
    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    void _handleMessage(RemoteMessage message) {
      if (message.data['type'] == 'chat') {
        _selectedIndex = 3;
      }
    }

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void setupRecievingMessages() {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      _fcm.requestPermission();
    }
  }

  asyncMethod() async {
    if (await Permission.activityRecognition.request().isGranted) {
      Stream<StepCount> stepCountStream;
      var backGroundWork = Provider.of<BackGroundWork>(context, listen: false);
      void onStepCount(StepCount event) async {
        print(event);
        DateTime timeStamp = event.timeStamp;
        int rawValue = event.steps;
        print("rawValue :$rawValue");
        backGroundWork.loadCounterValue(rawValue, timeStamp);
      }

      void onStepCountError(error) {
        print('onStepCountError: $error');
      }

      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      Workmanager().registerPeriodicTask(
        "1",
        "Task",
        frequency: const Duration(minutes: 15),
      );
      stepCountStream = Pedometer.stepCountStream;
      stepCountStream.listen(onStepCount).onError(onStepCountError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateManager =
        Provider.of<AppStateManager>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    var backGroundWork = Provider.of<BackGroundWork>(context, listen: false);
    return Scaffold(
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       child: const Icon(
      //         Icons.logout,
      //       ),
      //       onPressed: () async {
      //         await userDao.logout();
      //         appStateManager.logInOut(userDao);
      //       },
      //     ),
      //     SizedBox(
      //       width: 10.0,
      //     ),
      //     FloatingActionButton(
      //       child: const Icon(Icons.exposure_zero),
      //       onPressed: () async {
      //         await backGroundWork.zero();
      //       },
      //     ),
      //   ],
      // ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                _selectedIndex = 3;
                setState(() {});
              },
              icon: const Icon(
                Icons.message,
              ),
            ),
            IconButton(
              onPressed: () {
                appStateManager.toCompetition(true);
              },
              icon: const Icon(Icons.run_circle),
            ),
            IconButton(
              onPressed: () {
                _selectedIndex = 4;
                setState(() {});
              },
              icon: const Icon(
                Icons.person,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: (_selectedIndex < 3) ? _selectedIndex : 1,
        onTap: _onItemTapped,
      ),
    );
  }
}

AppBar appBar = AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.message,
        ),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.home),
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.person,
        ),
      ),
    ],
  ),
);

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(
        "#####################################################################################################################################################################################################################");
    print("I am in the callbackDispatcher");
    return BackGroundWork().loadCounterValueJob();
  });
}
