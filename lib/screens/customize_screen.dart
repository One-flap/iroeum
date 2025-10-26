import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/user_service.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  // 개발자 모드: 모든 데이터 삭제하고 처음부터 시작
  Future<void> _resetApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '개발자 모드',
          style: TextStyle(fontFamily: 'Ownglyph meetme'),
        ),
        content: const Text(
          '모든 데이터를 삭제하고 처음부터 시작하시겠습니까?',
          style: TextStyle(fontFamily: 'Ownglyph meetme'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Ownglyph meetme'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '확인',
              style: TextStyle(
                fontFamily: 'Ownglyph meetme',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await UserService().clearAllData();
      if (mounted) {
        context.go('/setup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFFFFFDD)),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Top section: Mood icon and Info card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood icon (개발자 모드 트리거)
                        GestureDetector(
                          onLongPress: _resetApp,
                          child: Container(
                            width: screenWidth * 0.25,
                            height: screenWidth * 0.24,
                            constraints: const BoxConstraints(
                              maxWidth: 99,
                              maxHeight: 95,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFFEDB8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/happy_face.png',
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.14,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Info card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(
                              maxWidth: 205,
                              maxHeight: 95,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0x7FFFD966),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '이름 : ${UserService().userName}',
                                            style: const TextStyle(
                                              color: Color(0xFF505050),
                                              fontSize: 14,
                                              fontFamily: 'Ownglyph meetme',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '병원 : ${UserService().hospital}',
                                            style: const TextStyle(
                                              color: Color(0xFF505050),
                                              fontSize: 14,
                                              fontFamily: 'Ownglyph meetme',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '나이 : ${UserService().userAge}세',
                                            style: const TextStyle(
                                              color: Color(0xFF505050),
                                              fontSize: 14,
                                              fontFamily: 'Ownglyph meetme',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '아픈 곳 : ${UserService().disease}',
                                            style: const TextStyle(
                                              color: Color(0xFF505050),
                                              fontSize: 14,
                                              fontFamily: 'Ownglyph meetme',
                                              fontWeight: FontWeight.w400,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '먹는약 : ${UserService().medications}',
                                  style: const TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 14,
                                    fontFamily: 'Ownglyph meetme',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Progress section
                    Column(
                      children: [
                        const Text(
                          '이번 약은 30%나 완주 했어',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF505050),
                            fontSize: 15,
                            fontFamily: 'Ownglyph meetme',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Progress bar
                        Container(
                          width: screenWidth * 0.75,
                          constraints: const BoxConstraints(maxWidth: 280),
                          child: Stack(
                            children: [
                              // Background
                              InnerShadow(
                                shadows: const [
                                  Shadow(
                                    color: Color(0xFFFF9B00),
                                    blurRadius: 20,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                                child: Container(
                                  height: 29,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 3,
                                        color: Color(0xFFFAA71B),
                                      ),
                                      borderRadius: BorderRadius.circular(12.50),
                                    ),
                                  ),
                                ),
                              ),
                              // Fill
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 0.3),
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Container(
                                    width: (screenWidth * 0.75 * value).clamp(0, 280 * 0.3),
                                    height: 29,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFAA71B),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 2,
                                          color: Color(0xFFFAA71B),
                                        ),
                                        borderRadius: BorderRadius.circular(12.50),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Border
                              Container(
                                height: 29,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 2,
                                      color: Color(0xFFFFEDB8),
                                    ),
                                    borderRadius: BorderRadius.circular(12.50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Main card with teddy
                    Container(
                      width: screenWidth * 0.87,
                      constraints: const BoxConstraints(maxWidth: 326),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Orange shadow card
                          Positioned(
                            left: 1,
                            top: 0.05,
                            child: Container(
                              width: screenWidth * 0.87,
                              height: screenWidth * 1.1,
                              constraints: const BoxConstraints(
                                maxWidth: 326,
                                maxHeight: 413,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFAA71B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(57),
                                ),
                              ),
                            ),
                          ),
                          // Main white card
                          Container(
                            width: screenWidth * 0.87,
                            height: screenWidth * 1.1,
                            constraints: const BoxConstraints(
                              maxWidth: 326,
                              maxHeight: 413,
                            ),
                            decoration: ShapeDecoration(
                              shadows: const [
                                BoxShadow(
                                  color: Color(0xAAFF9B00),
                                  blurRadius: 20,
                                  offset: Offset(0, 0),
                                  spreadRadius: 3,
                                ),
                              ],
                              color: const Color(0xFFFFFFDD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(57),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 30),
                                // Title
                                const Text(
                                  '너만의 곰이를 꾸며줘!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 24,
                                    fontFamily: 'Ownglyph meetme',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Teddy bear with orange circle
                                SizedBox(
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Orange circle shadow
                                      Container(
                                        width: screenWidth * 0.5,
                                        height: screenWidth * 0.5,
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                          maxHeight: 200,
                                        ),
                                        decoration: const ShapeDecoration(
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x33FF9933),
                                              blurRadius: 40,
                                              offset: Offset(0, 4),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                          shape: OvalBorder(),
                                        ),
                                      ),
                                      // Teddy image
                                      Image.asset(
                                        'assets/images/idle_teddy.png',
                                        width: screenWidth * 0.45,
                                        height: screenWidth * 0.45,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Customization options
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCustomOption(
                                      'assets/images/cloth_icon.png',
                                      '옷',
                                      screenWidth,
                                    ),
                                    SizedBox(width: screenWidth * 0.08),
                                    _buildCustomOption(
                                      'assets/images/just_face.png',
                                      '표정',
                                      screenWidth,
                                    ),
                                    SizedBox(width: screenWidth * 0.08),
                                    _buildCustomOption(
                                      'assets/images/item_icon.png',
                                      '아이템',
                                      screenWidth,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: BottomNavBar(currentIndex: 4),
        ),
      ),
    );
  }

  Widget _buildCustomOption(String imagePath, String label, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: screenWidth * 0.14,
          height: screenWidth * 0.14,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontFamily: 'Ownglyph meetme',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
