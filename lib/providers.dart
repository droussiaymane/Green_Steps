import 'dart:math';

import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackGroundWork {
  int ntodaysCount = 0;
  List<String> nmoments = kmoments;

  Future<void> loadCounterValue(int rawValue, DateTime timeStamp) async {
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
      print("inside provider : $todaysCount");
      if (today == timeStamp.day) {
        if (rawValue < lastValue! - 30) {
          previouslastValue = 0;
          lastValue = rawValue;
        } else {
          if (rawValue < lastValue) {
            rawValue = lastValue;
          }
          previouslastValue = lastValue;
          lastValue = rawValue;
        }

        await prefs.setInt("lastValue", lastValue);
        await prefs.setInt("previouslastValue", previouslastValue);

        processedValue = lastValue - previouslastValue;

        valueAtTimeT(timeStamp, processedValue, moments);

        todaysCount = todaysCount! + processedValue;

        await prefs.setInt("todaysCount", todaysCount);
        ntodaysCount = todaysCount;
        await prefs.setStringList("moments", moments);
        nmoments = moments;

        try {
          pasHistorique = snapshot.get("pasHistorique") ?? [];
          if (pasHistorique.isEmpty) {
            print("there is a big big probleme with the code");
          } else {
            pasHistorique.first = pasHistorique.first.map((key, value) {
              return MapEntry(key, todaysCount!);
            });
            userDao.updateUserWithData({"pasHistorique": pasHistorique});
          }
        } catch (e) {
          print(e);
        }

      } else {
        today = timeStamp.day;

        await prefs.setInt("today", today);
        await prefs.setStringList("moments", kmoments);
        nmoments = kmoments;
        await prefs.setInt("todaysCount", 0);
        ntodaysCount = 0;

        nombrePasTotal = (snapshot.get("nombrePasTotal") ?? 0) + todaysCount!;

        Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
        pasHistorique =
            <dynamic>[tomorrow] + (snapshot.get("pasHistorique") ?? []);
        userDao.updateUserWithData(
            {"nombrePasTotal": nombrePasTotal, "pasHistorique": pasHistorique});
      }
    } else {
      await prefs.setInt("today", timeStamp.day);
      await prefs.setInt("previouslastValue", rawValue);
      await prefs.setInt("lastValue", rawValue);
      await prefs.setInt("todaysCount", 0);
      await prefs.setStringList("moments", kmoments);
      Map<String, int> tomorrow = {timeStamp.toString().substring(0, 10): 0};
      pasHistorique =
          <dynamic>[tomorrow] + (snapshot.get("pasHistorique") ?? []);
      userDao.updateUserWithData({"pasHistorique": pasHistorique});
    }
  }

  Future<Map<String, dynamic>?>? initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? todaysCount = prefs.getInt("todaysCount");
    List<String> moments = prefs.getStringList("moments") ?? kmoments;
    print("initialize()");
    print(todaysCount);
    print(moments);
    return {
      "moments": moments,
      "todaysCount": todaysCount,
    };
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
