import 'package:flutter/material.dart';
import '../constants.dart';
import '../custom_widgets/bullet.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:app/models/models.dart';
import 'package:provider/provider.dart';

class DateNaissance extends StatefulWidget {
  DateNaissance({Key? key}) : super(key: key);
  static MaterialPage page() {
    return MaterialPage(
      name: "/dateNaissance",
      key: ValueKey("/dateNaissance"),
      child: DateNaissance(),
    );
  }

  @override
  State<DateNaissance> createState() => _DateNaissance();
}

class _DateNaissance extends State<DateNaissance> {
  BorderSide borderSide = const BorderSide(
    width: 2,
    style: BorderStyle.solid,
    color: Color(0xFF757a90),
  );

  String _selectedDate = "2000-11-12";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final appStateManager = Provider.of<AppStateManager>(context, listen: false);
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
              "Quel est votre date de naissance ?",
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_selectedDate,
                  style: TextStyle(fontSize: 25, color: kPrimaryColor)),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 40,
                  ),
                  Expanded(
                    child: DatePickerWidget(
                      looping: false, // default is not looping
                      firstDate: DateTime(1900, 01, 01),
                      lastDate: DateTime(2030, 1, 1),
                      initialDate: DateTime(2000, 11, 12),
                      dateFormat: "yyyy-MM-dd",
                      locale: DatePicker.localeFromString('FR'),
                      onChange: (DateTime newDate, _) => setState(() {
                        _selectedDate = newDate.toString().substring(0, 10);
                      }),
                      pickerTheme: const DateTimePickerTheme(
                        backgroundColor: Colors.transparent,
                        itemTextStyle:
                            TextStyle(color: kPrimaryColor, fontSize: 19),
                        dividerColor: kOtherColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
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
                      user.dateNaissance = _selectedDate;
                      appStateManager.setIndex(4);
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
