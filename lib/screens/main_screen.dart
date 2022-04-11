import 'dart:io';
import 'package:app/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:app/custom_widgets/custom_widgets.dart';
import 'package:app/models/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
    mainFunctionality();
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

  mainFunctionality() async {
    if (await Permission.activityRecognition.request().isGranted) {
      await initializeService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStateManager =
        Provider.of<AppStateManager>(context, listen: false);

    return Scaffold(
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

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async{
  print("start");
  BackGroundWork backGroundWork = BackGroundWork();
  await backGroundWork.initialize();
  service.invoke(
    'update',
    {
      "moments": backGroundWork.nmoments,
      "todaysCount": backGroundWork.ntodaysCount,
    },
  );
  void onStepCount(StepCount event) async {
    DateTime timeStamp = event.timeStamp;
    int rawValue = event.steps;
    await backGroundWork.loadCounterValue(rawValue, timeStamp);
    print(backGroundWork.ntodaysCount);
    print(backGroundWork.nmoments);
    service.invoke(
      'update',
      {
        "moments": backGroundWork.nmoments,
        "todaysCount": backGroundWork.ntodaysCount,
      },
    );
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Pas Journaliers : " + backGroundWork.ntodaysCount.toString(),
        content: "Restez actif!",
      );
    }
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  Stream<StepCount> stepCountStream = Pedometer.stepCountStream;
  stepCountStream.listen(onStepCount).onError(onStepCountError);
}
