import 'package:flutter/material.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class StaffEtudiant extends StatefulWidget {
  const StaffEtudiant({Key? key}) : super(key: key);
  static MaterialPage page() {
    return const MaterialPage(
      name: "/staffEtudiant",
      key: ValueKey("/staffEtudiant"),
      child: StaffEtudiant(),
    );
  }

  @override
  State<StaffEtudiant> createState() => _StaffEtudiant();
}

class _StaffEtudiant extends State<StaffEtudiant> {
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: Color(0xFF757a90),
  );

  bool staff = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final appStateManager = Provider.of<AppStateManager>(context);
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
            Bullet(
              "Vous êtes ?",
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Staff',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    leading: Radio<bool>(
                      activeColor: kPrimaryColor,
                      value: true,
                      groupValue: staff,
                      onChanged: (bool? value) {
                        setState(() {
                          staff = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Etudiant',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    leading: Radio<bool>(
                      activeColor: kPrimaryColor,
                      value: false,
                      groupValue: staff,
                      onChanged: (bool? value) {
                        setState(() {
                          staff = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
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
                      appStateManager.isStafff(staff);
                      if (staff) {
                        user.status = "Staff";
                        appStateManager.setIndex(3);
                      } else {
                        user.status = "Etudiant";
                        appStateManager.setIndex(2);
                      }
                    },
                    child: const Text("Suivant"),
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
