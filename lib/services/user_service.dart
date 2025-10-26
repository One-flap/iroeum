import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String _teddyName = '곰이';
  String _userName = '초연';
  int _userAge = 8;
  String _hospital = '조지병원';
  String _disease = '백혈병';
  String _medications = '항암제, 진통제';
  bool _isSetupComplete = false;

  String get teddyName => _teddyName;
  String get userName => _userName;
  int get userAge => _userAge;
  String get hospital => _hospital;
  String get disease => _disease;
  String get medications => _medications;
  bool get isSetupComplete => _isSetupComplete;

  // 앱 시작 시 사용자 데이터 로드
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupComplete = prefs.getBool('is_setup_complete') ?? false;
    _teddyName = prefs.getString('teddy_name') ?? '곰이';
    _userName = prefs.getString('user_name') ?? '초연';
    _userAge = prefs.getInt('user_age') ?? 8;
    _hospital = prefs.getString('hospital') ?? '조지병원';
    _disease = prefs.getString('disease') ?? '백혈병';
    _medications = prefs.getString('medications') ?? '항암제, 진통제';
  }

  // 사용자 데이터 저장 (전체)
  Future<void> saveUserData(
    String teddyName,
    String userName, {
    int? age,
    String? hospital,
    String? disease,
    String? medications,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teddy_name', teddyName);
    await prefs.setString('user_name', userName);
    if (age != null) await prefs.setInt('user_age', age);
    if (hospital != null) await prefs.setString('hospital', hospital);
    if (disease != null) await prefs.setString('disease', disease);
    if (medications != null) await prefs.setString('medications', medications);
    await prefs.setBool('is_setup_complete', true);

    _teddyName = teddyName;
    _userName = userName;
    if (age != null) _userAge = age;
    if (hospital != null) _hospital = hospital;
    if (disease != null) _disease = disease;
    if (medications != null) _medications = medications;
    _isSetupComplete = true;
  }

  // 환자 정보 업데이트 (딥링크/NFC에서 사용)
  Future<void> updatePatientInfo({
    required String userName,
    required int age,
    required String hospital,
    required String disease,
    required String medications,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userName);
    await prefs.setInt('user_age', age);
    await prefs.setString('hospital', hospital);
    await prefs.setString('disease', disease);
    await prefs.setString('medications', medications);

    _userName = userName;
    _userAge = age;
    _hospital = hospital;
    _disease = disease;
    _medications = medications;
  }

  // 모든 데이터 초기화 (개발자 모드용)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _teddyName = '곰이';
    _userName = '초연';
    _userAge = 8;
    _hospital = '조지병원';
    _disease = '백혈병';
    _medications = '항암제, 진통제';
    _isSetupComplete = false;
  }
}
