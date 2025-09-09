import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );

  static GoRouter get router => _router;
}
