import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/youtube_helper.dart';
import '../models/video_task_model.dart';
import '../services/task_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final int currentPoints;
  final String ownerUid;

  const CreateTaskScreen({
    super.key,
    required this.currentPoints,
    required this.ownerUid,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _rewardController = TextEditingController(text: '10');
  final _secondsController = TextEditingController(text: '30');
  final TaskService _taskService = TaskService();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _rewardController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _submitTask() {
    if (!_formKey.currentState!.validate()) return;

    final videoId = YouTubeHelper.extractVideoId(_urlController.text.trim());
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.darkRed,
          content: Text(
            'Lütfen geçerli bir YouTube video bağlantısı girin.',
            style: TextStyle(color: AppColors.cardWhite),
          ),
        ),
      );
      return;
    }

    final reward = int.tryParse(_rewardController.text.trim()) ?? 10;
    final seconds = int.tryParse(_secondsController.text.trim()) ?? 30;
    const creationCost = 20;

    final canCreate = _taskService.hasEnoughPointsForTask(
      currentPoints: widget.currentPoints,
      requiredCost: creationCost,
    );

    if (!canCreate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.darkRed,
          content: Text(
            'Görev oluşturmak için en az $creationCost puan gerekli.',
            style: TextStyle(color: AppColors.cardWhite),
          ),
        ),
      );
      return;
    }

    final newTask = VideoTaskModel(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      ownerUid: widget.ownerUid,
      youtubeUrl: _urlController.text.trim(),
      videoId: videoId,
      title: _titleController.text.trim(),
      rewardPoints: reward,
      requiredSeconds: seconds,
    );

    Navigator.pop(context, newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Yeni Görev Oluştur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  'Mevcut Puan: ${widget.currentPoints}  •  Görev Açma Bedeli: 20 Puan',
                  style: const TextStyle(
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Görev Başlığı',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık boş bırakılamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'YouTube Video Linki',
                  hintText: 'https://www.youtube.com/watch?v=...',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'YouTube bağlantısı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rewardController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Ödül Puanı',
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Süre (Saniye)',
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.cardWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitTask,
                child: const Text(
                  'Görevi Yayınla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
