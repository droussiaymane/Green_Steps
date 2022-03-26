import 'package:app/models/models.dart';
import 'package:app/screens/screens.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/welcome':
        return MaterialPageRoute(builder: (_) => Welcome());
      case '/welcome/identifier':
        return MaterialPageRoute(builder: (_) => Identifier());
      case '/welcome/identifier/valider':
        return MaterialPageRoute(builder: (_) => Valider());
      case '/welcome/identifier/valider/dateNaissance':
        return MaterialPageRoute(builder: (_) => DateNaissance());
      case '/welcome/identifier/valider/dateNaissance/choixSexe':
        return MaterialPageRoute(builder: (_) => ChoixSexe());
      case '/welcome/identifier/valider/dateNaissance/choixSexe/choixDepartement':
        return MaterialPageRoute(builder: (_) => ChoixDepartement());
      case '/welcome/identifier/valider/dateNaissance/choixSexe/choixDepartement/taillePoids':
        return MaterialPageRoute(builder: (_) => TaillePoids());
      case '/welcome/identifier/valider/dateNaissance/choixSexe/choixDepartement/taillePoids/bienvenue':
        return MaterialPageRoute(builder: (_) => Bienvenue());

      case '/mainScreen':
        return MaterialPageRoute(builder: (_) => MainScreen());
      case '/mainScreen/competition':
        return MaterialPageRoute(builder: (_) => Competition());

      default:
        return MaterialPageRoute(
            builder: (_) => const Material(
                  child: SafeArea(child: Text('error')),
                ));
    }
  }
}

class AppRouter extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppStateManager appStateManager;
  final List<MaterialPage> loginProcess = [
    Valider.page(),
    StaffEtudiant.page(),
    ChoixDepartement.page(),
    DateNaissance.page(),
    ChoixSexe.page(),
    TaillePoids.page(),
    Bienvenue.page(),
  ];

  AppRouter({
    required this.appStateManager,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    appStateManager.addListener(notifyListeners);
  }

  @override
  void dispose() {
    appStateManager.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      transitionDelegate: NoAnimationTransitionDelegate(),
      key: navigatorKey,
      onPopPage: _handlePopPage,
      pages: [
        if (!appStateManager.initialized) Welcome.page(),
        if (appStateManager.initialized && !appStateManager.loggedIn)
          Identifier.page(),
        if (appStateManager.initialized &&
            !appStateManager.loggedIn &&
            !(appStateManager.index <= -1))
          loginProcess[appStateManager.index],
        if (appStateManager.loggedIn) MainScreen.page(),
        if (appStateManager.loggedIn && appStateManager.inCompetition)
          Competition.page(),
      ],
    );
  }

  bool _handlePopPage(Route<dynamic> route, result) {
    if (!route.didPop(result)) {
      return false;
    }
    if (route.settings.name == "/bienvenue") {
      return true;
    }

    if (route.settings.name == "/dateNaissance") {
      appStateManager.setIndex(appStateManager.index - 1);
      if (appStateManager.isStaff) {
        appStateManager.setIndex(appStateManager.index - 1);
      }
    }

    else if (route.settings.name == "/staffEtudiant") {
      appStateManager.setIndex(-1);
    } else {
      appStateManager.setIndex(appStateManager.index - 1);
    }
    // TODO: Handle state when user closes profile screen
    // TODO: Handle state when user closes WebView screen
    // 6
    return true;
  }

  // 10
  @override
  Future<void> setNewRoutePath(configuration) async => null;
}

class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final RouteTransitionRecord exitingPageRoute
        in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final List<RouteTransitionRecord>? pagelessRoutes =
            pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}
