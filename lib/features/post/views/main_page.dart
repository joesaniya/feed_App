import 'package:flutter/material.dart';
import 'package:simple_app/features/post/views/post_screen.dart';
import 'package:simple_app/features/post/widgets/bottom_bar_widget.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = <BottomNavItem>[
    BottomNavItem(svgAsset: 'assets/home.svg', label: 'Home'),
    BottomNavItem(svgAsset: 'assets/reel.svg', label: 'Reels'),
    BottomNavItem(svgAsset: 'assets/shop.svg', label: 'Shop'),
    BottomNavItem(svgAsset: 'assets/circles.svg', label: 'Circles'),
    BottomNavItem(
      svgAsset: 'assets/profile_bottom.svg',
      label: 'Profile',
      isAvatar: true,
    ),
  ];

  static const _pages = <Widget>[
    PostScreen(),
    _Placeholder('Reels'),
    _Placeholder('Shop'),
    _Placeholder('Circles'),
    _Placeholder('Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        items: _items,
        currentIndex: _index,
        iconSize: 25,
        onTap: (i) => setState(() => _index = i),
        profileImageUrl:
            'https://img.magnific.com/premium-photo/trishul-lord-shiva-maha-shivratri_723055-6008.jpg?semt=ais_hybrid&w=740&q=80', 
     
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}
