import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:app/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';

class CompetitionDashboard extends StatefulWidget {
  const CompetitionDashboard({Key? key}) : super(key: key);

  @override
  State<CompetitionDashboard> createState() => _CompetitionDashboardState();
}

class _CompetitionDashboardState extends State<CompetitionDashboard> {
  @override
  Widget build(BuildContext context) {
    UserDao userDao = Provider.of<UserDao>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: CompetitionModel.getCompetitionsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var len = snapshot.data!.docs.length;

        if (len == 0) {
          return const NoCompetitionFound();
        }
        DateTime today = DateTime.now();
        var lastCompetitionStartDay =
            DateTime.parse(snapshot.data!.docs[0].get("date de debut"));

        var lastCompetitionEndDay =
            DateTime.parse(snapshot.data!.docs[0].get("date de fin"));

        if (today.compareTo(lastCompetitionEndDay) > 0) {
          userDao.updateUserWithData({'activeCompetition': null});
          return const NoCompetitionFound();
        }

        CompetitionModel competitionModel =
            CompetitionModel.fromSnapshot(snapshot.data!.docs[0]);
        if (today.compareTo(lastCompetitionStartDay) < 0) {
          return BeforeDashBoard(competitionModel);
        } else {
          return AfterDashBoard(competitionModel);
        }
      },
    );
  }
}

class BeforeDashBoard extends StatefulWidget {
  const BeforeDashBoard(
    this.competitionModel, {
    Key? key,
  }) : super(key: key);
  final CompetitionModel competitionModel;
  @override
  State<BeforeDashBoard> createState() => _BeforeDashBoardState();
}

class _BeforeDashBoardState extends State<BeforeDashBoard> {
  @override
  Widget build(BuildContext context) {
    UserDao userDao = Provider.of<UserDao>(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: userDao.getUserStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!["activeCompetition"] != null) {
          return Inscrit(widget.competitionModel);
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Text(
                widget.competitionModel.name,
                style: head,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "date de debut : " + widget.competitionModel.dateDeDebut,
                style: body,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "date de fin : " + widget.competitionModel.dateDeFin,
                style: body,
              ),
              const SizedBox(
                height: 50,
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Description :",
                    style: body,
                  )),
              const SizedBox(
                height: 16,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.competitionModel.discreption,
                    style: body,
                  )),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  userDao.updateUserWithData(
                    {'activeCompetition': widget.competitionModel.reference},
                  );
                  widget.competitionModel.addParticipant(snapshot.data!);
                },
                child: const Text("Participer"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AfterDashBoard extends StatefulWidget {
  const AfterDashBoard(this.competitionModel, {Key? key}) : super(key: key);
  final CompetitionModel competitionModel;
  @override
  State<AfterDashBoard> createState() => _AfterDashBoardState();
}

class _AfterDashBoardState extends State<AfterDashBoard> {
  @override
  Widget build(BuildContext context) {
    UserDao userDao = Provider.of<UserDao>(context);
    return FutureBuilder<DocumentSnapshot>(
      future: userDao.getUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!["activeCompetition"] != null) {
          return DashBoard(widget.competitionModel);
        }
        return const NoCompetitionFound();
      },
    );
  }
}

class DashBoard extends StatefulWidget {
  const DashBoard(this.competitionModel, {Key? key}) : super(key: key);
  final CompetitionModel competitionModel;
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final ScrollController scrollController = ScrollController();
  int currentUserRank = 1;
  int currentUserTotal = 0;
  num currentUserCalories = 0;
  num currentUserDistance = 0;
  int? todaysCount;

