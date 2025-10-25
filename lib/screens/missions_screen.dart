import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미션 목록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('미션 상세/리스트가 여기에 표시됩니다.'),
      ),
    );
  }
}

