import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final String videoUrl;
  final int targetViews;

  TaskItem({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.targetViews,
  });
}

class TaskService {
  static final List<TaskItem> _tasks = <TaskItem>[];

  List<TaskItem> getTasks() {
    return List<TaskItem>.unmodifiable(_tasks);
  }

  Future<void> createTask({
    required String title,
    required String videoUrl,
    required int targetViews,
  }) async {
    final TaskItem item = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      videoUrl: videoUrl.trim(),
      targetViews: targetViews,
    );
    _tasks.add(item);
  }
}

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

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
      await _taskService.createTask(
        title: _titleController.text,
        videoUrl: _urlController.text,
        targetViews: views <= 0 ? 100 : views,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gorev olusturuldu.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );

      _titleController.clear();
      _urlController.clear();
      _viewsController.text = '100';
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
