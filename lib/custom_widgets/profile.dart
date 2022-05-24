import 'dart:math';

import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  BorderSide borderSide = const BorderSide(
    width: 1,
    style: BorderStyle.solid,
    color: kOtherColor,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context);

    return FutureBuilder<DocumentSnapshot>(
      // 2
      future: userDao.getUser(),
      // 3
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        User user = User.fromSnapshot(snapshot.data!);
        final _nomController = TextEditingController(text: user.nom);
        final _prenomController = TextEditingController(text: user.prenom);
        final _dateNaissanceController =
            TextEditingController(text: user.dateNaissance);
        final _tailleController =
            TextEditingController(text: user.taille?.toString());
        final _poidsController =
            TextEditingController(text: user.poids?.toString());
        final _cibleController = TextEditingController(text: cible.toString());

        return FocusTraversalGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () async {
              if (_formKey.currentState!.validate()) {
                Form.of(primaryFocus!.context!)!.save();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                double taille = user.taille!.toDouble();
                double poids = user.poids!.toDouble();
                prefs.setDouble("taille", taille);
                prefs.setDouble("poids", poids);
                prefs.setInt("cible", cible);
                print(cible);
                stepsToDistanceFactor = 0.414 * taille * 1e-5;
                stepsToCaloriesFactor =
                    0.04 * (poids / (pow(taille * 1e-2, 2)));
                userDao.updateUser(user);
              }
            },
            child: ListView(
              children: [
                const SizedBox(height: 40),
                /////
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("NOM :",
                      style: TextStyle(fontSize: 20, color: kSecondaryColor)),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      // isDense: true, // Added this
                      // contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      user.nom = value;
                    },
                    controller: _nomController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      return null;
                    },
                  ),
                ),
                /////
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "PRENOM :",
                    style: TextStyle(
                      fontSize: 20,
                      color: kSecondaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      user.prenom = value;
                    },
                    controller: _prenomController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      return null;
                    },
                  ),
                ),
                /////
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "DATE DE NAISSANCE :",
                    style: TextStyle(
                      fontSize: 20,
                      color: kSecondaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      user.dateNaissance = value;
                    },
                    controller: _dateNaissanceController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      return null;
                    },
                  ),
                ),
                /////
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "TAILLE :",
                    style: TextStyle(
                      fontSize: 20,
                      color: kSecondaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      user.taille = num.tryParse(value!);
                    },
                    controller: _tailleController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      if (num.tryParse(value) == null) {
                        return "Veuillez entrer un nombre";
                      }
                      return null;
                    },
                  ),
                ),
                /////
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "POIDS :",
                    style: TextStyle(
                      fontSize: 20,
                      color: kSecondaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      user.poids = num.tryParse(value!);
                    },
                    controller: _poidsController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      if (num.tryParse(value) == null) {
                        return "Veuillez entrer un nombre";
                      }
                      return null;
                    },
                  ),
                ),
                /////
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "NOMBRE DES PAS CIBLE :",
                    style: TextStyle(
                      fontSize: 20,
                      color: kSecondaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: borderSide,
                      ),
                    ),
                    onSaved: (String? value) {
                      cible = int.tryParse(value!)!;
                      print(cible);
                    },
                    controller: _cibleController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Ce champ ne doit pas être vide";
                      }
                      if (num.tryParse(value) == null) {
                        return "Veuillez entrer un nombre";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
