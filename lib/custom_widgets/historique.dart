import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import '../constants.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

///******************************************************************* */

num fmoyenne(List measure) {
  int n = measure.length;
  num avg = 0;
  for (var i = 0; i < n; i++) {
    avg += measure[i];
  }
  avg = avg / n;
  return avg;
}

num ftotal(List measure) {
  int n = measure.length;
  num sum = 0;
  for (var i = 0; i < n; i++) {
    sum += measure[i];
  }
  return sum;
}

int size(String timeStamp) {
  switch (timeStamp) {
    case "week":
      return 5;
    case "month":
      return 3;
    case "year":
      return 5;
    default:
      return 5;
  }
}

///********************************************************************************* */
class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  String timeStamp = 'week';
  num factor = stepsToCaloriesFactor; //1

  List<String> factores = ["Calories", "Pas", "Distance"];
  List<String> months = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
  ];
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: kOtherColor,
  );

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context, listen: false);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  value: "week",
                  groupValue: timeStamp,
                  onTap: () {
                    timeStamp = "week";
                    setState(() {});
                  },
                  child: const Text(
                    "7 jours",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                CustomButton(
                  value: "month",
                  onTap: () {
                    timeStamp = "month";
                    setState(() {});
                  },
                  groupValue: timeStamp,
                  child: const Text(
                    "1 Mois",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                CustomButton(
                  value: "year",
                  onTap: () {
                    timeStamp = "year";
                    setState(() {});
                  },
                  groupValue: timeStamp,
                  child: const Text(
                    "1 An",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: FutureBuilder<DocumentSnapshot>(
            future: userDao.getUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              Map<DateTime, int> saver(Map<String, dynamic> map) {
                return map
                    .map((key, value) => MapEntry(DateTime.parse(key), value));
              }

              int getDayiPas(Map<DateTime, int> dayi) {
                return dayi.values.first;
              }
              int getDayk(Map<DateTime, int> dayi){
                return dayi.keys.first.day;
              }

              List measure = [];
              List<String> domain = [];
              num moyenne = 0;
              num total = 0;
              var pasHistorique = (snapshot.data!.get("pasHistorique") ?? []);
              if (pasHistorique.isEmpty) {
                print("there is a big big probleme with the code");
              } else {
                switch (timeStamp) {
                  case "week":
                    {
                      Map<DateTime, int> aujourdui = saver(pasHistorique[0]);
                      DateTime aujourduiDate = aujourdui.keys.first;
                      int aujourduiDay = aujourduiDate.day;
                      
                      DateTime currentDate = aujourduiDate;
                      String month;
                      int currentDay;

                      measure = List.filled(
                        7,
                        0,
                      );
                      measure[6] = getDayiPas(aujourdui) * factor;
                      domain = ["Aujourd'hui"];
                      
                      int k = 1;
                      int dayk;

                      for (var i = 1; i < 7; i++) {
                        currentDate = currentDate.add(const Duration(days: -1));
                        currentDay = currentDate.day;
                        month = months[currentDate.month - 1];
                         domain = [
                                "${month.substring(0, min(3, month.length))}/$currentDay"
                              ] +
                              domain;

                        try {
                          dayk = getDayk(saver(pasHistorique[k]));
                          if (dayk == aujourduiDay - i) {
                            measure[6 - i] =
                              getDayiPas(saver(pasHistorique[k])) * factor;
                            k++;
                          }else{
                            measure[6 - i] = 0;
                          }
                         
                        } on RangeError {
                          measure[6 - i] = 0;
                        }
                      }
                    }
                    break;

                  case "month":
                    {
                      Map<DateTime, int> aujourdui = saver(pasHistorique[0]);
                      DateTime aujourduiDate = aujourdui.keys.first;
                      int aujourduiDay = aujourduiDate.day;
                      String month = months[aujourduiDate.month - 1];

                      measure = List.filled(
                        aujourduiDay,
                        0,
                      );
                      measure[aujourduiDay - 1] =
                          getDayiPas(aujourdui) * factor;
                      domain = ["Aujourd'hui"];

                      int k = 1;
                      int dayk;

                      for (var i = 1; i < aujourduiDay; i++) {
                         domain = [
                                "${month.substring(0, min(3, month.length))}/${aujourduiDay - i}"
                              ] +
                              domain;

                        try {
                           dayk = getDayk(saver(pasHistorique[k]));
                          if (dayk == aujourduiDay - i) {
                            measure[aujourduiDay - 1  - i] =
                              getDayiPas(saver(pasHistorique[k])) * factor;
                            k++;
                          }else{
                            measure[aujourduiDay - 1  - i] = 0;
                          }

                         
                        } on RangeError {
                          measure[aujourduiDay - 1 - i] = 0;
                         
                        }
                      }
                    }
                    break;
                  case "year":
                    {
                      int getMonth(Map<DateTime, int> dayi) {
                        return dayi.keys.first.month;
                      }

                      Map<DateTime, int> aujourdui = saver(pasHistorique[0]);
                      int activeMonth = getMonth(aujourdui);
                      for (var i = 0; i < 12; i++) {
                        domain = [months[(activeMonth - 1 - i) % 12]] + domain;
                      }

                      measure = List.filled(
                        12,
                        0,
                      );

                      int j = 0;
                      for (var i = 0; i < 12; i++) {
                        try {
                          while (getMonth(saver(pasHistorique[j])) ==
                              activeMonth) {
                            measure[11 - i] +=
                                getDayiPas(saver(pasHistorique[j])) * factor;
                            j++;
                          }
                          activeMonth = getMonth(saver(pasHistorique[j]));
                        } on RangeError {
                          break;
                        }
                      }
                    }
                    break;
                }
                moyenne = fmoyenne(measure);
                total = ftotal(measure);
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Moyenne",
                            style: TextStyle(
                              fontSize: kDefaultPadding / 3,
                            ),
                          ),
                          Text(
                            moyenne.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: kDefaultPadding / 2,
                              color: Color(
                                0xffff1414,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: kDefaultPadding / 3,
                            ),
                          ),
                          Text(
                            total.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: kDefaultPadding / 2,
                              color: Color(
                                0xff36a5bb,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 4,
                    child: charts.BarChart(
                      [
                        charts.Series(
                          id: 'graph',
                          domainFn: (value, _) => domain[_!],
                          measureFn: (value, _) => measure[_!], //mesure(value),
                          data: measure,
                          fillColorFn: (value, _) {
                            return charts.ColorUtil.fromDartColor(
                                kPrimaryColor);
                          },
                        )
                      ],
                      animate: true,
                      vertical: true,
                      behaviors: [
                        charts.SlidingViewport(),
                        charts.PanAndZoomBehavior(),
                      ],
                      domainAxis: charts.OrdinalAxisSpec(
                        viewport: charts.OrdinalViewport(
                            "Aujourd'hui", size(timeStamp)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              WheelChooser(
                itemSize: 90,
                horizontal: true,
                perspective: 0.006,
                onValueChanged: (s) => setState(
                  () {
                    switch (s) {
                      case "Calories":
                        {
                          factor = stepsToCaloriesFactor;
                        }
                        break;
                      case "Pas":
                        {
                          factor = 1;
                        }
                        break;
                      case "Distance":
                        {
                          factor = stepsToDistanceFactor;
                        }
                        break;
                    }
                  },
                ),
                datas: factores,
                unSelectTextStyle: const TextStyle(
                  color: Color(0xffd6eac1),
                  fontSize: 10,
                ),
                selectTextStyle: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                ),
              ),
              Center(
                child: Container(
                  height: 40,
                  margin: EdgeInsets.all(8),
                  width: 90,
                  decoration: BoxDecoration(
                    border: Border(
                      left: borderSide,
                      right: borderSide,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: (widget.value == widget.groupValue)
              ? const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
          color: (widget.value == widget.groupValue)
              ? kPrimaryColor
              : kLightPrimaryColor,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 60,
        width: 80,
        child: widget.child,
      ),
    );
  }
}
