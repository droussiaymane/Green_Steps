import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int? todaysCount;
  num? todaysCalories;
  num? todaysDistance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context, listen: false);

    return FutureBuilder<Map<String, dynamic>?>(
        future: BackGroundWork().initialize(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder<Map<String, dynamic>?>(
            initialData: snapshot.data!,
            stream: FlutterBackgroundService().on('update'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final data = snapshot.data!;
              todaysCount = data["todaysCount"];
              todaysCalories = todaysCount! * stepsToCaloriesFactor;
              todaysDistance = todaysCount! * stepsToDistanceFactor;
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Calories",
                            style: TextStyle(
                              fontSize: kDefaultPadding / 2,
                            ),
                          ),
                          Text(
                            todaysCalories!.toStringAsFixed(2),
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
                            "km",
                            style: TextStyle(
                              fontSize: kDefaultPadding / 2,
                            ),
                          ),
                          Text(
                            todaysDistance!.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: kDefaultPadding / 2,
                              color: kBlueColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Column(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Text(
                        "Pas d'aujourd'hui",
                        style: TextStyle(
                          fontSize: kDefaultPadding / 3,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        todaysCount.toString(),
                        style: const TextStyle(
                          fontSize: kDefaultPadding,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      FutureBuilder<DocumentSnapshot>(
                        // 2
                        future: userDao.getUser(),
                        // 3
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text(
                              "But d'aujourd'hui\n...",
                              style: TextStyle(
                                fontSize: kDefaultPadding / 3,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                          User user = User.fromSnapshot(snapshot.data!);
                          return Text(
                            "But d'aujourd'hui\n${user.cible ?? 2000}",
                            style: const TextStyle(
                              fontSize: kDefaultPadding / 3,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 5,
                    child: Graph(data["moments"].cast<String>()),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        });
  }
}

////////////////////////////////////////////

class Graph extends StatelessWidget {
  const Graph(this.moments, {Key? key}) : super(key: key);
  final List<String> moments;
  String domain(String value) {
    return value.substring(0, 2);
  }

  int mesure(String value) {
    return int.tryParse(value.substring(2)) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      [
        charts.Series(
          id: 'graph',
          domainFn: (value, _) => domain(value),
          measureFn: (value, _) => mesure(value),
          data: moments,
          fillColorFn: (value, _) {
            return charts.ColorUtil.fromDartColor(kPrimaryColor);
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
        viewport:
            charts.OrdinalViewport("${(DateTime.now().hour - 5) % 24}", 15),
      ),
    );
  }
}
