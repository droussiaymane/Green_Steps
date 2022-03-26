import 'dart:math';

import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BackGroundWork with ChangeNotifier {
  int ntodaysCount = 0;
  List<String> nmoments = kmoments;

  Future<bool> help() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("1");
      int counter = prefs.getInt("counter") ?? 0;
      print("2");
      counter++;
      print("3");
      await prefs.setInt("counter", counter);
      print("4");
    } catch (err) {
      print((err.toString()));
      throw Exception(err);
    }

    return true;
  }
  //this one to test an issue with plugin not found

  Future<bool> loadCounterValueJob() async {
    try {
    print(await Permission.activityRecognition.isGranted);
    Stream<StepCount> stepCountStream = Pedometer.stepCountStream;
    StepCount rawStep = await stepCountStream.first;
    DateTime timeStamp = rawStep.timeStamp;
    int rawValue = rawStep.steps;
    print(timeStamp);
    print(rawValue);
    }catch (err) {
      print((err.toString()));
      throw Exception(err);
    }

    return true;
  }
  //to get the for real loadCounterValueJob replace the last two print with await loadCounterValueWithoutNotify

  Future<bool> loadCounterValueJob1() async {
    DateTime now = DateTime.now();
    await loadCounterValueWithoutNotify(1000, now);
    return true;
  }
  // this the tasliki loadCounterValueJob

  Future<void> loadCounterValueWithoutNotify(int rawValue, DateTime timeStamp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Firebase.initializeApp();

    UserDao userDao = UserDao();

    DocumentSnapshot snapshot = await userDao.getUser();

    int? processedValue;
    int? nombrePasTotal;
    var pasHistorique;

    if (prefs.containsKey("today")) {
      int? today = prefs.getInt("today");
      int? lastValue = prefs.getInt("lastValue");
      int? previouslastValue = prefs.getInt("previouslastValue");
      int? todaysCount = prefs.getInt("todaysCount");
      List<String> moments = prefs.getStringList("moments") ?? kmoments;

      if (today == timeStamp.day) {
        //this code below is tsliki
        processedValue = Random().nextInt(100);
        previouslastValue = lastValue;
        lastValue = previouslastValue! + processedValue;
        await prefs.setInt("lastValue", lastValue);
        await prefs.setInt("previouslastValue", previouslastValue);
        valueAtTimeT(timeStamp, processedValue, moments);

        todaysCount = todaysCount! + processedValue;
        pasHistorique = snapshot.get("pasHistorique") ?? [];
        
        if (pasHistorique!.isEmpty) {
          print("there is a big big probleme with the code");
        } else {
          pasHistorique.first = pasHistorique.first.map((key,value){return MapEntry(key,value + todaysCount!);});
          userDao.updateUserWithData(
            {"pasHistorique": pasHistorique}); 
        }
        await prefs.setInt("todaysCount", todaysCount);
        await prefs.setStringList("moments", moments);
        //end of tasliki code

      } else {
        nombrePasTotal = (snapshot.get("nombrePasTotal") ?? 0) + todaysCount!;

        today = timeStamp.day;
        Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
        pasHistorique = [tomorrow] + (snapshot.get("pasHistorique") ?? []) ;
        userDao.updateUserWithData(
            {"nombrePasTotal": nombrePasTotal, "pasHistorique": pasHistorique});

        await prefs.setInt("today", today);
        await prefs.setStringList("moments", kmoments);
        await prefs.setInt("todaysCount", 0);
      }
    } else {
      await prefs.setInt("today", timeStamp.day);
      await prefs.setInt("previouslastValue", rawValue);
      await prefs.setInt("lastValue", rawValue);
      await prefs.setInt("todaysCount", 0);
      await prefs.setStringList("moments", kmoments);
      Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
     pasHistorique = [tomorrow] + (snapshot.get("pasHistorique") ?? []) ;
      userDao.updateUserWithData(
            {"pasHistorique": pasHistorique});
    }
  }
  //you need to change the tesliki part of this function when you find a solution to the probleme

  Future<void> loadCounterValue(int rawValue, DateTime timeStamp) async {
    print("########################################################################################################################################################################");
    print("I am her inside load");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Firebase.initializeApp();

    UserDao userDao = UserDao();

    DocumentSnapshot snapshot = await userDao.getUser();

    int? processedValue;
    int? nombrePasTotal;
    List<dynamic> pasHistorique;

    if (prefs.containsKey("today")) {
      int? today = prefs.getInt("today");
      int? lastValue = prefs.getInt("lastValue");
      int? previouslastValue = prefs.getInt("previouslastValue");
      int? todaysCount = prefs.getInt("todaysCount");
      List<String> moments = prefs.getStringList("moments") ?? kmoments;

      if (today == timeStamp.day) {
        print("rawValue :$rawValue");
        print("lastValue :$lastValue");
        print("previouslastValue :$previouslastValue");
        if (rawValue < lastValue! - 30) {
          //you need to think more about this one
          print(-30);
          previouslastValue = 0;
          lastValue = rawValue;
        } else {

          if (rawValue < lastValue){
            print("<");
            rawValue = lastValue;
          }
          previouslastValue = lastValue;
          lastValue = rawValue;
        }
        print("after change :");
        print("lastValue :$lastValue");
        print("previouslastValue :$previouslastValue");
        await prefs.setInt("lastValue", lastValue);
        await prefs.setInt("previouslastValue", previouslastValue);

        processedValue = lastValue - previouslastValue;
        print("processedValue :$processedValue");
        valueAtTimeT(timeStamp, processedValue, moments);
        print("todaysCount :$todaysCount");
        todaysCount = todaysCount! + processedValue;
        print("todaysCount :$todaysCount");
        
        pasHistorique = snapshot.get("pasHistorique") ?? [];
        if (pasHistorique.isEmpty) {
          print("there is a big big probleme with the code");
        } else {
          pasHistorique.first = pasHistorique.first.map((key,value){return MapEntry(key,todaysCount!);});
          userDao.updateUserWithData(
            {"pasHistorique": pasHistorique}); 
        }
        
        await prefs.setInt("todaysCount", todaysCount);
        ntodaysCount = todaysCount;
        await prefs.setStringList("moments", moments);
        nmoments = moments;
      } else {
        
        nombrePasTotal = (snapshot.get("nombrePasTotal") ?? 0) + todaysCount!;
        
        today = timeStamp.day;
        Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
        pasHistorique = <dynamic>[tomorrow] + (snapshot.get("pasHistorique") ?? []) ;
        userDao.updateUserWithData(
            {"nombrePasTotal": nombrePasTotal, "pasHistorique": pasHistorique});
        await prefs.setInt("today", today);
        await prefs.setStringList("moments", kmoments);
        nmoments = kmoments;
        await prefs.setInt("todaysCount", 0);
        ntodaysCount = 0;
      }
    } else {
      await prefs.setInt("today", timeStamp.day);
      await prefs.setInt("previouslastValue", rawValue);
      await prefs.setInt("lastValue", rawValue);
      await prefs.setInt("todaysCount", 0);
      await prefs.setStringList("moments", kmoments);
      Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
      pasHistorique = <dynamic>[tomorrow] + (snapshot.get("pasHistorique") ?? []) ;
      userDao.updateUserWithData(
            {"pasHistorique": pasHistorique});
    }
    notifyListeners();
  }

  Future<void> zero() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("todaysCount", 0);
    ntodaysCount = 0;
    await prefs.setStringList("moments", kmoments);
    nmoments = kmoments;
    notifyListeners();
  }

  Future<int> getBackGroundCounterValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counterValue = prefs.getInt('todaysCount') ?? 0;
    return counterValue;
  }

  Future<List<String>> getBackGroundGraphValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> moments = prefs.getStringList("moments") ?? kmoments;
    return moments;
  }
}
//the end of the BackGroundWork class

//a simple function use to create the moments list
void valueAtTimeT(
    DateTime timeStamp, int processedValue, List<String> moments) {
  int pos = timeStamp.hour;
  int prevHourValue = int.parse(moments[pos].substring(2));
  int newHourValue = prevHourValue + processedValue;
  moments[pos] = moments[pos].substring(0, 2) + newHourValue.toString();
}
