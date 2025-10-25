import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String _teddyName = '곰이';
  String _userName = '초연';
  bool _isSetupComplete = false;

  String get teddyName => _teddyName;
  String get userName => _userName;
  bool get isSetupComplete => _isSetupComplete;

  // 앱 시작 시 사용자 데이터 로드
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupComplete = prefs.getBool('is_setup_complete') ?? false;
    _teddyName = prefs.getString('teddy_name') ?? '곰이';
    _userName = prefs.getString('user_name') ?? '초연';
  }

  // 사용자 데이터 저장
  Future<void> saveUserData(String teddyName, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teddy_name', teddyName);
    await prefs.setString('user_name', userName);
    await prefs.setBool('is_setup_complete', true);

    _teddyName = teddyName;
    _userName = userName;
    _isSetupComplete = true;
  }

  // 모든 데이터 초기화 (개발자 모드용)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _teddyName = '곰이';
    _userName = '초연';
    _isSetupComplete = false;
  }
}
