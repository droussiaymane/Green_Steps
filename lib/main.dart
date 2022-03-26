import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:app/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';


void main(){
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
        ChangeNotifierProvider(
          create: (_) => BackGroundWork(),
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




