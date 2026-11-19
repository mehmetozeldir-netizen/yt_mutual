import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _moderate(BuildContext context, String id, String status) async {
    try {
      await FirebaseFirestore.instance.collection('campaigns').doc(id).update({
        'status': status,
        'moderatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': FirebaseAuth.instance.currentUser!.uid,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'active' ? 'İçerik yayınlandı.' : 'İçerik reddedildi.')));
      }
    } on FirebaseException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İşlem yapılamadı: ${e.message ?? e.code}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Yönetici • İçerik onayı'),
      backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('campaigns')
        .where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Bekleyen içerikler yüklenemedi.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Onay bekleyen içerik yok.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index], data = doc.data();
            return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data['title'] as String? ?? 'Başlıksız',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                SelectableText(data['youtubeUrl'] as String? ?? ''),
                if ((data['description'] as String? ?? '').isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 6),
                    child: Text(data['description'] as String)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => _moderate(context, doc.id, 'rejected'),
                    child: const Text('Reddet'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primaryRed),
                    onPressed: () => _moderate(context, doc.id, 'active'),
                    child: const Text('Yayınla'))),
                ]),
              ],
            )));
          },
        );
      },
    ),
  );
}
