import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/reflection/presentation/reflection_input_screen.dart';
import '../../features/output/presentation/echo_output_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/models/reflection.dart';
import '../../shared/models/echo_response.dart';

class AppRouter {
  AppRouter._();

  // Route names
  static const String home = '/';
  static const String reflectionInput = '/reflection';
  static const String echoOutput = '/echo';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildPageRoute(const HomeScreen(), settings);

      case reflectionInput:
        return _buildPageRoute(const ReflectionInputScreen(), settings);

      case echoOutput:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          EchoOutputScreen(
            reflection: args?['reflection'] as Reflection?,
            echoResponse: args?['echoResponse'] as EchoResponse?,
          ),
          settings,
        );

      case history:
        return _buildPageRoute(const HistoryScreen(), settings);

      case AppRouter.settings:
        return _buildPageRoute(const SettingsScreen(), settings);

      default:
        return _buildPageRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
