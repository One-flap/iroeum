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
    // Show splash for 2 seconds then navigate based on setup status
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // 딥링크로 환자 정보가 있으면 Setup으로
        if (DeepLinkService().patientData != null) {
          context.go('/setup');
        }
        // setup이 완료되지 않았으면 signup으로, 완료되었으면 home으로
        else if (UserService().isSetupComplete) {
          context.go('/');
        } else {
          context.go('/signup');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a responsive approximation of the provided design
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
        child: Stack(
          children: [
            // Top status-like area (keeps spacing similar)
            Positioned(
              left: 9,
              top: 0,
              child: SizedBox(
                width: 375,
                height: 44,
                child: Stack(children: [
                  Positioned(
                    left: 21,
                    top: 12,
                    child: Container(
                      width: 54,
                      height: 21,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // Main centered image
            Positioned(
              left: 80,
              top: 499,
              child: Container(
                width: 313,
                height: 313,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/splash_teddy.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Texts (approx positions from your snippet)
            Positioned(
              left: 129,
              top: 327,
              child: Text(
                '너만을 위한 작은곰돌이',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFAA71B),
                  fontSize: 20,
                  fontFamily: 'Ownglyph meetme',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              left: 161,
              top: 350,
              child: Text(
                '이로움',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF505050),
                  fontSize: 40,
                  fontFamily: 'Ownglyph meetme',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Bottom grabber
            Positioned(
              left: 129,
              top: 834,
              child: Container(
                width: 134,
                height: 5,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
