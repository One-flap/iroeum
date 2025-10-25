import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/missions_screen.dart';
import '../screens/customize_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/star_screen.dart';
import '../services/user_service.dart';

final GoRouter appRouter = GoRouter(
  // 항상 스플래시 화면부터 시작
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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // setup -> home transition: current slides down, new scales up and fades in
          final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(animation);
          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
          final slideDownAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(secondaryAnimation);

          return Stack(
            children: [
              SlideTransition(
                position: slideDownAnimation,
                child: FadeTransition(
                  opacity: ReverseAnimation(animation),
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    GoRoute(
      path: '/missions',
      name: 'missions',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MissionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // default transition: current fades out and shrinks, new fades in and grows
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
          final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    // GoRoute(
    //   path: '/profile',
    //   name: 'profile',
    //   builder: (context, state) => const ProfileScreen(),
    // ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // default transition: current fades out and shrinks, new fades in and grows
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
          final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/setup',
      name: 'setup',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // signup -> setup transition: current fades out, next slides up and fades in
          final slideUp = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation);
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: state.extra as Widget? ?? Container(),
              ),
              SlideTransition(
                position: slideUp,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    GoRoute(
      path: '/customize',
      name: 'customize',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CustomizeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // default transition: current fades out and shrinks, new fades in and grows
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
          final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      pageBuilder: (context, state) {
        final query = state.uri.queryParameters['query'];
        return CustomTransitionPage(
          key: state.pageKey,
          child: ChatScreen(initialQuery: query),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // default transition: current fades out and shrinks, new fades in and grows
            final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
            final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
            final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
            final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

            return Stack(
              children: [
                FadeTransition(
                  opacity: fadeOut,
                  child: ScaleTransition(
                    scale: scaleOut,
                    child: state.extra as Widget? ?? Container(),
                  ),
                ),
                FadeTransition(
                  opacity: fadeIn,
                  child: ScaleTransition(
                    scale: scaleIn,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/calendar',
      name: 'calendar',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CalendarScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // default transition: current fades out and shrinks, new fades in and grows
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
          final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
    GoRoute(
      path: '/star',
      name: 'star',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StarScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // default transition: current fades out and shrinks, new fades in and grows
          final fadeIn = animation.drive(Tween(begin: 0.0, end: 1.0));
          final scaleIn = animation.drive(Tween(begin: 0.95, end: 1.0));
          final fadeOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.0));
          final scaleOut = secondaryAnimation.drive(Tween(begin: 1.0, end: 0.95));

          return Stack(
            children: [
              FadeTransition(
                opacity: fadeOut,
                child: ScaleTransition(
                  scale: scaleOut,
                  child: state.extra as Widget? ?? Container(),
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    ),
  ],
  errorBuilder: (context, state) => const HomeScreen(),
);