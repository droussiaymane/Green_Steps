import 'package:flutter/material.dart';
import 'package:wheel_chooser/wheel_chooser.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class ChoixDepartement extends StatefulWidget {
  ChoixDepartement({Key? key}) : super(key: key);

  static MaterialPage page() {
    return MaterialPage(
      name: "/choixDepartement",
      key: ValueKey("/choixDepartement"),
      child: ChoixDepartement(),
    );
  }

  @override
  State<ChoixDepartement> createState() => _ChoixDepartementState();
}

class _ChoixDepartementState extends State<ChoixDepartement> {
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: kOtherColor,
  );
  String departement = "EMINES";

  List<String> departemnts = [
    "1337",
    "GTI",
    "CBS",
    "MSN",
    "ESAFE",
    "SAP+D",
    "ISSPB",
    "CS",
    "EMINES",
    "CI",
    "ALKHAWARIZMI",
    "Maher Center",
    "SHBM",
  ];

  @override
  Widget build(BuildContext context) {
    final appStateManager = Provider.of<AppStateManager>(context, listen: false);
    final user = Provider.of<User>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              "Quel est votre département ?",
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(departement,
                  style: TextStyle(fontSize: 30, color: kPrimaryColor)),
            ),
            // Expanded(
            //   child: WheelChooser.custom(
            //     perspective: 0.006,
            //     onValueChanged: (s) => setState(() {
            //       //departemnts[s].color = Color(0xFF757a90);
            //       departemnts[s] = WheelChooserOption(departemnts[s].text,color : Color(0xFF757a90));
            //       departement = departemnts[s].text;
            //     }),
            //     children: departemnts,
            //   ),
            // ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  WheelChooser(
                    perspective: 0.006,
                    onValueChanged: (s) => setState(() {
                      departement = s;
                    }),
                    datas: departemnts,
                    unSelectTextStyle: TextStyle(
                      color: Color(0xffd6eac1),
                    ),
                    selectTextStyle: TextStyle(
                      color: kPrimaryColor,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.all(8),
                      width: 90,
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        border: Border(
                          top: borderSide,
                          bottom: borderSide,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                      user.departement = departement;
                      appStateManager.setIndex(3);
                    },
                    child: const Text("Suivant"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
























//usless ///////////////////////////////////////////////////////////
class WheelChooserOption extends StatelessWidget {
  Color color;
  double fontsize;
  String text;
  bool noTop;

  WheelChooserOption(
    this.text, {
    this.noTop = false,
    this.fontsize = 20,
    this.color = const Color(0xFF000000),
  });

  @override
  Widget build(BuildContext context) {
    BorderSide borderSide = BorderSide(
      width: 2,
      style: BorderStyle.solid,
      color: Color(0xFFFFFFFF), //Color(0xFF757a90),
    );
    return Container(
      margin: EdgeInsets.all(8),
      width: 90,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontsize,
          ),
        ),
      ),
      decoration: BoxDecoration(
        // color: Colors.red,
        border: Border(
          top: noTop ? BorderSide.none : borderSide,
          bottom: borderSide,
        ),
      ),
    );
  }
}


/*
List<WheelChooserOption> departemnts = [
    WheelChooserOption("EMINES"),
    WheelChooserOption("ARCHI"),
    WheelChooserOption("1337"),
    WheelChooserOption("CS"),
    WheelChooserOption("Hospitality"),
    WheelChooserOption("FLAHA"),
    WheelChooserOption("MAHER"),
  ];

*/
