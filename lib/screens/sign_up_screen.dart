import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier(1.0);

  @override
  void dispose() {
    _scaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFF9F9F9), Color(0xFFFFD966)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Sign Up Title
                  const Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email input
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFFAA71B)),
                        borderRadius: BorderRadius.circular(32.5),
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'email',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Password input
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFFAA71B)),
                        borderRadius: BorderRadius.circular(32.5),
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'password',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Forget password
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'forget password?',
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 13,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Login button
                  GestureDetector(
                    onTapDown: (_) => _scaleNotifier.value = 0.9,
                    onTapUp: (_) async {
                      _scaleNotifier.value = 1.1;
                      await Future.delayed(const Duration(milliseconds: 80));
                      _scaleNotifier.value = 1.0;
                      context.go('/setup');
                    },
                    onTapCancel: () => _scaleNotifier.value = 1.0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scaleNotifier,
                      builder: (context, scale, child) => AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutBack,
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAA71B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // "or sign up with" section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Color(0xFFFAA71B)),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            color: Color(0xFF6B6D6F),
                            fontSize: 10,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Color(0xFFFAA71B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Social icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/google.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 22),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/kakaotalk.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 22),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/naver.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
