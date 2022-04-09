import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    asyncMethod();
  }

  asyncMethod() async {
    var backGroundWork = Provider.of<BackGroundWork>(context, listen: false);
    backGroundWork.ntodaysCount =
        await backGroundWork.getBackGroundCounterValue();
    backGroundWork.nmoments = await backGroundWork.getBackGroundGraphValues();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context, listen: false);
    todaysCount = Provider.of<BackGroundWork>(context).ntodaysCount;
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
                    fontSize: kDefaultPadding,
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
                    fontSize: kDefaultPadding,
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
                fontSize: kDefaultPadding / 2,
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
                      fontSize: kDefaultPadding / 2,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
                User user = User.fromSnapshot(snapshot.data!);
                return Text(
                  "But d'aujourd'hui\n${user.cible ?? 2000}",
                  style: TextStyle(
                    fontSize: kDefaultPadding / 2,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
        Expanded(
          flex: 5,
          child: Graph(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

////////////////////////////////////////////

class Graph extends StatelessWidget {
  const Graph({Key? key}) : super(key: key);
  String domain(String value) {
    return value.substring(0, 2);
  }

  int mesure(String value) {
    return int.tryParse(value.substring(2)) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    List<String> moments = Provider.of<BackGroundWork>(context).nmoments;
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
        viewport: charts.OrdinalViewport("${(DateTime.now().hour - 5) % 24}", 15),
      ),
    );
  }
}
