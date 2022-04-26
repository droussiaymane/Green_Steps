import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);
  static MaterialPage page() {
    return const MaterialPage(
      name: "/welcome",
      key: ValueKey("/welcome"),
      child: Welcome(),
    );
  }

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late Image um6p;
  late Image logo;

  @override
  void initState() {
    super.initState();
    um6p = Image.asset("assets/icons/um6p.png", scale: 20,);
    logo = Image.asset("assets/icons/new LOGO.png",scale: 7,);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await precacheImage(um6p.image, context);
    await precacheImage(logo.image, context);
    await Provider.of<AppStateManager>(context, listen: false).initializeApp();
    await Provider.of<MainProvider>(context, listen: false).initialize();
    final userDao = Provider.of<UserDao>(context, listen: false);
    Provider.of<AppStateManager>(context, listen: false).logInOut(userDao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                um6p,
                logo,
              ],
            ),
          ),
          Center(
            child: Text('Green Steps',
                style: Theme.of(context).textTheme.headline4),
          ),
        ],
      ),
    );
  }
}
