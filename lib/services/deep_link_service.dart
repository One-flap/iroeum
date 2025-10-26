import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'user_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // 환자 정보 저장용
  Map<String, dynamic>? _patientData;

  // BuildContext 저장 (라우팅용)
  BuildContext? _context;

  Map<String, dynamic>? get patientData => _patientData;

  // Context 등록 (앱 시작 후 호출)
  void setContext(BuildContext context) {
    _context = context;
  }

  // 딥링크 리스너 시작
  Future<void> initialize() async {
    debugPrint('DeepLinkService: Initializing...');

    // 앱이 종료된 상태에서 딥링크로 열린 경우
    final initialLink = await _appLinks.getInitialLink();
    debugPrint('DeepLinkService: initialLink = $initialLink');

    if (initialLink != null) {
      await _handleDeepLink(initialLink);
    }

    // 앱이 실행 중일 때 딥링크 수신
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('DeepLinkService: Received URI from stream: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );

    debugPrint('DeepLinkService: Initialization complete. patientData = $_patientData');
  }

  // 딥링크 처리
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Received deep link: $uri');

    // heroum://patient?name=김철수&age=8&hospital=조지병원&disease=백혈병&meds=항암제,진통제
    if (uri.scheme == 'heroum' && uri.host == 'patient') {
      final params = uri.queryParameters;

      final name = params['name'];
      final ageStr = params['age'];
      final hospital = params['hospital'];
      final disease = params['disease'];
      final meds = params['meds'];

      if (name != null && ageStr != null && hospital != null &&
          disease != null && meds != null) {
        final age = int.tryParse(ageStr);

        if (age != null) {
          debugPrint('DeepLinkService: Valid patient data found. Clearing all data...');

          // 기존 데이터 모두 삭제
          await UserService().clearAllData();
          debugPrint('DeepLinkService: Data cleared. isSetupComplete = ${UserService().isSetupComplete}');

          // 환자 정보 저장 (메모리에만, SharedPreferences는 Setup 완료 시)
          _patientData = {
            'name': name,
            'age': age,
            'hospital': hospital,
            'disease': disease,
            'medications': meds,
          };
          debugPrint('DeepLinkService: _patientData set to $_patientData');

          // UserService에 환자 정보만 저장 (is_setup_complete는 false로 유지)
          await UserService().updatePatientInfo(
            userName: name,
            age: age,
            hospital: hospital,
            disease: disease,
            medications: meds,
          );

          debugPrint('DeepLinkService: Patient data saved. isSetupComplete = ${UserService().isSetupComplete}');

          // 앱이 실행 중일 때 딥링크가 도착하면 자동으로 Setup으로 이동
          if (_context != null && _context!.mounted) {
            debugPrint('DeepLinkService: Navigating to /setup');
            _context!.go('/setup');
          }
        }
      }
    }
  }

  // 환자 데이터 초기화
  void clearPatientData() {
    _patientData = null;
  }

  // 리스너 종료
  void dispose() {
    _linkSubscription?.cancel();
  }
}
