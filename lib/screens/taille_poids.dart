import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class TaillePoids extends StatefulWidget {
  TaillePoids({Key? key}) : super(key: key);

  static MaterialPage page() {
    return MaterialPage(
      name: "/taillePoids",
      key: const ValueKey("/taillePoids"),
      child: TaillePoids(),
    );
  }

  @override
  State<TaillePoids> createState() => _TaillePoidsState();
}

class _TaillePoidsState extends State<TaillePoids> {
  final _poidsController = TextEditingController();
  // 2
  final _tailleController = TextEditingController();
  // 3
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: kOtherColor,
  );

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final appStateManager =
        Provider.of<AppStateManager>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
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
                        "Quel est votre taille ?",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 200,
                        decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: borderSide)),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(vertical: 8),
                            hintText: 'Taille en cm',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: kPrimaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _tailleController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez insérer votre taille";
                            }
                            return null;
                          },
                        ),
                      ),
                      Bullet(
                        "Quel est votre poids ?",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 200,
                        decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: borderSide)),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            // contentPadding: EdgeInsets.symmetric(vertical: 16),
                            hintText: 'Poids en kg',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: kPrimaryColor,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _poidsController,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez insérer votre poids";
                            }
                            return null;
                          },
                        ),
                      ),
                      const Spacer(
                        flex: 4,
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  user.taille =
                                      num.tryParse(_tailleController.text) ??
                                          180;
                                  user.poids =
                                      num.tryParse(_poidsController.text) ?? 70;

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  double taille = user.taille!.toDouble();
                                  double poids = user.poids!.toDouble();
                                  prefs.setDouble("taille", taille);
                                  prefs.setDouble("poids", poids);
                                  stepsToDistanceFactor =
                                      0.414 * taille * 10e-5;
                                  stepsToCaloriesFactor =
                                      0.04 * (poids / (pow(taille * 10e-2, 2)));

                                  appStateManager.setIndex(6);
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
              ),
            );
          }),
        ),
      ),
    );
  }
}
