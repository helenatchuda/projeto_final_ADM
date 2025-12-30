import 'package:flutter_application_1/Pages/menu_page.dart';
import 'package:flutter_application_1/main.dart';
import 'package:go_router/go_router.dart';

/// App route constants and configuration
class AppRoutes {
  // Route paths
  static const String splashPath = '/';
  static const String homePath = '/homepage';
  static const String menuPath = '/menupage';
  static const String ordersPath = '/orders';
  static const String profilePath = '/profile';

  // Router configuration
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: homePath, builder: (context, state) => const HomePage()),
      GoRoute(path: menuPath, builder: (context, state) => const MenuPage()),
    ],
  );
}
