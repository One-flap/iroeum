import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_service.dart';
import '../services/deep_link_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 최소 2초 대기
    await Future.delayed(const Duration(seconds: 2));

    // 딥링크 처리를 위해 추가로 조금 더 대기 (최대 500ms)
    int attempts = 0;
    while (attempts < 5) {
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        // 딥링크로 환자 정보가 있으면 Setup으로
        if (DeepLinkService().patientData != null) {
          context.go('/setup');
          return;
        }
      }

      attempts++;
    }

    // 딥링크가 없으면 기존 로직
    if (mounted) {
      if (UserService().isSetupComplete) {
        context.go('/');
      } else {
        context.go('/signup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFFFFFDD), Color(0xFFFFD966)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Title texts
              const Text(
                '너만을 위한 작은곰돌이',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFAA71B),
                  fontSize: 20,
                  fontFamily: 'Ownglyph meetme',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '이로움',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF505050),
                  fontSize: 40,
                  fontFamily: 'Ownglyph meetme',
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 2),

              // Main centered image
              Container(
                width: screenWidth * 0.7,
                height: screenWidth * 0.7,
                constraints: const BoxConstraints(
                  maxWidth: 313,
                  maxHeight: 313,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/splash_teddy.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
