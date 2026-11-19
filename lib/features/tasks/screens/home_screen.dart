import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String ownerUid;
  final String taskType;
  const HomeScreen({super.key, required this.ownerUid, this.taskType = 'İzle'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _duration = 64;
  int _seconds = _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_seconds == 0) setState(() => _seconds = _duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _changeTask() {
    _timer?.cancel();
    setState(() => _seconds = _duration);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni içerik bulunamadı. Daha sonra tekrar deneyebilirsin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWatch = widget.taskType == 'İzle';
    final isSubscribe = widget.taskType == 'Abone Ol';
    final score = isWatch ? '48' : (isSubscribe ? '32' : '16');
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
              child: Row(
                children: [
                  _Metric(icon: Icons.favorite, value: score, label: 'Puan'),
                  const Spacer(),
                  _Metric(icon: Icons.timer_outlined, value: '$_seconds', label: 'Saniye'),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.12,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isWatch ? Icons.play_circle_outline
                              : (isSubscribe ? Icons.video_library_outlined : Icons.thumb_up_alt_outlined),
                          color: Colors.white24,
                          size: 58,
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            isWatch ? 'Video oynatıcı alanı'
                                : (isSubscribe ? 'Abonelik içerikleri' : 'Beğeni içerikleri'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _changeTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A0A0A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Değiştir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _seconds == 0 ? 'Süre tamamlandı' : 'Görev süresi: $_seconds saniye',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Metric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E2E2)),
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF171717), fontSize: 25, height: 1, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
        ],
      ),
    ],
  );
}
