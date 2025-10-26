import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // 환자 정보 저장용
  Map<String, dynamic>? _patientData;

  Map<String, dynamic>? get patientData => _patientData;

  // 딥링크 리스너 시작
  Future<void> initialize() async {
    // 앱이 종료된 상태에서 딥링크로 열린 경우
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await _handleDeepLink(initialLink);
    }

    // 앱이 실행 중일 때 딥링크 수신
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
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
          // 환자 정보 저장
          _patientData = {
            'name': name,
            'age': age,
            'hospital': hospital,
            'disease': disease,
            'medications': meds,
          };

          // UserService에 바로 저장
          await UserService().updatePatientInfo(
            userName: name,
            age: age,
            hospital: hospital,
            disease: disease,
            medications: meds,
          );

          debugPrint('Patient data saved from deep link: $_patientData');
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
