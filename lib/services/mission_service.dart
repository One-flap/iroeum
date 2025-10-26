import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MissionItem {
  final String id;
  final String title;
  bool isCompleted;
  final String date; // 날짜별로 미션 관리

  MissionItem({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'isCompleted': isCompleted,
      };

  factory MissionItem.fromJson(Map<String, dynamic> json) => MissionItem(
        id: json['id'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        isCompleted: json['isCompleted'] as bool,
      );
}

class MissionService {
  static final MissionService _instance = MissionService._internal();
  factory MissionService() => _instance;
  MissionService._internal();

  List<MissionItem> _missions = [];

  List<MissionItem> get todayMissions {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _missions.where((m) => m.date == today).toList();
  }

  // 미션 불러오기
  Future<void> loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = prefs.getStringList('custom_missions');

    if (missionsJson != null) {
      _missions = missionsJson
          .map((json) => MissionItem.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  // 미션 저장
  Future<void> saveMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = _missions.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('custom_missions', missionsJson);
  }

  // 미션 추가 (오늘 날짜로)
  Future<void> addMission(String title) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final newMission = MissionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: today,
    );
    _missions.add(newMission);
    await saveMissions();
  }

  // 미션 완료 상태 토글
  Future<void> toggleMission(String id) async {
    final index = _missions.indexWhere((item) => item.id == id);
    if (index != -1) {
      _missions[index].isCompleted = !_missions[index].isCompleted;
      await saveMissions();
    }
  }

  // 미션 삭제
  Future<void> removeMission(String id) async {
    _missions.removeWhere((item) => item.id == id);
    await saveMissions();
  }

  // 완료된 미션 개수
  int get todayCompletedCount =>
      todayMissions.where((item) => item.isCompleted).length;

  // 오늘 전체 미션 개수
  int get todayTotalCount => todayMissions.length;
}
