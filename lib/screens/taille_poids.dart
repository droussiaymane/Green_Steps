import 'package:flutter/material.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class TaillePoids extends StatefulWidget {
  TaillePoids({Key? key}) : super(key: key);

  static MaterialPage page() {
    return MaterialPage(
      name: "/taillePoids",
      key: ValueKey("/taillePoids"),
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
    color: kPrimaryColor,
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
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Taille en cm',
                          border: OutlineInputBorder(
                            borderSide: borderSide,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        controller: _tailleController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez insérer votre taille";
                          }
                          return null;
                        },
                      ),
                      Bullet(
                        "Quel est votre poids ?",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Poids en kg',
                          border: OutlineInputBorder(
                            borderSide: borderSide,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        controller: _poidsController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Veuillez insérer votre poids";
                          }
                          return null;
                        },
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
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  user.taille =
                                      num.tryParse(_tailleController.text) ??
                                          180;
                                  user.poids =
                                      num.tryParse(_poidsController.text) ?? 70;

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
