import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bear Habit Tracker',
      theme: ThemeData(
        fontFamily: 'OwnGlyph Meetme',
        scaffoldBackgroundColor: const Color(0xFFFFF9E6),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// home_screen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8B8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/home_teddy.png',
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF8B7355),
                                            fontFamily: 'OwnGlyph Meetme',
                                          ),
                                          children: [
                                            TextSpan(text: '안녕! 오늘은 용기 '),
                                            TextSpan(
                                              text: '80%',
                                              style: TextStyle(
                                                color: Color(0xFFFF9933),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(text: ' 충전이야'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: 0.8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFFCC66),
                                                  Color(0xFFFF9933),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '" 오늘을 잡기가 까지 7일 남았어!"',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8B7355),
                                fontFamily: 'OwnGlyph Meetme',
                              ),
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
                          color: Color(0xFF8B7355),
                          fontFamily: 'OwnGlyph Meetme',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Mission Items
                      MissionItem(
                        title: '오늘 하루 3번 밥먹고 약먹기',
                        isCompleted: true,
                        completionCount: 1,
                        totalCount: 3,
                      ),
                      const SizedBox(height: 8),
                      MissionItem(
                        title: '오늘 일기에 날씨 기록하기',
                        isCompleted: false,
                      ),
                      const SizedBox(height: 8),
                      MissionItem(
                        title: '한끼 싹싹 비워서 다 먹기',
                        isCompleted: true,
                      ),
                      const SizedBox(height: 24),

                      // Mood Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8B8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '오늘 너의 기분은?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B7355),
                                fontFamily: 'OwnGlyph Meetme',
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MoodButton(
                                  emoji: '😊',
                                  label: '기뻐!',
                                ),
                                MoodButton(
                                  emoji: '😐',
                                  label: '보통이야',
                                ),
                                MoodButton(
                                  emoji: '😢',
                                  label: '별로야',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bear Character
                      Center(
                        child: Image.asset(
                          'assets/images/homecard_teddy.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Search Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFFFFCC66),
                            width: 2,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                '곰이는 너가 궁금해!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFCCCCCC),
                                  fontFamily: 'OwnGlyph Meetme',
                                ),
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: Color(0xFFFFCC66),
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
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC66),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 28),
                    color: Colors.white.withOpacity(0.6),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 28),
                    color: Colors.white.withOpacity(0.6),
                    onPressed: () {},
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home,
                      size: 28,
                      color: Color(0xFFFF9933),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_outline, size: 28),
                    color: Colors.white.withOpacity(0.6),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 28),
                    color: Colors.white.withOpacity(0.6),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MissionItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final int? completionCount;
  final int? totalCount;

  const MissionItem({
    super.key,
    required this.title,
    required this.isCompleted,
    this.completionCount,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8B8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF8B7355),
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
                    Icons.check_circle,
                    color: index < completionCount!
                        ? const Color(0xFFFF6B9D)
                        : const Color(0xFFFFE8B8),
                    size: 24,
                  ),
                ),
              ),
            ),
          ] else
            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? const Color(0xFFFF6B9D) : const Color(0xFFFFE8B8),
              size: 28,
            ),
        ],
      ),
    );
  }
}

class MoodButton extends StatelessWidget {
  final String emoji;
  final String label;

  const MoodButton({
    super.key,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD699),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8B7355),
            fontFamily: 'OwnGlyph Meetme',
          ),
        ),
      ],
    );
  }
}