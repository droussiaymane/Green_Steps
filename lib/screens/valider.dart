import 'package:app/models/models.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class Valider extends StatelessWidget {
  Valider({Key? key}) : super(key: key);
  static MaterialPage page() {
    return MaterialPage(
      name: "/valider",
      key: ValueKey("/Valider"),
      child: Valider(),
    );
  }

  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final appStateManager =
        Provider.of<AppStateManager>(context, listen: false);
    final user = Provider.of<User>(context);
    final userDao = Provider.of<UserDao>(context);
    return Scaffold(
      body: Center(
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
              flex: 2,
            ),
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  // ignore: prefer_const_constructors
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Code de vérification',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: 250,
              child: const Text(
                "Veuillez vérifier votre boite mail, pour avoir le code de vérification.",
                style: TextStyle(
                  color: Color(0xff5364a6),
                ),
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: kPrimaryColor,
              ),
              onPressed: () async{
                await userDao.signup(user.email as String);

                appStateManager.setIndex(1);
              },
              child: const Text("Valider"),
            ),
            const Spacer(
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}
