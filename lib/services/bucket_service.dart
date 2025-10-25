import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BucketItem {
  final String id;
  final String title;
  bool isCompleted;

  BucketItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory BucketItem.fromJson(Map<String, dynamic> json) => BucketItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool,
      );
}

class BucketService {
  static final BucketService _instance = BucketService._internal();
  factory BucketService() => _instance;
  BucketService._internal();

  List<BucketItem> _bucketList = [];

  List<BucketItem> get bucketList => _bucketList;

  // 버킷리스트 불러오기
  Future<void> loadBucketList() async {
    final prefs = await SharedPreferences.getInstance();
    final bucketJson = prefs.getStringList('bucket_list');

    if (bucketJson != null) {
      _bucketList = bucketJson
          .map((json) => BucketItem.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  // 버킷리스트 저장
  Future<void> saveBucketList() async {
    final prefs = await SharedPreferences.getInstance();
    final bucketJson = _bucketList.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('bucket_list', bucketJson);
  }

  // 버킷리스트 추가
  Future<void> addBucket(String title) async {
    final newItem = BucketItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _bucketList.add(newItem);
    await saveBucketList();
  }

  // 버킷리스트 완료 상태 토글
  Future<void> toggleBucket(String id) async {
    final index = _bucketList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _bucketList[index].isCompleted = !_bucketList[index].isCompleted;
      await saveBucketList();
    }
  }

  // 버킷리스트 삭제
  Future<void> removeBucket(String id) async {
    _bucketList.removeWhere((item) => item.id == id);
    await saveBucketList();
  }

  // 완료된 버킷 개수
  int get completedCount => _bucketList.where((item) => item.isCompleted).length;

  // 전체 버킷 개수
  int get totalCount => _bucketList.length;
}
