import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/models/user_model.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/tasks/models/video_task_model.dart';
import 'features/tasks/screens/create_task_screen.dart';
import 'features/tasks/screens/home_screen.dart';
import 'features/tasks/services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  final TaskService _taskService = TaskService();
  int _selectedIndex = 0;

  UserModel _currentUser = const UserModel(
    uid: 'user_demo_1',
    email: 'kullanici@ytmutual.app',
    displayName: 'Yt Mutual Üyesi',
    points: 50,
    watchedVideosCount: 3,
    completedTasksCount: 3,
  );

  final List<VideoTaskModel> _tasks = [
    const VideoTaskModel(
      id: 'task_1',
      ownerUid: 'user_a',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      videoId: 'dQw4w9WgXcQ',
      title: 'Yeni Müzik Videosu — İzle & Destekle',
      rewardPoints: 15,
      requiredSeconds: 30,
    ),
    const VideoTaskModel(
      id: 'task_2',
      ownerUid: 'user_b',
      youtubeUrl: 'https://youtu.be/9bZkp7q19f0',
      videoId: '9bZkp7q19f0',
      title: 'Akustik Performans Kaydı',
      rewardPoints: 20,
      requiredSeconds: 45,
    ),
  ];

  final Set<String> _completedTaskIds = {};

  void _handleCompleteTask(VideoTaskModel task) {
    if (_completedTaskIds.contains(task.id)) return;

    final updatedPoints = _taskService.addPoints(
      currentPoints: _currentUser.points,
      task: task,
    );

    setState(() {
      _completedTaskIds.add(task.id);
      _currentUser = _currentUser.copyWith(
        points: updatedPoints,
        watchedVideosCount: _currentUser.watchedVideosCount + 1,
        completedTasksCount: _currentUser.completedTasksCount + 1,
      );
    });
  }

  Future<void> _openCreateTask() async {
    final createdTask = await Navigator.push<VideoTaskModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(
          currentPoints: _currentUser.points,
          ownerUid: _currentUser.uid,
        ),
      ),
    );

    if (createdTask != null && mounted) {
      const creationCost = 20;
      setState(() {
        _tasks.insert(0, createdTask);
        _currentUser = _currentUser.copyWith(
          points: (_currentUser.points - creationCost).clamp(0, 999999),
        );
        _selectedIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryRed,
          content: Text(
            'Yeni görev yayınlandı (-20 puan)',
            style: TextStyle(color: AppColors.cardWhite),
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _openCreateTask();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        points: _currentUser.points,
        tasks: _tasks,
        completedTaskIds: _completedTaskIds,
        onCompleteTask: _handleCompleteTask,
      ),
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
