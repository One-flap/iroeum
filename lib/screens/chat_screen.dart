import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/user_service.dart';
import '../services/bucket_service.dart';

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
  String _currentDate = '';

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
      setState(() {
        _messages.addAll([
          ChatMessage(
            text: '$userName!',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
          ),
          ChatMessage(
            text: '안녕 오늘 잘자',
            isUser: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 11)),
          ),
          ChatMessage(
            text: '좋은 하루 보내구',
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
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('마이크 권한이 필요해요')),
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
            'content': '너는 "$teddyName"라는 이름의 따뜻하고 친근한 AI 친구야. 8세 아이 $userName이와 대화하고 있어. 항상 밝고 긍정적이며, 아이의 건강과 치료를 응원해줘. 짧고 간단하게 대답하고, 이모지를 적절히 사용해서 친근하게 말해줘. $userName이가 하고 싶은 일이나 버킷리스트를 말하면, add_bucket_item 함수를 사용해서 버킷리스트에 추가해줘.'
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
              'description': '사용자의 버킷리스트에 새로운 항목을 추가합니다. 사용자가 하고 싶은 일이나 목표를 말하면 이 함수를 호출하세요.',
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
      backgroundColor: const Color(0xFFFFFFDD),
      body: SafeArea(
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
                          : _buildBearMessage(message.text, message.timestamp),
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
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? const Color(0xFFFAA71B) : const Color(0xFF828282),
                    ),
                    onPressed: _toggleListening,
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF828282)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: Color(0xFF828282)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
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

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
