import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/bucket_service.dart';
import '../services/user_service.dart';

class StarScreen extends StatefulWidget {
  const StarScreen({super.key});

  @override
  State<StarScreen> createState() => _StarScreenState();
}

class _StarScreenState extends State<StarScreen> {
  final BucketService _bucketService = BucketService();
  final TextEditingController _newBucketController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBuckets();
  }

  Future<void> _loadBuckets() async {
    await _bucketService.loadBucketList();
    setState(() {});
  }

  @override
  void dispose() {
    _newBucketController.dispose();
    super.dispose();
  }

  void _addNewBucket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFDD),
        title: const Text(
          '새로운 버킷리스트',
          style: TextStyle(
            fontFamily: 'Ownglyph meetme',
            color: Color(0xFF505050),
          ),
        ),
        content: TextField(
          controller: _newBucketController,
          decoration: const InputDecoration(
            hintText: '하고 싶은 일을 적어봐!',
            hintStyle: TextStyle(fontFamily: 'Ownglyph meetme'),
          ),
          style: const TextStyle(fontFamily: 'Ownglyph meetme'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Ownglyph meetme',
                color: Color(0xFF505050),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (_newBucketController.text.trim().isNotEmpty) {
                await _bucketService.addBucket(_newBucketController.text.trim());
                _newBucketController.clear();
                setState(() {});
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text(
              '추가',
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

  @override
  Widget build(BuildContext context) {
    final userName = UserService().userName;
    final buckets = _bucketService.bucketList;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFDD),
      body: Stack(
        children: [
          // 스크롤 가능한 콘텐츠
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // 네비게이션 바 공간 확보
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$userName이의 버킷리스트 일지',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF505050),
                            fontFamily: 'Ownglyph meetme',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Color(0xFFFAA71B),
                            size: 32,
                          ),
                          onPressed: _addNewBucket,
                        ),
                      ],
                    ),
                  ),

                  // Bucket List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: buckets.length,
                    itemBuilder: (context, index) {
                      final bucket = buckets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
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
                                child: Text(
                                  bucket.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFF505050),
                                    fontFamily: 'Ownglyph meetme',
                                    decoration: bucket.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _bucketService.toggleBucket(bucket.id);
                                  setState(() {});
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: bucket.isCompleted
                                        ? const Color(0xFFFAA71B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFFAA71B),
                                      width: 2,
                                    ),
                                  ),
                                  child: bucket.isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // "전체보기" button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // 전체보기 기능 (필요시 추가)
                        },
                        child: const Text(
                          '전체보기',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF505050),
                            fontFamily: 'Ownglyph meetme',
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Draw UI Image - 화면 폭에 맞춤
                  Image.asset(
                    'assets/images/drawui.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 네비게이션 바 - 바닥에서 살짝 띄워서 상단에 고정
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: const BottomNavBar(currentIndex: 3),
          ),
        ],
      ),
    );
  }
}
