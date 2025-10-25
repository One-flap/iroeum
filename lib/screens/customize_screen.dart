import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/user_service.dart';

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
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFFFFFFDD)),
          child: Stack(
            children: [
              // Orange shadow card
              Positioned(
                left: 35,
                top: 298.05,
                child: Container(
                  width: 326,
                  height: 413,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFAA71B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(57),
                    ),
                  ),
                ),
              ),
              // Main white card
              Positioned(
                left: 34.78,
                top: 298,
                child: Container(
                  width: 325.45,
                  height: 413.07,
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: const Color(0xAAFF9B00),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                        spreadRadius: 3,
                      )
                    ],
                    color: const Color(0xFFFFFFDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(57),
                    ),
                  ),
                ),
              ),
              // Info card
              Positioned(
                left: 156,
                top: 98,
                child: Container(
                  width: 205,
                  height: 95,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0x7FFFD966),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '이름 : 박초연    나이 : 8세',
                        style: TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 11,
                          fontFamily: 'Ownglyph meetme',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        '병원 : 조지병원',
                        style: TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 11,
                          fontFamily: 'Ownglyph meetme',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        '아픈 곳 : 백혈구',
                        style: TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 11,
                          fontFamily: 'Ownglyph meetme',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        '먹는약 : 항암제',
                        style: TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 11,
                          fontFamily: 'Ownglyph meetme',
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Title text
              const Positioned(
                left: 119,
                top: 333.05,
                child: Text(
                  '너만의 곰이를 꾸며줘!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 24,
                    fontFamily: 'Ownglyph meetme',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Orange circle behind teddy
              Positioned(
                left: 97,
                top: 404.05,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Color(0x33FF9933),
                        blurRadius: 40,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                    shape: OvalBorder(),
                  ),
                ),
              ),
              // Teddy bear image
              Positioned(
                left: 107,
                top: 381.05,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/idle_teddy.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              // Customization options row
              Positioned(
                left: 86,
                top: 628.05,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/cloth_icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        const SizedBox(
                          width: 8,
                          child: Text(
                            '옷',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Ownglyph meetme',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      children: [
                        Container(
                          width: 57,
                          height: 50,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/just_face.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        const Text(
                          '표정',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Ownglyph meetme',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/item_icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        const Text(
                          '아이템',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Ownglyph meetme',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress bar background
              Positioned(
                left: 52,
                top: 234,
                child: Container(
                  width: 280,
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
              // Progress bar fill
              Positioned(
                left: 52,
                top: 234,
                child: Container(
                  width: 117,
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
                ),
              ),
              // Progress bar border
              Positioned(
                left: 52,
                top: 234,
                child: Container(
                  width: 277.24,
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
              ),
              // Progress text
              const Positioned(
                left: 59,
                top: 211,
                child: Text(
                  '이번 약은 30%나 완주 했어',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 15,
                    fontFamily: 'Ownglyph meetme',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Mood icon background
              Positioned(
                left: 42,
                top: 98,
                child: Container(
                  width: 99,
                  height: 95,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFEDB8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              // Settings icon placeholder
              Positioned(
                left: 334,
                top: 56,
                child: Container(
                  width: 32,
                  height: 28,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 32,
                          height: 28,
                          child: const Stack(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Happy face icon (개발자 모드 트리거)
              Positioned(
                left: 61,
                top: 118,
                child: GestureDetector(
                  onLongPress: _resetApp,
                  child: Container(
                    width: 61,
                    height: 55,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/happy_face.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ), //wow
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: BottomNavBar(currentIndex: 4),
        ),
      ),
    );
  }
}
