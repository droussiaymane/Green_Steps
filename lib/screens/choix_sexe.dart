import 'package:flutter/material.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class ChoixSexe extends StatefulWidget {
  ChoixSexe({Key? key}) : super(key: key);
  static MaterialPage page() {
    return MaterialPage(
      name: "/choixSexe",
      key: ValueKey("/choixSexe"),
      child: ChoixSexe(),
    );
  }
  @override
  State<ChoixSexe> createState() => _ChoixSexeState();
}

class _ChoixSexeState extends State<ChoixSexe> {
  String sexe = '';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final appStateManager = Provider.of<AppStateManager>(context, listen: false);
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
              flex: 2,
            ),
            Bullet(
              "Quel est votre sexe ?",
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
            const Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  value: "femelle",
                  groupValue: sexe,
                  onTap: () {
                    sexe = "femelle";
                    setState(() {});
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/icons/female.png',
                        scale: 10,
                      ),
                      const Text("Femelle"),
                    ],
                  ),
                ),
                CustomButton(
                  value: "male",
                  onTap: () {
                    sexe = "male";
                    setState(() {});
                  },
                  groupValue: sexe,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/icons/male.png',
                        scale: 20,
                      ),
                      const Text("Male"),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/icons/new LOGO.png',
                    scale: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                    ),
                    onPressed: () {
                      user.sexe = sexe;
                      appStateManager.setIndex(5);
                    },
                    child: Text("Suivant"),
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

class CustomButton extends StatefulWidget {
  final Widget child;
  void Function()? onTap;
  String value;
  String groupValue;
  CustomButton(
      {Key? key,
      required this.child,
      this.onTap,
      required this.value,
      required this.groupValue})
      : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: kPrimaryColor,
  );
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: (widget.value == widget.groupValue) ? Border.fromBorderSide(borderSide) : null,
        ),
        padding: const EdgeInsets.all(8),
        height: 150,
        width: 80,
        child: widget.child,
      ),
    );
  }
}
