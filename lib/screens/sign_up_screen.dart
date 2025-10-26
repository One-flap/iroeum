import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../services/deep_link_service.dart';
import '../services/user_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier(1.0);

  @override
  void initState() {
    super.initState();
    // Context 등록 (딥링크 라우팅용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DeepLinkService().setContext(context);
      }
    });
  }

  @override
  void dispose() {
    _scaleNotifier.dispose();
    super.dispose();
  }

  // NFC 태그 스캔
  Future<void> _startNFCScan() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NFC를 사용할 수 없는 기기입니다'),
            backgroundColor: Color(0xFFFAA71B),
          ),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFDD),
          title: const Text(
            'NFC 태그 스캔',
            style: TextStyle(fontFamily: 'Ownglyph meetme'),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.nfc, size: 64, color: Color(0xFFFAA71B)),
              SizedBox(height: 16),
              Text(
                'NFC 태그를 기기 뒷면에 가까이 대주세요',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Ownglyph meetme'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                NfcManager.instance.stopSession();
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Ownglyph meetme'),
              ),
            ),
          ],
        ),
      );
    }

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          // NFC 태그의 전체 데이터를 문자열로 변환 시도
          debugPrint('NFC Tag discovered: ${tag.data}');

          // tag.data의 각 키를 순회하며 NDEF 데이터 찾기
          final tagData = tag.data as Map<String, dynamic>;
          dynamic ndefData;

          // 일반적인 NDEF 키들 확인
          for (final key in ['ndef', 'ndefformatable', 'mifareclassic', 'isodep']) {
            if (tagData.containsKey(key)) {
              ndefData = tagData[key];
              if (ndefData != null) break;
            }
          }

          if (ndefData == null) {
            debugPrint('NFC tag is not NDEF formatted');
            return;
          }

          final cachedMessage = ndefData['cachedMessage'];
          if (cachedMessage == null) {
            debugPrint('No cached NDEF message found');
            return;
          }

          final records = cachedMessage['records'] as List?;
          if (records == null || records.isEmpty) {
            debugPrint('No NDEF records found');
            return;
          }

          for (final record in records) {
            final payload = record['payload'] as List<int>?;
            if (payload == null) continue;

            // payload를 문자열로 변환
            final payloadStr = utf8.decode(payload, allowMalformed: true);
            debugPrint('NFC Payload: $payloadStr');

            // URL 찾기
            if (payloadStr.contains('heroum://patient')) {
              final heroumIndex = payloadStr.indexOf('heroum://patient');
              final cleanUrl = payloadStr.substring(heroumIndex);

              // 첫 번째 공백이나 특수문자까지만 URL로 인식
              final endIndex = cleanUrl.indexOf(RegExp(r'[\s\x00-\x1F]'));
              final finalUrl = endIndex > 0 ? cleanUrl.substring(0, endIndex) : cleanUrl;

              debugPrint('Parsed URL: $finalUrl');

              try {
                final uri = Uri.parse(finalUrl);
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
                    NfcManager.instance.stopSession();
                    if (mounted) {
                      Navigator.pop(context);

                      // 확인 다이얼로그 표시
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFFFFFFDD),
                          title: const Text(
                            'NFC 태그 인식',
                            style: TextStyle(fontFamily: 'Ownglyph meetme'),
                          ),
                          content: Text(
                            '$name님의 정보가 인식되었습니다.\n\n기존 데이터를 지우고 새로 설정하시겠습니까?',
                            style: const TextStyle(fontFamily: 'Ownglyph meetme'),
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
                                '진행',
                                style: TextStyle(
                                  fontFamily: 'Ownglyph meetme',
                                  color: Color(0xFFFAA71B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        // 기존 데이터 모두 삭제
                        await UserService().clearAllData();

                        // 환자 정보 저장
                        await UserService().updatePatientInfo(
                          userName: name,
                          age: age,
                          hospital: hospital,
                          disease: disease,
                          medications: meds,
                        );

                        if (mounted) {
                          // NFC 태그 성공 알림
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('환자 정보가 등록되었습니다'),
                              backgroundColor: Color(0xFF4CAF50),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // 잠시 대기 후 Setup으로 이동
                          await Future.delayed(const Duration(milliseconds: 500));
                          context.go('/setup');
                        }
                      }
                    }
                    return;
                  }
                }
              } catch (parseError) {
                debugPrint('URL parse error: $parseError');
              }
            }
          }

          // 태그를 찾았지만 유효한 데이터가 없으면
          NfcManager.instance.stopSession();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('올바른 환자 정보가 없습니다'),
                backgroundColor: Color(0xFFFAA71B),
              ),
            );
          }
        } catch (e) {
          debugPrint('NFC error: $e');
          NfcManager.instance.stopSession();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('NFC 태그 읽기 실패: $e'),
                backgroundColor: const Color(0xFFFAA71B),
              ),
            );
          }
        }
      },
    );
  }

  // QR 코드 스캔
  void _startQRScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _QRScannerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.50, -0.00),
            end: Alignment(0.50, 1.00),
            colors: [Color(0xFFFFFFDD), Color(0xFFFFD966)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Sign Up Title
                  const Text(
                    '로그인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email input
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFFAA71B)),
                        borderRadius: BorderRadius.circular(32.5),
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '이메일',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 27, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Password input
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF9F9F9),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFFAA71B)),
                        borderRadius: BorderRadius.circular(32.5),
                      ),
                    ),
                    child: const TextField(
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Forget password
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'forget password?',
                      style: TextStyle(
                        color: Color(0xFF6B6D6F),
                        fontSize: 13,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Login button
                  GestureDetector(
                    onTapDown: (_) => _scaleNotifier.value = 0.9,
                    onTapUp: (_) async {
                      _scaleNotifier.value = 1.1;
                      await Future.delayed(const Duration(milliseconds: 80));
                      _scaleNotifier.value = 1.0;
                      context.go('/setup');
                    },
                    onTapCancel: () => _scaleNotifier.value = 1.0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _scaleNotifier,
                      builder: (context, scale, child) => AnimatedScale(
                        scale: scale,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOutBack,
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAA71B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // "or sign up with" section
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Color(0xFFFAA71B)),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            color: Color(0xFF6B6D6F),
                            fontSize: 10,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Color(0xFFFAA71B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Social icons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/google.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 22),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/kakaotalk.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 22),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: SvgPicture.asset(
                          'assets/images/naver.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // NFC and QR buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // NFC 태그 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: _startNFCScan,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6CB),
                              border: Border.all(
                                color: const Color(0xFFFAA71B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.nfc,
                                  color: Color(0xFFFAA71B),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'NFC 태그',
                                  style: TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 14,
                                    fontFamily: 'Ownglyph meetme',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // QR 코드 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: _startQRScan,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6CB),
                              border: Border.all(
                                color: const Color(0xFFFAA71B),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  color: Color(0xFFFAA71B),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'QR 코드',
                                  style: TextStyle(
                                    color: Color(0xFF505050),
                                    fontSize: 14,
                                    fontFamily: 'Ownglyph meetme',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  }
}

// QR 스캐너 화면
class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _isProcessing = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.startsWith('heroum://patient')) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final uri = Uri.parse(code);
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
              // 스캐너를 먼저 중지
              await _controller?.stop();

              if (mounted) {
                Navigator.pop(context);

                // 확인 다이얼로그 표시
                final confirmed = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFFFFFFDD),
                    title: const Text(
                      'QR 코드 인식',
                      style: TextStyle(fontFamily: 'Ownglyph meetme'),
                    ),
                    content: Text(
                      '$name님의 정보가 인식되었습니다.\n\n기존 데이터를 지우고 새로 설정하시겠습니까?',
                      style: const TextStyle(fontFamily: 'Ownglyph meetme'),
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
                          '진행',
                          style: TextStyle(
                            fontFamily: 'Ownglyph meetme',
                            color: Color(0xFFFAA71B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  // 기존 데이터 모두 삭제
                  await UserService().clearAllData();

                  // 환자 정보 저장
                  await UserService().updatePatientInfo(
                    userName: name,
                    age: age,
                    hospital: hospital,
                    disease: disease,
                    medications: meds,
                  );

                  if (mounted) {
                    // QR 스캔 성공 알림
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('환자 정보가 등록되었습니다'),
                        backgroundColor: Color(0xFF4CAF50),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // 잠시 대기 후 Setup으로 이동
                    await Future.delayed(const Duration(milliseconds: 500));
                    context.go('/setup');
                  }
                }
              }
            }
          }
        } catch (e) {
          debugPrint('QR code processing error: $e');
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('QR 코드 처리 실패: $e'),
                backgroundColor: const Color(0xFFFAA71B),
              ),
            );
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDD),
      appBar: AppBar(
        title: const Text(
          'QR 코드 스캔',
          style: TextStyle(fontFamily: 'Ownglyph meetme'),
        ),
        backgroundColor: const Color(0xFFFFFFDD),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFAA71B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
