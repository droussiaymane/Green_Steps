import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:app/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // print("I am in main");
  // print(prefs.containsKey('todaysCount'));
  // int counterValue = prefs.getInt('todaysCount') ?? 0;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouter _appRouter;
  final appStateManager = AppStateManager();

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      appStateManager: appStateManager,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => MainProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider<UserDao>(
          create: (_) => UserDao(),
        ),
        ChangeNotifierProvider<AppStateManager>(
          create: (_) => appStateManager,
        ),
        Provider<User>(
          create: (_) => User(),
        )
      ],
      child: MaterialApp(
        theme: lightThemeData(context),
        debugShowCheckedModeBanner: false,
        title: 'Green Steps',
        home: Router(
          routerDelegate: _appRouter,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
