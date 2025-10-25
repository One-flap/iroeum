import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/missions_screen.dart';

final GoRouter appRouter = GoRouter(
  // Start the app on the splash screen, then the splash will navigate to '/'
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/missions',
      name: 'missions',
      builder: (context, state) => const MissionsScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/setup',
      name: 'setup',
      builder: (context, state) => const SetupScreen(),
    )
  ],
  errorBuilder: (context, state) => const HomeScreen(),
);