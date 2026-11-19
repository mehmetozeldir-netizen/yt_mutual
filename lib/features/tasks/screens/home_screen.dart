import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final String ownerUid;
  const HomeScreen({super.key, required this.ownerUid});

  Future<void> _openVideo(BuildContext context, String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !['youtube.com', 'www.youtube.com', 'youtu.be', 'm.youtube.com']
      .contains(uri.host.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli YouTube bağlantısı bulunamadı.')));
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('YouTube bağlantısı açılamadı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('campaigns')
      .where('status', isEqualTo: 'active').limit(50);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(
            child: Padding(padding: EdgeInsets.all(24),
              child: Text('İçerikler yüklenemedi. Firebase bağlantısını ve Firestore kurallarını kontrol edin.',
                textAlign: TextAlign.center)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.video_library_outlined, size: 58, color: AppColors.primaryRed),
              const SizedBox(height: 12),
              const Text('Henüz yayınlanmış içerik yok.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
              const SizedBox(height: 6),
              const Text('İlk içeriği sen gönderebilirsin. İçerikler yönetici onayından sonra burada görünür.',
                textAlign: TextAlign.center),
            ]),
          ));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: docs.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] as String? ?? 'İçerik';
              final description = data['description'] as String? ?? '';
              final url = data['youtubeUrl'] as String? ?? '';
              final owner = data['ownerUid'] as String? ?? '';
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderLight)),
                child: Padding(padding: const EdgeInsets.all(16), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.play_circle_fill, color: AppColors.primaryRed, size: 28),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      if (owner == ownerUid) const Chip(label: Text('Senin içeriğin')),
                    ]),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8), Text(description)],
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryRed),
                      onPressed: () => _openVideo(context, url),
                      icon: const Icon(Icons.open_in_new), label: const Text('YouTube’da aç'))),
                    const SizedBox(height: 6),
                    const Text('İçerik keşfi ve gönüllü geri bildirim içindir. İzlenme, beğeni veya abone karşılığında puan verilmez.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                )),
              );
            },
          );
        },
      );
  }
}