  @override
  Widget build(BuildContext context) {
    UserDao userDao = Provider.of<UserDao>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: widget.competitionModel.reference!.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          DateTime dateDeDebut =
              DateTime.parse(snapshot.data!.get("date de debut"));
          DateTime dateDeFin =
              DateTime.parse(snapshot.data!.get("date de fin"));
          bool isBetween(DateTime date) {
            return date.isAfter(dateDeDebut) && date.isBefore(dateDeFin) ||
                date == dateDeDebut ||
                date == dateDeFin;
          }

          Future<List<CustomRow>> helperFuture() async {
            List<DocumentSnapshot> participants = (await snapshot
                    .data!.reference
                    .collection("participants")
                    .get())
                .docs;
            print("participants $participants");
            List<CustomRow> customTableRow = [];
            for (var participant in participants) {
              DocumentSnapshot user = await participant["user"].get();
              int total = 0;
              var newPasHistorique = participant["pasHistorique"];
              for (var item in user["pasHistorique"]) {
                DateTime day = DateTime.parse(item.keys.first);
                int value = item.values.first;
                if (isBetween(day)) {
                  newPasHistorique[item.keys.first] = value;
                  total += value;
                } else {
                  break;
                }
              }

              participant.reference.update({"pasHistorique": newPasHistorique});

              if (user.id == userDao.userId()) {
                currentUserTotal = total;
                currentUserCalories = currentUserTotal * stepsToCaloriesFactor;
                currentUserDistance = currentUserTotal * stepsToDistanceFactor;
              }
              customTableRow.add(buildListItem(context, user, total));
            }
            return customTableRow;
          }

          return FutureBuilder<List<CustomRow>>(
            future: helperFuture(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              List<CustomRow> customTableRow = snapshot.data!;
              customTableRow.sort((a, b) => a.total.compareTo(b.total));
              var map = customTableRow.asMap();
              map.forEach(
                (key, value) {
                  if (value.id == userDao.userId()) {
                    currentUserRank = key + 1;
                  }
                  value.rang = (key + 1).toString();
                },
              );
              customTableRow = map.values.toList();
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.run_circle),
                      const Text(
                        "Rang : ",
                        style: body,
                      ),
                      Text(
                        currentUserRank.toString(),
                        style: const TextStyle(
                            fontSize: 20, color: kSecondaryColor),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Colories",
                            style: body,
                          ),
                          Text(
                            currentUserCalories.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 20, color: kBlueColor),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            "Total pas",
                            style: body,
                          ),
                          Text(
                            currentUserTotal.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 20, color: kPrimaryColor),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Km",
                            style: body,
                          ),
                          Text(
                            currentUserDistance.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.red),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: ListView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        children: customTableRow),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Builder(builder: (context) {
                    final mainProvider =
                        Provider.of<MainProvider>(context, listen: false);

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
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "Total aujourd'hui : ",
                                style: body,
                              ),
                              Text(
                                todaysCount.toString(),
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 20),
                              ),
                            ],
                          );
                        });
                  }),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  CustomRow buildListItem(
      BuildContext context, DocumentSnapshot snapshot, int total) {
    final userModel = User.fromSnapshot(snapshot);
    return CustomRow(
      userModel.reference!.id,
      "0",
      (userModel.prenom ?? '__') + ' ' + (userModel.nom ?? '__'),
      total.toString(),
    );
  }
}

class NoCompetitionFound extends StatelessWidget {
  const NoCompetitionFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      "il n'y a pas de competitions pour le moment",
      style: kerror,
    );
  }
}

class Inscrit extends StatefulWidget {
  const Inscrit(this.competition, {Key? key}) : super(key: key);
  final CompetitionModel competition;
  @override
  State<Inscrit> createState() => _InscritState();
}

class _InscritState extends State<Inscrit> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Vous êtes incrit dans la competition " + widget.competition.name,
          style: body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          "Elle va commencer le " + widget.competition.dateDeDebut,
          style: body,
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          "Nombre de participants est " +
              widget.competition.nombreDeParticipants.toString(),
          style: body,
        ),
      ],
    );
  }
}

class CustomRow extends StatefulWidget {
  CustomRow(this.id, this.rang, this.fullName, this.total, {Key? key})
      : super(key: key);
  String rang;
  final String fullName;
  final String total;
  final String id;
  @override
  State<CustomRow> createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide()),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TableHelper(
            widget.fullName,
            width: 160,
            style: body,
          ),
          TableHelper(
            widget.total,
            width: 70,
            style: body,
          ),
          TableHelper(
            widget.rang,
            width: 40,
            style: body,
          ),
        ],
      ),
    );
  }
}

class TableHelper extends StatelessWidget {
  const TableHelper(this.text,
      {Key? key, required this.width, required this.style})
      : super(key: key);
  final double width;
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: width,
        child: Text(
          text,
          style: style,
        ));
  }
}
