import 'package:flutter/widgets.dart';
import 'package:safe_map_application/config/routes.dart';

/// Lightweight route observer that keeps a short history of visited named
/// routes. Useful to implement "smart" back navigation when screens are
/// opened using replacement navigation (tabs) and the navigator stack
/// doesn't contain the previous page.
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  static final List<String> _history = <String>[];

  void _add(String? name) {
    if (name == null || name.isEmpty) return;
    if (_history.isEmpty || _history.last != name) _history.add(name);
    // keep history reasonably small
    if (_history.length > 20) _history.removeAt(0);
  }

  @override
  void didPush(Route route, Route? previous) {
    super.didPush(route, previous);
    try {
      if (route is PageRoute) {
        _add(route.settings.name);
      }
    } catch (_) {}
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    try {
      // For replacement (e.g. tab switches using pushReplacementNamed) we
      // intentionally DO NOT remove the oldRoute from history. Removing it
      // causes the observer to forget the previous screen, which prevents
      // "smart" back navigation. Instead, just record the new route so
      // history retains the ordering of visited screens.
      if (newRoute is PageRoute) {
        _add(newRoute.settings.name);
      }
    } catch (_) {}
  }

  @override
  void didPop(Route route, Route? previous) {
    super.didPop(route, previous);
    try {
      if (route is PageRoute && _history.isNotEmpty && _history.last == route.settings.name) {
        _history.removeLast();
      }
    } catch (_) {}
  }

  /// Returns the most recent route that is not an auth/splash/welcome route.
  String? lastNonAuthRoute() {
    for (var i = _history.length - 1; i >= 0; i--) {
      final n = _history[i];
      if (n != AppRoutes.login && n != AppRoutes.splash && n != AppRoutes.welcome) return n;
    }
    return null;
  }

  /// Returns the most recent route before [current] that is not an auth/splash/welcome route.
  String? previousMeaningfulRoute(String? current) {
    if (_history.isEmpty) return null;
    for (var i = _history.length - 1; i >= 0; i--) {
      final n = _history[i];
      if (n == current) continue;
      if (n == AppRoutes.login || n == AppRoutes.splash || n == AppRoutes.welcome) continue;
      return n;
    }
    return null;
  }

  /// Last recorded route (may be auth/splash)
  String? get lastRoute => _history.isNotEmpty ? _history.last : null;
}

final AppRouteObserver appRouteObserver = AppRouteObserver();
