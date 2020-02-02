enum RouteName {
  Splash,
  Entrance,
  Initialization,
  Home
}

extension RouteNameExtension on RouteName {
  String get name {
    switch (this) {
      case RouteName.Splash: {
        return '/';
      }
      case RouteName.Entrance: {
        return '/entrance';
      }
      case RouteName.Initialization: {
        return '/initialization';
      }
      case RouteName.Home: {
        return '/home';
      }
    }
  }
}