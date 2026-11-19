import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final String ownerUid;
  const HomeScreen({super.key, required this.ownerUid});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('campaigns')
      .where('status', isEqualTo: 'active').limit(50);
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white,
        title: const Text('Yt Mutual • Keşfet', style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('İçerikler yüklenemedi. Firestore kurallarını kontrol edin.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Padding(
            padding: EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.video_library_outlined, size: 54, color: Colors.black38),
              SizedBox(height: 12), Text('Henüz yayınlanmış içerik yok.', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 6), Text('İlk içeriği sen ekleyebilirsin.', textAlign: TextAlign.center),
            ]),
          ));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final title = data['title'] as String? ?? 'İçerik';
              final description = data['description'] as String? ?? '';
              final url = data['youtubeUrl'] as String? ?? '';
              final owner = data['ownerUid'] as String? ?? '';
              return Card(elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderLight)),
                child: Padding(padding: const EdgeInsets.all(16), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.ondemand_video, color: AppColors.primaryRed),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      if (owner == ownerUid) const Chip(label: Text('Senin içeriğin')),
                    ]),
                    if (description.isNotEmpty) ...[const SizedBox(height: 8), Text(description)],
                    const SizedBox(height: 12),
                    SelectableText(url, style: const TextStyle(color: AppColors.primaryRed)),
                    const SizedBox(height: 8),
                    const Text('İçerik keşfi ve gönüllü topluluk geri bildirimi içindir. İzlenme, beğeni veya abone karşılığında puan verilmez.',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ])),
              );
            },
          );
        },
      ),
    );
  }
}
