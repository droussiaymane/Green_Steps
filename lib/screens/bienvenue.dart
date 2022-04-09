import 'package:app/models/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//this is foregroundService branch

class Bienvenue extends StatefulWidget {
  Bienvenue({Key? key}) : super(key: key);
  static MaterialPage page() {
    return MaterialPage(
      name: "/bienvenue",
      key: ValueKey("/bienvenue"),
      child: Bienvenue(),
    );
  }
  @override
  State<Bienvenue> createState() => _BienvenueState();
}

class _BienvenueState extends State<Bienvenue> {
  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    if (mounted){
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final user = Provider.of<User>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    String? token = await _fcm.getToken();
    user.token = token;
    _fcm.subscribeToTopic("all");
    await userDao.login(user.email as String);
    
    userDao.saveUser(user);
    
    Provider.of<AppStateManager>(context, listen: false).logInOut(userDao);
    Provider.of<AppStateManager>(context, listen: false).setIndex(-1);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Image.asset(
              'assets/icons/um6p.png',
              scale: 10,
            ),
            const Spacer(
              flex: 1,
            ),
            const Text("Bienvenue à"),
            const SizedBox(height: 16,),
            Text('Green Steps', style: Theme.of(context).textTheme.headline4),
            const Spacer(
              flex: 2,
            ),
            const Icon(
              Icons.check_circle_outline,
              size: 120,
            ),
            const Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/new LOGO.png',
                    scale: 8,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
