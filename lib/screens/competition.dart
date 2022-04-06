import 'package:app/custom_widgets/custom_widgets.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Competition extends StatefulWidget {
  const Competition({Key? key}) : super(key: key);
  static MaterialPage page() {
    return const MaterialPage(
      name: '/competition',
      key: ValueKey('/competition'),
      child: Competition(),
    );
  }

  @override
  State<Competition> createState() => _CompetitionState();
}

class _CompetitionState extends State<Competition> {
  int _selectedIndex = 1;

  List<Widget> pages = [
    Text("historique"),
    const CompetitionDashboard(),
    Text("error"),
    MessageList(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    if (index != 2) {
      _selectedIndex = index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDao = Provider.of<UserDao>(context);
    final appStateManager =
        Provider.of<AppStateManager>(context, listen: false);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.logout,
        ),
        onPressed: () async {
          await userDao.logout();
          appStateManager.logInOut(userDao);
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              icon: const Icon(
                Icons.message,
              ),
            ),
            IconButton(
              onPressed: () {
                appStateManager.toCompetition(false);
              },
              icon: const Icon(Icons.home),
            ),
            IconButton(
              onPressed: () {
                _selectedIndex = 4;
                setState(() {});
              },
              icon: const Icon(
                Icons.person,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: (_selectedIndex < 3) ? _selectedIndex : 1,
        onTap: _onItemTapped,
      ),
    );
  }
}
