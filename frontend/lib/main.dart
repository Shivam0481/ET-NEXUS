import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/news_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const ProviderScope(child: ETNexusApp()));
}

class ETNexusApp extends StatefulWidget {
  const ETNexusApp({super.key});

  @override
  State<ETNexusApp> createState() => _ETNexusAppState();
}

class _ETNexusAppState extends State<ETNexusApp> {
  bool _isAuthenticated = false;
  String _userName = '';
  String _investorType = 'Long Term';

  void _handleAuthComplete(String name, String email, String type) {
    setState(() {
      _userName = name;
      _investorType = type;
      _isAuthenticated = true;
    });
  }

  void _handleSignOut() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ET NEXUS',
      debugShowCheckedModeBanner: false,
      theme: ETTheme.lightTheme,
      darkTheme: ETTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _isAuthenticated 
        ? MainNavigation(onSignOut: _handleSignOut, userName: _userName, investorType: _investorType)
        : AuthScreen(onAuthComplete: _handleAuthComplete),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback onSignOut;
  final String userName;
  final String investorType;
  
  const MainNavigation({
    super.key, 
    required this.onSignOut,
    required this.userName,
    required this.investorType,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ChatScreen(),
      const DiscoverScreen(),
      const NewsScreen(),
      const ProfileScreen(),
      SettingsScreen(onSignOut: widget.onSignOut),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1E293B),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFFEAB308),
          unselectedItemColor: Colors.white.withOpacity(0.4),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'CHAT'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'DISCOVER'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), activeIcon: Icon(Icons.newspaper), label: 'NEWS'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'SETTINGS'),
          ],
        ),
      ),
    );
  }
}
