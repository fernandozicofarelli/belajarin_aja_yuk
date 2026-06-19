import 'package:belajarin_aja_yuk/pages/setting/settig_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animations/animations.dart';

import '../home/home_page.dart';
import '../setting/pengaturan_page.dart';
import '../chatbot/chatbot_page.dart';
import '../profil/profil_page.dart';
import '../setting/hubungi_kami_page.dart';
import '../setting/tentang_kami_page.dart';
import '../setting/kebijakan_privasi_page.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  String? _photoUrl;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadUserData();
    _initializePages(); // Inisialisasi halaman tanpa cek role
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _photoUrl = data['photoUrl'];
        });
      }
    }
  }

  void _initializePages() {
    _pages = [
      const HomePage(),
      const ChatbotPage(),
      PengaturanPage(onNavigate: _navigateToPage),
      const SettingPage(),
      const HubungiKamiPage(),
      const TentangKamiPage(),
      const KebijakanPrivasiPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToPage(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _photoUrl != null
        ? NetworkImage(_photoUrl!)
        : const AssetImage('assets/images/profile.png') as ImageProvider;

    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: Scaffold(
        appBar: AppBar(
          title: _selectedIndex == 0 ? const Text('') : null,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: _selectedIndex == 0
              ? [
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundImage: avatarImage,
                      radius: 16,
                    ),
                    onSelected: (value) async {
                      if (value == 'edit_profile') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfilPage()),
                        );
                        _loadUserData(); // Refresh foto
                      }
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem<String>(
                        value: 'edit_profile',
                        child: Text('Edit Profile'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ]
              : null,
        ),
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex > 2 ? 2 : _selectedIndex,
          onTap: (index) {
            if (index < 3) {
              _onItemTapped(index);
            }
          },
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: 'NovaAI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
