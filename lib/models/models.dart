import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


num defaultValue = 0;

class User {
  String? nom;
  String? prenom;
  String? dateNaissance;
  String? sexe;
  String? departement;
  num? taille;
  num? poids;
  int? cible;
  String? email;
  int? nombrePasTotal;
  List<Map<DateTime,int>>? pasHistorique;
  DocumentReference? activeCompetition;
  String? token;

  DocumentReference? reference;

  User({
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.sexe,
    this.departement,
    this.taille,
    this.poids,
    this.cible,
    this.email,
    this.reference,
  });
  factory User.fromJson(Map<dynamic, dynamic> json) => User(
        nom: json['nom'] as String?,
        prenom: json['prenom'] as String?,
        dateNaissance: json['dateNaissance'] as String?,
        sexe: json['sexe'] as String?,
        departement: json['departement'] as String?,
        taille: (json['taille'] != null)
            ? num.tryParse(json['taille'] as String) ?? defaultValue
            : null,
        poids: (json['poids'] != null)
            ? num.tryParse(json['poids'] as String) ?? defaultValue
            : null,
        cible: (json['cible'] != null)
            ? int.tryParse(json['cible'] as String) ?? defaultValue.floor()
            : null,
        email: json['email'] as String?,
      );
  
  Map<String, dynamic> toJson() => <String, dynamic>{
        'nom': nom,
        'prenom': prenom,
        'dateNaissance': dateNaissance,
        'sexe': sexe,
        'departement': departement,
        'taille': taille?.toString(),
        'poids': poids?.toString(),
        'cible': cible?.toString(),
        'email': email,
        'nombrePasTotal' : nombrePasTotal,
        'pasHistorique' : pasHistorique,
        'activeCompetition' : activeCompetition,
        'token' : token,
      };
  Map<String, dynamic> toJsonForUpdate() => <String, dynamic>{
        'nom': nom,
        'prenom': prenom,
        'dateNaissance': dateNaissance,
        'sexe': sexe,
        'departement': departement,
        'taille': taille?.toString(),
        'poids': poids?.toString(),
        'cible': cible?.toString(),
        'email': email, 
      };
  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final user = User.fromJson(snapshot.data() as Map<String, dynamic>);
    user.reference = snapshot.reference;
    return user;
  }
}

class Message {
  final String text;
  final DateTime date;
  DocumentReference? reference;

  Message({
    required this.text,
    required this.date,
    this.reference,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) => Message(
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'date': date.toString(),
        'text': text,
      };

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final message = Message.fromJson(snapshot.data() as Map<String, dynamic>);
    message.reference = snapshot.reference;
    return message;
  }
}



  


class UserDao extends ChangeNotifier {
  final auth = FirebaseAuth.instance;

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('users');

  void saveUser(User user) {
    collection.doc(userId()).set(user.toJson());
    collection.doc(userId()).collection("messages").add({"date":DateTime.now().toString(),"text":"ici, vous pouvez recevoir des messages du pôle sport"});
  }

  void updateUserWithData(Map<String, dynamic> data) {
    collection.doc(userId()).update(data);
  }

  void updateUser(User user) {
    collection.doc(userId()).update(user.toJsonForUpdate());
  }

  Stream<DocumentSnapshot> getUserStream() {
    return collection.doc(userId()).snapshots();
  }

  Future<DocumentSnapshot> getUser() {
    return collection.doc(userId()).get();
  }

  
  //message Dao

  void saveMessage(Message message) {
    collection.doc(userId()).collection("messages").add(message.toJson());
  }

  Stream<QuerySnapshot> getMessageStream() {
    return collection.doc(userId()).collection("messages").snapshots();
  }
  

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  String? userId() {
    return auth.currentUser?.uid;
  }

  String? email() {
    return auth.currentUser?.email;
  }

  Future<bool> login(String email) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: '!0Abcdefg',
      );

      notifyListeners();
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<bool> signup(String email) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: '!0Abcdefg',
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // 4
      if (e.code == 'invalid-email') {
        print('invalid-email');
      }
      if (e.code == 'email-already-in-use') {
        print("email-already-in-use");
        return false;
      }
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<bool> logout() async {
    await auth.signOut();
    notifyListeners();
    return true;
  }

}


class CompetitionModel {
  final String name;
  final String discreption;
  List<dynamic> participants;
  final DateTime dateDeDebut;
  final DateTime dateDeFin;

  DocumentReference? reference;

  CompetitionModel(
    this.name,
    this.discreption,
    this.dateDeDebut,
    this.dateDeFin, {
    this.participants = const [],
  });

  void addParticipant(DocumentReference user) {
    participants.add(user);
    collection.doc(reference!.id).update({'participants': participants});
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'discreption': discreption,
        'date de debut': dateDeDebut,
        'date de fin': dateDeFin,
        'participants': participants,
      };
  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    final competition = CompetitionModel(
        json["name"] as String,
        json["discreption"] as String,
        json["date de debut"].toDate(),
        json["date de fin"].toDate(),
        participants: json["participants"] as List<dynamic>);
    return competition;
  }
  factory CompetitionModel.fromSnapshot(DocumentSnapshot snapshot) {
    final competition =
        CompetitionModel.fromJson(snapshot.data() as Map<String, dynamic>);
    competition.reference = snapshot.reference;
    return competition;
  }

  static final CollectionReference collection =
      FirebaseFirestore.instance.collection('competitions');
  
  static Stream<QuerySnapshot> getCompetitionsStream() {
    return collection.orderBy("date de fin", descending: true).snapshots();
  }
}




class AppStateManager extends ChangeNotifier {
  // 2
  bool initialized = false;
  // 3
  bool loggedIn = false;

  bool isStaff = false;
  void isStafff(bool value) {
    isStaff = value;
    notifyListeners();
  }

  int index = -1;
  void setIndex(int i) {
    index = i;
    notifyListeners();
  }

  bool inCompetition = false;
  void toCompetition(bool value) {
    inCompetition = value;
    notifyListeners();
  }

  void logInOut(UserDao userDao) {
    loggedIn = userDao.isLoggedIn();
    print("#############################################");
    print(loggedIn);
    notifyListeners();
  }

  Future<bool> initializeApp() async {
    
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    initialized = true;
    notifyListeners();
    return true;
  }
}


