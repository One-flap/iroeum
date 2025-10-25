import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _grassController;
  late AnimationController _teddyFadeController;
  late AnimationController _bubbleController;
  late AnimationController _floatingController;

  late Animation<Offset> _grassSlideAnimation;
  late Animation<double> _teddyFadeAnimation;
  late Animation<double> _bubbleScaleAnimation;
  late Animation<Offset> _bubbleSlideAnimation;
  late Animation<double> _floatingAnimation;

  bool _isInputMode = false;
  String _teddyName = '';
  String _userName = '';
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Grass slide up animation
    _grassController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _grassSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _grassController,
      curve: Curves.easeOutCubic,
    ));

    // Teddy fade in animation
    _teddyFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _teddyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _teddyFadeController,
        curve: Curves.easeIn,
      ),
    );

    // Speech bubble bounce animation
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bubbleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.elasticOut,
      ),
    );
    _bubbleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.elasticOut,
    ));

    // Floating animation (continuous up-down)
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations sequentially
    _startInitialAnimations();
  }

  void _startInitialAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _grassController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _teddyFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _bubbleController.forward();
  }

  void _handleDoubleTap() {
    if (!_isInputMode) {
      setState(() {
        _isInputMode = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _focusNode.requestFocus();
      });
    }
  }

  void _handleSubmit(String value) async {
    if (value.trim().isNotEmpty) {
      if (_teddyName.isEmpty) {
        // 첫 번째 입력: 테디 이름
        setState(() {
          _teddyName = value.trim();
          _isInputMode = false;
          _textController.clear();
        });
        _focusNode.unfocus();
      } else {
        // 두 번째 입력: 사용자 이름, Home으로 이동
        setState(() {
          _userName = value.trim();
          _isInputMode = false;
        });
        _focusNode.unfocus();

        // UserService를 통해 이름 저장 (SharedPreferences + 메모리)
        await UserService().saveUserData(_teddyName, _userName);

        // 애니메이션이 끝난 후 Home으로 이동
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _grassController.dispose();
    _teddyFadeController.dispose();
    _bubbleController.dispose();
    _floatingController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _bubbleText {
    if (_teddyName.isEmpty) {
      return '내 이름을 지어줘!';
    } else {
      return '너 이름은 뭐야?';
    }
  }

  String get _teddyImage {
    if (_teddyName.isEmpty) {
      return 'assets/images/name_teddy.png';
    } else {
      return 'assets/images/running_teddy.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDD),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          children: [
            // Grass bottom background (slide up from bottom)
            Positioned.fill(
              child: SlideTransition(
                position: _grassSlideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SvgPicture.asset(
                    'assets/images/grass_bottom.svg',
                    width: screenWidth,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),

            // Main content
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight - MediaQuery.of(context).padding.top,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Speech bubble
                        SlideTransition(
                          position: _bubbleSlideAnimation,
                          child: ScaleTransition(
                            scale: _bubbleScaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFFEDB8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: _isInputMode
                                  ? SizedBox(
                                      width: screenWidth * 0.5,
                                      child: TextField(
                                        controller: _textController,
                                        focusNode: _focusNode,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF505050),
                                          fontSize: 24,
                                          fontFamily: 'Ownglyph meetme',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '이름 입력',
                                          hintStyle: TextStyle(
                                            color: Color(0x80505050),
                                          ),
                                        ),
                                        onSubmitted: _handleSubmit,
                                      ),
                                    )
                                  : Text(
                                      _bubbleText,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF505050),
                                        fontSize: 24,
                                        fontFamily: 'Ownglyph meetme',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Teddy image with floating animation
                        Expanded(
                          child: FadeTransition(
                            opacity: _teddyFadeAnimation,
                            child: AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatingAnimation.value),
                                  child: child,
                                );
                              },
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: _teddyName.isEmpty ? 80 : 120,
                                  ),
                                  child: Transform.rotate(
                                    angle: -0.07,
                                    child: Image.asset(
                                      _teddyImage,
                                      width: screenWidth * 0.65,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom indicator bar
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
