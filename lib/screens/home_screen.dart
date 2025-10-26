import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customize_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/user_service.dart';
import '../services/mission_service.dart';


// main.dart
void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/customize',
      builder: (context, state) => const CustomizeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'idk what to do',
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'OwnGlyph Meetme',
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 221),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// home_screen.dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showMoodBox = true;

  // 미션 상태 관리
  List<bool> _missionCompleted = [false, false, false];
  int _mealCount = 0; // 밥먹고 약먹기 카운트 (0-3)

  // 검색 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _checkMoodBoxStatus();
    _loadMissionStatus();
    MissionService().loadMissions(); // 커스텀 미션 로드
  }

  // 미션 상태 불러오기
  Future<void> _loadMissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('mission_date');

    if (savedDate == today) {
      // 오늘 저장된 미션 상태 불러오기
      setState(() {
        _missionCompleted[0] = prefs.getBool('mission_0') ?? false;
        _missionCompleted[1] = prefs.getBool('mission_1') ?? false;
        _missionCompleted[2] = prefs.getBool('mission_2') ?? false;
        _mealCount = prefs.getInt('meal_count') ?? 0;
      });
    } else {
      // 새로운 날이면 미션 초기화
      await _resetMissions();
    }
  }

  // 미션 상태 저장
  Future<void> _saveMissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    await prefs.setString('mission_date', today);
    await prefs.setBool('mission_0', _missionCompleted[0]);
    await prefs.setBool('mission_1', _missionCompleted[1]);
    await prefs.setBool('mission_2', _missionCompleted[2]);
    await prefs.setInt('meal_count', _mealCount);
  }

  // 미션 초기화
  Future<void> _resetMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    setState(() {
      _missionCompleted = [false, false, false];
      _mealCount = 0;
    });

    await prefs.setString('mission_date', today);
    await prefs.setBool('mission_0', false);
    await prefs.setBool('mission_1', false);
    await prefs.setBool('mission_2', false);
    await prefs.setInt('meal_count', 0);
  }

  // 밥먹고 약먹기 미션 토글 (카운트 증가)
  void _toggleMealMission() {
    setState(() {
      if (_mealCount < 3) {
        _mealCount++;
      } else {
        _mealCount = 0;
      }
      _missionCompleted[0] = _mealCount == 3;
    });
    _saveMissionStatus();
  }

  // 일반 미션 토글
  void _toggleMission(int index) {
    setState(() {
      _missionCompleted[index] = !_missionCompleted[index];
    });
    _saveMissionStatus();
  }

  // 오늘 기분 선택 박스를 이미 봤는지 확인
  Future<void> _checkMoodBoxStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMoodDate = prefs.getString('last_mood_date');
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    if (lastMoodDate == today) {
      // 오늘 이미 기분을 선택했으면 박스를 표시하지 않음
      setState(() {
        _showMoodBox = false;
      });
    } else {
      // 오늘 처음이면 박스를 표시
      setState(() {
        _showMoodBox = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 검색 후 채팅으로 이동
  void _searchAndNavigateToChat() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.go('/chat?query=$query');
      _searchController.clear();
    }
  }

  Future<void> _onMoodSelected(int moodIndex) async {
    // 오늘 날짜 저장 및 기분 데이터 저장
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    await prefs.setString('last_mood_date', today);
    await prefs.setInt('mood_$today', moodIndex); // 0: 기쁨, 1: 보통, 2: 슬픔

    // 애니메이션으로 박스 숨기기
    _animationController.reverse().then((_) {
      setState(() {
        _showMoodBox = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      // Progress Card
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 14, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBB1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/homecard_teddy.png',
                                  width: 100,
                                  height: 100,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Color(0xFF505050),
                                            fontFamily: 'OwnGlyph Meetme',
                                          ),
                                          children: [
                                            TextSpan(text: '안녕! ${UserService().userName} 오늘은 용기 '),
                                            const TextSpan(
                                              text: '80%',
                                              style: TextStyle(
                                                color: Color(0xFFFF9933),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const TextSpan(text: ' 충전이야'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFE9A6).withOpacity(0.8),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            // 배경 (테두리 느낌)
                                            InnerShadow(
                                              shadows: [
                                                Shadow(
                                                  color: const Color(0xFFFFA400).withOpacity(0.6),
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(
                                                    color: const Color(0xFFFFEDB8),
                                                    width: 5,
                                                  ),
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFFF7E0),
                                                      Color(0xFFFFEFB3),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // 진행 바
                                            FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: 0.8, // 진행률 조정
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFFB627),
                                                      Color(0xFFFFA41B),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFFFFD580).withOpacity(0.6),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        '" 오늘은 집 가기까지 7일 남았어!"',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color(0xFF505050),
                                          fontFamily: 'OwnGlyph Meetme',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Today's Mission
                      const Text(
                        '오늘의 미션!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF505050),
                          fontFamily: 'OwnGlyph Meetme',
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Mission Items or Completion Message
                      if (_missionCompleted[0] && _missionCompleted[1] && _missionCompleted[2])
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD966),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFA500).withValues(alpha: 0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '오늘 할 일 모두 완료!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF505050),
                                fontFamily: 'OwnGlyph Meetme',
                              ),
                            ),
                          ),
                        )
                      else ...[
                        MissionItem(
                          title: '오늘 하루 3번 밥먹고 약먹기',
                          isCompleted: _missionCompleted[0],
                          completionCount: _mealCount,
                          totalCount: 3,
                          onTap: _toggleMealMission,
                        ),
                        const SizedBox(height: 6),
                        MissionItem(
                          title: '오늘 일기에 날씨 기록하기',
                          isCompleted: _missionCompleted[1],
                          onTap: () => _toggleMission(1),
                        ),
                        const SizedBox(height: 6),
                        MissionItem(
                          title: '한끼 싹싹 비워서 다 먹기',
                          isCompleted: _missionCompleted[2],
                          onTap: () => _toggleMission(2),
                        ),
                        // 커스텀 미션 추가
                        ...MissionService().todayMissions.map((mission) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: MissionItem(
                              title: mission.title,
                              isCompleted: mission.isCompleted,
                              onTap: () async {
                                await MissionService().toggleMission(mission.id);
                                setState(() {});
                              },
                            ),
                          );
                        }).toList(),
                      ],
                      const SizedBox(height: 120),

                      // Bear Character with Speech Bubble
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'assets/images/home_teddy_green.png',
                              width: 600,
                              height: 250,
                            ),
                            Positioned(
                              top: -100,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 100,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/home_bubble.svg',
                                        width: 200,
                                        height: 100,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 15),
                                        child: Text(
                                          '오늘 뭐했어??',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF505050),
                                            fontFamily: 'OwnGlyph Meetme',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search Bar (TextField)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFFFCC66),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: '${UserService().teddyName}는 너가 궁금해!',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF828282),
                                    fontFamily: 'OwnGlyph Meetme',
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'OwnGlyph Meetme',
                                ),
                                onSubmitted: (_) => _searchAndNavigateToChat(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Color(0xFFFFCC66),
                              ),
                              onPressed: _searchAndNavigateToChat,
                            ),
                          ],
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Navigation
                const BottomNavBar(currentIndex: 2),
              ],
            ),
          ),

          // Center Mood Popup
          if (_showMoodBox)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8B8),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD699).withValues(alpha: 0.8),
                                blurRadius: 40,
                                spreadRadius: 15,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '오늘 너의 기분은?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF505050),
                                  fontFamily: 'OwnGlyph Meetme',
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  MoodButton(
                                    image: 'assets/images/happy_face.png',
                                    label: '기뻐!',
                                    onTap: () => _onMoodSelected(0),
                                  ),
                                  Spacer(),
                                  MoodButton(
                                    image: 'assets/images/just_face.png',
                                    label: '보통이야',
                                    onTap: () => _onMoodSelected(1),
                                  ),
                                  Spacer(),
                                  MoodButton(
                                    image: 'assets/images/sad_face.png',
                                    label: '별로야',
                                    onTap: () => _onMoodSelected(2),
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
              },
            ),
        ],
      ),
    );
  }
}

class MissionItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final int? completionCount;
  final int? totalCount;
  final VoidCallback? onTap;

  const MissionItem({
    super.key,
    required this.title,
    required this.isCompleted,
    this.completionCount,
    this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD966),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF505050),
                  fontFamily: 'OwnGlyph Meetme',
                ),
              ),
            ),
            if (completionCount != null && totalCount != null) ...[
              Row(
                children: List.generate(
                  totalCount!,
                      (index) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      index < completionCount! ? Icons.check_circle : Icons.circle,
                      color: index < completionCount!
                          ? const Color(0xFFFF8100)
                          : const Color(0xFFFFFFFF),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ] else
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle,
                color: isCompleted ? const Color(0xFFFF8100) : const Color(0xFFFFFFFF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class MoodButton extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback? onTap;

  const MoodButton({
    super.key,
    required this.image,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  Color.fromARGB(255, 255, 200, 0), // 가운데 진한 노란색
                  Color.fromARGB(0, 255, 200, 0),   // 밖으로 갈수록 완전 투명
                ],
                stops: [0.0, 1.0], // 색 변화 비율 (0 = 중심, 1 = 끝)
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 48,
                height: 48,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF505050),
              fontFamily: 'OwnGlyph Meetme',
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Speech Bubble Painter
class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();

    // Main bubble body (rounded rectangle)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 0, size.width - 20, size.height - 20),
      const Radius.circular(20),
    );

    path.addRRect(rect);

    // Bubble tail (pointing down)
    final tailPath = Path();
    tailPath.moveTo(size.width / 2 - 10, size.height - 20);
    tailPath.lineTo(size.width / 2, size.height - 5);
    tailPath.lineTo(size.width / 2 + 10, size.height - 20);
    tailPath.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(tailPath, shadowPaint);

    // Draw bubble
    canvas.drawPath(path, paint);
    canvas.drawPath(tailPath, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFFFCC66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(tailPath, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}