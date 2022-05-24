import 'dart:math';

import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:app/route_generator.dart';
import 'package:app/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  //test a widget
  // runApp(MaterialApp(home: TaillePoids(),));

  //main app
  runApp(const MyApp());

  //mock values
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  // String toString(DateTime date) {
  //   return date.toString().substring(0, 10);
  // }

  // CollectionReference collection =
  //     FirebaseFirestore.instance.collection('users');
  // CollectionReference compcollection =
  //     FirebaseFirestore.instance.collection('competitions');

  // String competitionId = "jGfVQIseASlJkidPr0qJ";
  // DocumentReference competitionRefrence = compcollection.doc(competitionId);
  // String dateDeDebut = "2022-05-13";
  // String dateDeFin = "2022-05-18";

  // void addParticipant(DocumentSnapshot snapshot) {
  //   final user = User.fromSnapshot(snapshot);
  //   Map<String, dynamic> pasHistorique = {};
  //   DateTime start = DateTime.parse(dateDeDebut);
  //   DateTime fin = DateTime.parse(dateDeFin);
  //   while (start != fin) {
  //     pasHistorique[toString(start)] = 0;
  //     start = start.add(const Duration(days: 1));
  //   }
  //   pasHistorique[toString(fin)] = 0;
  //   Participant participant = Participant(
  //       user: user.reference!,
  //       prenom: user.prenom!,
  //       nom: user.nom!,
  //       sexe: user.sexe!,
  //       departement: user.departement!,
  //       poids: user.poids!,
  //       taille: user.taille!,
  //       rang: 0,
  //       pasHistorique: pasHistorique);
  //   competitionRefrence
  //       .collection("participants")
  //       .add(participant.toJson());
  // }

  // generatePasHistorique(int max) {
  //   List<Map<String, int>> pasHistorique = [];
  //   Random random = Random();

  //   for (var i = 12; i > 0; i--) {
  //     var j = i.toString().length == 1 ?  "0$i": "$i";
  //     pasHistorique.add({"2022-05-$j":random.nextInt(max)});
  //   }
  //    return pasHistorique;
  // }

  // var users = await collection.get();
  // List<DocumentSnapshot> usersList = users.docs;
  // for (var user in usersList) {
  //   // collection.doc(user.id).update({"activeCompetition":competitionRefrence,"pasHistorique":generatePasHistorique(4000)});
  //   addParticipant(user);
  // }
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
        Provider(
          create: (_) => MainProvider(),
          lazy: false,
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
