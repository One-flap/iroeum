import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  Map<String, int> _moodData = {}; // 날짜별 기분 데이터 (0: 기쁨, 1: 보통, 2: 슬픔)

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  // 기분 데이터 불러오기
  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    setState(() {
      _moodData.clear();
      for (var key in keys) {
        if (key.startsWith('mood_')) {
          final date = key.substring(5); // 'mood_' 제거
          final mood = prefs.getInt(key) ?? 0;
          _moodData[date] = mood;
        }
      }
    });
  }

  // 월 변경
  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
    });
  }

  // 날짜의 기분 색상 가져오기
  Color _getMoodColor(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final mood = _moodData[dateStr];

    if (mood == null) {
      return Colors.white; // 별로였어
    } else if (mood == 0) {
      return const Color(0xFFFFA500); // 기뻤어 (진한 오렌지)
    } else if (mood == 1) {
      return const Color(0xFFFFD966); // 보통이었어 (연한 오렌지)
    } else {
      return Colors.white; // 별로였어
    }
  }

  // 해당 월의 날짜 리스트 생성
  List<DateTime?> _generateCalendarDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    final List<DateTime?> days = [];
    
    // 첫 주의 빈 칸 채우기
    for (int i = 0; i < firstDay.weekday % 7; i++) {
      days.add(null);
    }
    
    // 실제 날짜 추가
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _generateCalendarDays();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDD),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      '나의 출석률',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF505050),
                        fontFamily: 'Ownglyph meetme',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calendar
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          // Month Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Color(0xFFFFA500), size: 32),
                                onPressed: () => _changeMonth(-1),
                              ),
                              Text(
                                '${_currentMonth.month}월',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFA500),
                                  fontFamily: 'Ownglyph meetme',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Color(0xFFFFA500), size: 32),
                                onPressed: () => _changeMonth(1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Weekday Headers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                                .map((day) => SizedBox(
                                      width: 40,
                                      child: Text(
                                        day,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF505050),
                                          fontFamily: 'Ownglyph meetme',
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 12),

                          // Calendar Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: calendarDays.length,
                            itemBuilder: (context, index) {
                              final date = calendarDays[index];
                              
                              if (date == null) {
                                return const SizedBox.shrink();
                              }

                              final isToday = date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;

                              return Container(
                                decoration: BoxDecoration(
                                  color: _getMoodColor(date),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isToday
                                      ? Border.all(color: const Color(0xFFFFA500), width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: const Color(0xFF505050),
                                      fontFamily: 'Ownglyph meetme',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend(const Color(0xFFFFA500), '기뻤어'),
                        const SizedBox(width: 16),
                        _buildLegend(const Color(0xFFFFD966), '보통이었어'),
                        const SizedBox(width: 16),
                        _buildLegend(Colors.white, '별로였어'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Progress Bars
                    _buildProgressSection('나의 약 복용률', 98, const Color(0xFFFFA500)),
                    const SizedBox(height: 24),
                    _buildProgressSection('나의 미션 수행률', 75, const Color(0xFFFFA500)),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            const BottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF505050),
            fontFamily: 'Ownglyph meetme',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(String title, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF505050),
                fontFamily: 'Ownglyph meetme',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA500),
                fontFamily: 'Ownglyph meetme',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
