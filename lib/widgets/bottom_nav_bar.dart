import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD966),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            index: 0,
            route: '/calendar',
            assetPath: 'assets/images/nav_calender.svg',
          ),
          _buildNavItem(
            context,
            index: 1,
            route: '/chat',
            assetPath: 'assets/images/nav_chat.svg',
          ),
          _buildNavItem(
            context,
            index: 2,
            route: '/',
            assetPath: 'assets/images/nav_home.svg',
          ),
          _buildNavItem(
            context,
            index: 3,
            route: '/star',
            assetPath: 'assets/images/nav_star.svg',
          ),
          _buildNavItem(
            context,
            index: 4,
            route: '/customize',
            assetPath: 'assets/images/nav_mypage.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required int index, required String route, required String assetPath}) {
    bool isSelected = currentIndex == index;
    return isSelected
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              assetPath,
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFF9933),
                BlendMode.srcIn,
              ),
            ),
          )
        : IconButton(
            icon: SvgPicture.asset(
              assetPath,
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFAA71B),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              context.go(route);
            },
          );
  }
}

