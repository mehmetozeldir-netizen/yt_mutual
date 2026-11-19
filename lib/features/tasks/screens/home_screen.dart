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
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.taskType} bölümü için yeni içerik aranıyor.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskIcon = widget.taskType == 'Abone Ol'
        ? Icons.video_library_outlined
        : widget.taskType == 'Beğen'
            ? Icons.thumb_up_alt_outlined
            : Icons.play_circle_outline;

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.12,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(taskIcon, color: Colors.white24, size: 58),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            widget.taskType == 'İzle'
                                ? 'Video oynatıcı alanı'
                                : widget.taskType == 'Abone Ol'
                                    ? 'Kanal keşif alanı'
                                    : 'İçerik keşif alanı',
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
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _Metric(icon: Icons.favorite, value: '48', label: 'Puan'),
                  _Metric(icon: Icons.timer_outlined, value: '$_seconds', label: 'Saniye'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
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
              padding: const EdgeInsets.only(bottom: 10, top: 2),
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
