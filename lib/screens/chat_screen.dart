import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/user_service.dart';
import '../services/bucket_service.dart';
import '../services/mission_service.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuery;

  const ChatScreen({super.key, this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // 음성 인식 관련
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadMessages().then((_) {
      // 쿼리가 있으면 자동으로 전송
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendMessage(widget.initialQuery!);
        });
      }
    });
  }

  // 저장된 메시지 불러오기
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList('chat_messages');

    if (messagesJson != null && messagesJson.isNotEmpty) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          messagesJson.map((json) => ChatMessage.fromJson(jsonDecode(json))).toList(),
        );
      });
    } else {
      // 저장된 메시지가 없으면 초기 메시지 추가
      final userName = UserService().userName;
      final teddyName = UserService().teddyName;
      setState(() {
        _messages.addAll([
          ChatMessage(
            text: '$userName아, 안녕! 나는 $teddyName야! 만나서 반가워! 😊',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
          ),
        ]);
      });
      await _saveMessages();
    }
    _scrollToBottom();
  }

  // 메시지 저장
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList('chat_messages', messagesJson);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  // 음성 인식 시작/중지
  Future<void> _toggleListening() async {
    if (_isListening) {
      // 음성 인식 중지
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      // 마이크 권한 확인
      PermissionStatus status = await Permission.microphone.status;

      if (status.isDenied) {
        // 권한이 거부된 상태면 요청
        status = await Permission.microphone.request();
      }

      if (status.isPermanentlyDenied) {
        // 영구적으로 거부된 경우 설정으로 이동
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFFFFFFDD),
              title: const Text(
                '마이크 권한 필요',
                style: TextStyle(fontFamily: 'Ownglyph meetme'),
              ),
              content: const Text(
                '음성 입력을 사용하려면 앱 설정에서 마이크 권한을 허용해주세요.',
                style: TextStyle(fontFamily: 'Ownglyph meetme'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '취소',
                    style: TextStyle(fontFamily: 'Ownglyph meetme'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '설정으로 이동',
                    style: TextStyle(
                      fontFamily: 'Ownglyph meetme',
                      color: Color(0xFFFAA71B),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '마이크 권한이 필요해요',
                style: TextStyle(fontFamily: 'Ownglyph meetme'),
              ),
            ),
          );
        }
        return;
      }

      // 음성 인식 시작
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
          localeId: 'ko_KR', // 한국어 설정
        );
      }
    }
  }

  // 선물을 보낼지 판단
  bool _shouldSendGift(String userMessage, String aiResponse) {
    final lowerUser = userMessage.toLowerCase();
    final lowerAI = aiResponse.toLowerCase();

    // 축하 상황 키워드
    final celebrationKeywords = [
      '축하', '성공', '완료', '해냈', '다 먹었', '약 먹었', '미션 완료',
      '잘했', '대단', '최고', '훌륭', '멋져', '멋있', '좋아', '기뻐',
      '끝냈', '다했', '이겼', '맞았', '100점'
    ];

    // 격려 필요 상황 키워드
    final encouragementKeywords = [
      '힘들', '어려', '슬프', '우울', '피곤', '지쳐', '아프', '무서',
      '걱정', '불안', '싫어', '짜증', '화나', '속상', '외로'
    ];

    // 축하 응답 키워드
    final celebrationResponseKeywords = [
      '축하', '잘했어', '대단해', '훌륭해', '멋져', '최고', '자랑스러',
      '굉장해', '기특해', '장하다', '감동'
    ];

    // 격려 응답 키워드
    final encouragementResponseKeywords = [
      '힘내', '괜찮', '잘 될', '응원', '함께', '옆에', '걱정 마',
      '이겨낼', '할 수 있어', '용기'
    ];

    // 사용자 메시지에서 축하/격려 상황 감지
    for (var keyword in celebrationKeywords) {
      if (lowerUser.contains(keyword)) {
        return true;
      }
    }

    for (var keyword in encouragementKeywords) {
      if (lowerUser.contains(keyword)) {
        return true;
      }
    }

    // AI 응답에서 축하/격려 메시지 감지
    for (var keyword in celebrationResponseKeywords) {
      if (lowerAI.contains(keyword)) {
        return true;
      }
    }

    for (var keyword in encouragementResponseKeywords) {
      if (lowerAI.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  // 선물 보내기
  Future<void> _sendGift() async {
    await Future.delayed(const Duration(seconds: 1));

    final giftMessages = [
      '오늘 내가 너를 위해서 작은 빈 하나 선물로 줄게!',
      '너한테 꽃빈을 줄게! 받아줘!',
      '선물이야! 이거 보면 기분 좋아질 거야!',
      '너랑 채팅 할 알아가니까 너무 좋아\n선물로 줄게!',
      '오늘 너 정말 잘했어! 선물 줄게!',
      '너는 최고야! 작은 선물을 준비했어!',
    ];

    final message = giftMessages[DateTime.now().second % giftMessages.length];

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
    await _saveMessages();

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _messages.add(ChatMessage(
        text: '${UserService().teddyName}에게 "꽃빈" 을 받았어!',
        isUser: false,
        timestamp: DateTime.now(),
        isGift: true,
      ));
    });
    _scrollToBottom();
    await _saveMessages();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();
    await _saveMessages(); // 사용자 메시지 저장

    try {
      final response = await _getOpenAIResponse(text);

      // AI 응답에서 선물 보낼지 판단
      final shouldSendGift = _shouldSendGift(text, response);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      await _saveMessages(); // AI 응답 저장

      // 축하/격려가 필요한 경우 선물 보내기
      if (shouldSendGift) {
        await _sendGift();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '미안해, 지금은 대답하기 어려워. 다시 한번 말해줄래?',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      await _saveMessages(); // 에러 메시지 저장
    }
  }

  Future<String> _getOpenAIResponse(String message) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('OpenAI API key not configured');
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // Build conversation history
    final conversationHistory = _messages
        .where((msg) => !msg.isUser || msg.text != message)
        .map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();

    // 사용자 서비스에서 이름 가져오기
    final userService = UserService();
    final teddyName = userService.teddyName;
    final userName = userService.userName;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '너는 "$teddyName"라는 이름의 따뜻하고 친근한 AI 친구야. 8세 아이 $userName이와 대화하고 있어. 항상 밝고 긍정적이며, 아이의 건강과 치료를 응원해줘. 짧고 간단하게 대답하고, 이모지를 적절히 사용해서 친근하게 말해줘. $userName이가 하고 싶은 일이나 버킷리스트를 말하면 add_bucket_item 함수를 사용하고, "나 ~해야해", "~해야 돼", "~할 거야" 같이 오늘 할 일을 말하면 add_mission 함수를 사용해서 오늘의 미션에 추가해줘.'
          },
          ...conversationHistory,
          {
            'role': 'user',
            'content': message,
          }
        ],
        'tools': [
          {
            'type': 'function',
            'function': {
              'name': 'add_bucket_item',
              'description': '사용자의 버킷리스트에 새로운 항목을 추가합니다. 사용자가 하고 싶은 일이나 장기적인 목표를 말하면 이 함수를 호출하세요.',
              'parameters': {
                'type': 'object',
                'properties': {
                  'title': {
                    'type': 'string',
                    'description': '버킷리스트 항목의 제목'
                  }
                },
                'required': ['title']
              }
            }
          },
          {
            'type': 'function',
            'function': {
              'name': 'add_mission',
              'description': '오늘의 할 일 목록에 새로운 미션을 추가합니다. 사용자가 "나 ~해야해", "~해야 돼", "~할 거야" 같이 오늘 할 일을 말하면 이 함수를 호출하세요.',
              'parameters': {
                'type': 'object',
                'properties': {
                  'title': {
                    'type': 'string',
                    'description': '오늘 할 일 항목의 제목'
                  }
                },
                'required': ['title']
              }
            }
          }
        ],
        'temperature': 0.8,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final choice = data['choices'][0];
      final responseMessage = choice['message'];

      // Function calling 확인
      if (responseMessage['tool_calls'] != null) {
        final toolCall = responseMessage['tool_calls'][0];
        final functionName = toolCall['function']['name'];

        if (functionName == 'add_bucket_item') {
          final arguments = jsonDecode(toolCall['function']['arguments']);
          final title = arguments['title'] as String;

          // 버킷리스트에 추가
          await BucketService().addBucket(title);

          return '좋아! "$title" 를 버킷리스트에 추가했어! 꼭 이루자! 💪✨';
        } else if (functionName == 'add_mission') {
          final arguments = jsonDecode(toolCall['function']['arguments']);
          final title = arguments['title'] as String;

          // 오늘의 미션에 추가
          await MissionService().addMission(title);

          return '알겠어! "$title" 를 오늘의 미션에 추가했어! 화이팅! 🎯💫';
        }
      }

      return responseMessage['content']?.trim() ?? '미안해, 다시 한번 말해줄래?';
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, 0.6),
            end: Alignment(0, 1.4),
            colors: [Color(0xFFFFFFDD), Color(0xFFFFD966)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDB8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF8B7355)),
                      onPressed: () => context.go('/'),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD699),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/just_face.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserService().teddyName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B7355),
                              fontFamily: 'Ownglyph meetme',
                            ),
                          ),
                          Text(
                            'chat ${_getTimeAgo()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B7355),
                              fontFamily: 'Ownglyph meetme',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAA71B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return _buildBearMessage('...', null);
                    }
                    final message = _messages[index];

                    // 날짜 구분선 표시
                    Widget? dateSeparator;
                    if (index == 0 || !_isSameDay(_messages[index - 1].timestamp, message.timestamp)) {
                      dateSeparator = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            _formatDateSeparator(message.timestamp),
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                              fontFamily: 'Ownglyph meetme',
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (dateSeparator != null) dateSeparator,
                        message.isUser
                            ? _buildUserMessage(message.text, message.timestamp)
                            : (message.isGift
                                ? _buildGiftMessage(message, index)
                                : _buildBearMessage(message.text, message.timestamp)),
                      ],
                    );
                  },
                ),
              ),

              // Input field
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFAA71B),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: '대화 하기',
                          hintStyle: TextStyle(
                            color: Color(0xFFCCCCCC),
                            fontFamily: 'Ownglyph meetme',
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Ownglyph meetme',
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: _isListening ? SvgPicture.asset(
                        'assets/images/mic_active_icon.svg'
                      ) : SvgPicture.asset(
                          'assets/images/mic_icon.svg'
                      ),
                      onPressed: _toggleListening,
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/emoji_icon.svg',
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/images/image_icon.svg',
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBearMessage(String text, DateTime? timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD699),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/just_face.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDB8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF505050),
                      fontFamily: 'Ownglyph meetme',
                    ),
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      _formatMessageTime(timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF999999),
                        fontFamily: 'Ownglyph meetme',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 선물 메시지 빌더
  Widget _buildGiftMessage(ChatMessage message, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD699),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/just_face.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 선물 상자 (클릭 가능)
                GestureDetector(
                  onTap: () {
                    if (!message.isOpened) {
                      _showGiftPopup();
                      setState(() {
                        message.isOpened = true;
                      });
                      _saveMessages();
                    }
                  },
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: message.isOpened ? 1.0 : scale,
                        child: Opacity(
                          opacity: message.isOpened ? 0.5 : 1.0,
                          child: Image.asset(
                            'assets/images/giftbox.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      if (!message.isOpened && mounted) {
                        setState(() {}); // 애니메이션 반복
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                      fontFamily: 'Ownglyph meetme',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 선물 팝업 표시
  void _showGiftPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (context) => const _GiftPopup(),
    );

    // 3초 후 자동으로 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  Widget _buildUserMessage(String text, DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Text(
              _formatMessageTime(timestamp),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF999999),
                fontFamily: 'Ownglyph meetme',
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAA71B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Ownglyph meetme',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 메시지 시간 포맷 (오전/오후 HH:MM)
  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  // 날짜 구분선 포맷
  String _formatDateSeparator(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (messageDate == today) {
      return '오늘';
    } else if (messageDate == yesterday) {
      return '어제';
    } else {
      return DateFormat('yyyy년 M월 d일').format(timestamp);
    }
  }

  // 같은 날인지 확인
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getTimeAgo() {
    if (_messages.isEmpty) return 'now';
    final lastMessage = _messages.last;
    final diff = DateTime.now().difference(lastMessage.timestamp);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return '$minutes분 전';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours시간 전';
    } else {
      final days = diff.inDays;
      return '$days일 전';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isGift; // 선물 상자 여부
  bool isOpened; // 선물 상자가 열렸는지 여부

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isGift = false,
    this.isOpened = false,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isGift': isGift,
      'isOpened': isOpened,
    };
  }

  // JSON 역직렬화
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isGift: json['isGift'] as bool? ?? false,
      isOpened: json['isOpened'] as bool? ?? false,
    );
  }
}

// 선물 팝업 위젯
class _GiftPopup extends StatefulWidget {
  const _GiftPopup();

  @override
  State<_GiftPopup> createState() => _GiftPopupState();
}

class _GiftPopupState extends State<_GiftPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDB8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFAA71B),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFAA71B).withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '곰이에게 "꽃빈" 을 받았어!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  color: const Color(0xFF505050),
                  fontFamily: 'Ownglyph meetme',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // 꽃빈 이미지
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFAA71B).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/item_icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
