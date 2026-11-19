import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_helper.dart';
import '../models/video_task_model.dart';

class HomeScreen extends StatelessWidget {
  final int points;
  final List<VideoTaskModel> tasks;
  final Set<String> completedTaskIds;
  final void Function(VideoTaskModel task) onCompleteTask;

  const HomeScreen({
    super.key,
    required this.points,
    required this.tasks,
    required this.completedTaskIds,
    required this.onCompleteTask,
  });

  void _handleTaskTap(BuildContext context, VideoTaskModel task) {
    if (completedTaskIds.contains(task.id)) return;

    final resolvedId =
        YouTubeHelper.extractVideoId(task.youtubeUrl) ?? task.videoId;
    if (resolvedId.isEmpty) return;

    onCompleteTask(task);

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
                  '$points Puan',
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
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isDone = completedTaskIds.contains(task.id);

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
                    backgroundColor:
                        isDone ? AppColors.cardWhite : AppColors.primaryRed,
                    foregroundColor:
                        isDone ? AppColors.primaryRed : AppColors.cardWhite,
                    side: const BorderSide(color: AppColors.primaryRed),
                  ),
                  onPressed: isDone ? null : () => _handleTaskTap(context, task),
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
