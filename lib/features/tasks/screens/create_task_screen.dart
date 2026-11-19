import 'package:flutter/material.dart';

class VideoTaskModel {
  final String id;
  final String title;
  final String videoUrl;
  final int targetViews;
  final int rewardPoints;
  final String? ownerUid;

  VideoTaskModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.targetViews,
    this.rewardPoints = 10,
    this.ownerUid,
  });
}

class TaskService {
  static final List<VideoTaskModel> _tasks = <VideoTaskModel>[];
  static int _points = 0;

  List<VideoTaskModel> getTasks() {
    return List<VideoTaskModel>.unmodifiable(_tasks);
  }

  int addPoints({
    dynamic currentPoints,
    dynamic task,
    int? amount,
  }) {
    final int basePoints =
        currentPoints is int ? currentPoints : _points;
    final int reward = amount ??
        (task != null ? _extractReward(task) : 10);
    _points = basePoints + reward;
    return _points;
  }

  int _extractReward(dynamic task) {
    try {
      final dynamic value = task.rewardPoints;
      if (value is int) return value;
    } catch (_) {}
    try {
      final dynamic value = task.points;
      if (value is int) return value;
    } catch (_) {}
    return 10;
  }

  Future<VideoTaskModel> createTask({
    required String title,
    required String videoUrl,
    required int targetViews,
    String? ownerUid,
  }) async {
    final VideoTaskModel item = VideoTaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      videoUrl: videoUrl.trim(),
      targetViews: targetViews,
      ownerUid: ownerUid,
    );
    _tasks.add(item);
    return item;
  }
}

class CreateTaskScreen extends StatefulWidget {
  final dynamic currentPoints;
  final String? ownerUid;
  final VoidCallback? onCreated;
  final VoidCallback? onTaskCreated;

  const CreateTaskScreen({
    super.key,
    this.currentPoints,
    this.ownerUid,
    this.onCreated,
    this.onTaskCreated,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _viewsController =
      TextEditingController(text: '100');
  final TaskService _taskService = TaskService();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _viewsController.dispose();
    super.dispose();
  }

  Future<void> _submitTask() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final int views = int.tryParse(_viewsController.text.trim()) ?? 100;
      final VideoTaskModel created = await _taskService.createTask(
        title: _titleController.text,
        videoUrl: _urlController.text,
        targetViews: views <= 0 ? 100 : views,
        ownerUid: widget.ownerUid,
      );

      widget.onCreated?.call();
      widget.onTaskCreated?.call();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gorev olusturuldu.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );

      Navigator.of(context).pop(created);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F);
    const Color surfaceWhite = Color(0xFFFFFFFF);
    final String pointsText = widget.currentPoints?.toString() ?? '0';

    return Scaffold(
      backgroundColor: surfaceWhite,
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: surfaceWhite,
        title: const Text('Yeni Gorev Olustur'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryRed),
                  ),
                  child: Text(
                    'Mevcut Puan: $pointsText',
                    style: const TextStyle(
                      color: primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Video / Gorev Basligi',
                    filled: true,
                    fillColor: surfaceWhite,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Baslik girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'YouTube Video Baglantisi',
                    filled: true,
                    fillColor: surfaceWhite,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Baglanti girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _viewsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Hedef Izlenme',
                    filled: true,
                    fillColor: surfaceWhite,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitTask,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: surfaceWhite,
                            ),
                          )
                        : const Text(
                            'Gorevi Kaydet',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
