import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_helper.dart';
import '../models/video_task_model.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();
  int _points = 50;

  final List<VideoTaskModel> _tasks = const [
    VideoTaskModel(
      id: 'task_1',
      ownerUid: 'user_a',
      youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      videoId: 'dQw4w9WgXcQ',
      title: 'Yeni Müzik Videosu — İzle & Destekle',
      rewardPoints: 15,
      requiredSeconds: 30,
    ),
    VideoTaskModel(
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

  void _completeTask(VideoTaskModel task) {
    if (_completedTaskIds.contains(task.id)) return;

    final resolvedId = YouTubeHelper.extractVideoId(task.youtubeUrl) ?? task.videoId;
    if (resolvedId.isEmpty) return;

    setState(() {
      _completedTaskIds.add(task.id);
      _points = _taskService.addPoints(currentPoints: _points, task: task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryRed,
        content: Text(
          '+${task.rewardPoints} puan eklendi ($resolvedId)',
          style: const TextStyle(color: AppColors.cardWhite),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Yt Mutual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppColors.primaryRed, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$_points Puan',
                  style: const TextStyle(
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final isDone = _completedTaskIds.contains(task.id);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDone ? AppColors.surfaceLight : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Süre: ${task.requiredSeconds} sn  •  Ödül: +${task.rewardPoints} puan',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? AppColors.cardWhite : AppColors.primaryRed,
                    foregroundColor: isDone ? AppColors.primaryRed : AppColors.cardWhite,
                    side: BorderSide(color: AppColors.primaryRed),
                  ),
                  onPressed: isDone ? null : () => _completeTask(task),
                  child: Text(isDone ? 'Tamamlandı' : 'Görevi Yap'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
