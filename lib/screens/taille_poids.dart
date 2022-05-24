import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
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

  final ValueNotifier<List<double>> imc =
      ValueNotifier<List<double>>([double.infinity, 0]);

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
                        width: 300,
                        decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: borderSide)),
                        child: TextFormField(
                          onChanged: (value) {
                            imc.value[0] =
                                double.tryParse(value) ??
                                    double.infinity;
                            if (imc.value[0].isNegative){
                              imc.value[0] =double.infinity;
                            }
                          },
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
                            if(double.tryParse(value) == null){
                              return "La taille doit être un nombre positif";
                            }
                            if(double.tryParse(value)!.isNegative){
                              return "La taille doit être un nombre positif";
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
                        width: 300,
                        decoration: BoxDecoration(
                            border: Border.symmetric(horizontal: borderSide)),
                        child: TextFormField(
                          onChanged: (value) {
                            imc.value[1] =
                                double.tryParse(value) ?? 0;
                            if (imc.value[1].isNegative){
                              imc.value[1] = 0;
                            }
                          },
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
                            if(double.tryParse(value) == null){
                              return "Le poids doit être un nombre positif";
                            }
                            if(double.tryParse(value)!.isNegative){
                              return "Le poids doit être un nombre positif";
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: ValueListenableBuilder<List<num?>>(
                          valueListenable: imc,
                          builder: (context, value, child) {
                            print(value[1]);
                            print(value[0]);
                            double imc = value[1]! / pow(value[0]! * 1e-2, 2);
                            print("imc : $imc");
                            double imcInterval = 0;

                            if (imc == 0) {
                              imcInterval = 0;
                            } else if (imc >= 40) {
                              imcInterval = 45;
                            } else if (imc > 29.9) {
                              imcInterval = 35;
                            } else if (imc > 24.9) {
                              imcInterval = 25;
                            } else if (imc >= 18.5) {
                              imcInterval = 15;
                            } else if (imc > 0) {
                              imcInterval = 5;
                            }

                            print("imcInterval : $imcInterval");
                            return RadialGauge(
                              imc: imcInterval,
                            );
                          },
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  user.taille =
                                      num.tryParse(_tailleController.text);
                                  user.poids =
                                      num.tryParse(_poidsController.text);

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  double taille = user.taille!.toDouble();
                                  double poids = user.poids!.toDouble();
                                  setState(() {});
                                  prefs.setDouble("taille", taille);
                                  prefs.setDouble("poids", poids);
                                  stepsToDistanceFactor =
                                      0.414 * taille * 1e-5;
                                  stepsToCaloriesFactor =
                                      0.04 * (poids / (pow(taille * 1e-2, 2)));

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

class RadialGauge extends StatelessWidget {
  double imc;
  RadialGauge({required this.imc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("rebuilt RadialGauge");
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          showLabels: false,
          canScaleToFit: true,
          radiusFactor: 1.3,
          startAngle: 180,
          endAngle: 0,
          ranges: <GaugeRange>[
            GaugeRange(
              label: "Maigreur",
              startWidth: 50,
              endWidth: 50,
              startValue: 0,
              endValue: 10,
              color: Colors.blue,
            ),
            GaugeRange(
              label: "Normal",
              startWidth: 50,
              endWidth: 50,
              startValue: 10,
              endValue: 20,
              color: Colors.green,
            ),
            GaugeRange(
              label: "Surpoids",
              startWidth: 50,
              endWidth: 50,
              startValue: 20,
              endValue: 30,
              color: Colors.orangeAccent,
            ),
            GaugeRange(
              label: "Obésité",
              startWidth: 50,
              endWidth: 50,
              startValue: 30,
              endValue: 40,
              color: Colors.deepOrangeAccent,
            ),
            GaugeRange(
              label: "Obésité\nmassive",
              startWidth: 50,
              endWidth: 50,
              startValue: 40,
              endValue: 50,
              color: Colors.red,
            )
          ],
          minimum: 0,
          maximum: 50,
          pointers: <GaugePointer>[
            NeedlePointer(
              value: imc,
              enableAnimation: true,
            )
          ],
        ),
      ],
    );
  }
}
