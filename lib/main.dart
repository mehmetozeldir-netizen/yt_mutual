import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/models/user_model.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/tasks/screens/create_task_screen.dart';
import 'features/tasks/screens/home_screen.dart';

void main() {
  runApp(const YtMutualApp());
}

class YtMutualApp extends StatelessWidget {
  const YtMutualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yt Mutual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        primaryColor: AppColors.primaryRed,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
          surface: AppColors.cardWhite,
        ),
        useMaterial3: true,
      ),
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  final UserModel _currentUser = const UserModel(
    uid: 'user_demo_1',
    email: 'kullanici@ytmutual.app',
    displayName: 'Yt Mutual Üyesi',
    points: 50,
    watchedVideosCount: 3,
    completedTasksCount: 3,
  );

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateTaskScreen(
            currentPoints: _currentUser.points,
            ownerUid: _currentUser.uid,
          ),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const SizedBox.shrink(),
      ProfileScreen(user: _currentUser),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_lesson),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Görev Aç',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
