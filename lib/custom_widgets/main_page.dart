import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
    return Builder(builder: (context) {
      final mainProvider = Provider.of<MainProvider>(context, listen: false);
      return StreamBuilder<Map<String, dynamic>?>(
        initialData: {
          "moments": mainProvider.moments,
          "todaysCount": mainProvider.todaysCount,
        },
        stream: FlutterBackgroundService().on('update'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          mainProvider.moments = data["moments"].cast<String>();
          mainProvider.todaysCount = data["todaysCount"];

          todaysCount = data["todaysCount"];
          todaysCalories = todaysCount! * stepsToCaloriesFactor;
          todaysDistance = todaysCount! * stepsToDistanceFactor;
          return Column(
            children: [
             const Spacer(
                flex: 1,
              ),
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
                          color: kBlueColor,
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
                          color: Color(
                            0xffff1414,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
              Builder(builder: (context) {
                Widget annotation = Column(
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
                    Text(
                      "But d'aujourd'hui\n$cible",
                      style: const TextStyle(
                        fontSize: kDefaultPadding / 3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
                return Expanded(
                  flex: 5,
                  child: RadialGauge(
                    todaysCount: todaysCount!,
                    annotation: annotation,
                  ),
                );
              }),
              Expanded(
                flex: 4,
                child: Padding(padding :const EdgeInsets.symmetric(horizontal: 15) ,child: Graph(data["moments"].cast<String>())),
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          );
        },
      );
    });
  }
}

////////////////////////////////////////////
class RadialGauge extends StatelessWidget {
  int todaysCount;
  Widget annotation;
  RadialGauge({required this.todaysCount, required this.annotation, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          axisLineStyle: const AxisLineStyle(thickness: 4),
          showTicks: false,
          radiusFactor: 0.95,
          showLabels: false,
          minimum: 0,
          maximum: cible.toDouble(),
          pointers: <GaugePointer>[
            RangePointer(
              width: 4,
              color: kLightPrimaryColor,
              enableAnimation: true,
              value: todaysCount < cible
                  ? todaysCount.toDouble()
                  : cible.toDouble(),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: annotation,
              angle: 90,
              positionFactor: 0.5
            ),
          ],
        ),
      ],
    );
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
