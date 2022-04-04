import 'package:flutter/material.dart';

class CompetitionHistorique extends StatefulWidget {
  const CompetitionHistorique({Key? key}) : super(key: key);

  @override
  State<CompetitionHistorique> createState() => _CompetitionHistoriqueState();
}

class _CompetitionHistoriqueState extends State<CompetitionHistorique> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      return Text("vous êtes pas inscrit dans aucun competition");
    });
  }
}
