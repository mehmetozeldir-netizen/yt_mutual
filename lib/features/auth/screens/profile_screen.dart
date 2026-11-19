import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../admin/screens/admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  Future<void> _editName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('Profil adını düzenle'),
      content: TextField(controller: controller, maxLength: 40,
        decoration: const InputDecoration(labelText: 'Ad / kullanıcı adı')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Kaydet')),
      ],
    ));
    controller.dispose();
    if (name == null || name.trim().length < 2) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'displayName': name.trim(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    await user.updateDisplayName(name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final history = FirebaseFirestore.instance.collection('campaigns')
      .where('ownerUid', isEqualTo: user.uid).limit(30);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Profilim'),
        backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white,
        actions: [IconButton(tooltip: 'Çıkış yap',
          onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Profil yüklenemedi.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() ?? {};
          final name = data['displayName'] as String? ?? user.displayName ?? 'Yt Mutual Üyesi';
          final points = (data['points'] as num?)?.toInt() ?? 0;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              CircleAvatar(radius: 38, backgroundColor: AppColors.softRed,
                child: Text(name.isEmpty ? 'Y' : name[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primaryRed, fontSize: 28))),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(user.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: () => _editName(context, name),
                icon: const Icon(Icons.edit), label: const Text('Profili düzenle')),
            ]))),
            const SizedBox(height: 12),
            Card(color: AppColors.softRed, child: ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: AppColors.primaryRed),
              title: const Text('Puan bakiyesi'),
              trailing: Text('$points', style: const TextStyle(
                color: AppColors.darkRed, fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: const Text('YouTube izlenmesi, beğenisi veya abonesi için puan verilmez.'),
            )),
            const SizedBox(height: 18),
            const Text('Gönderdiğim içerikler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: history.snapshots(),
              builder: (context, items) {
                if (items.hasError) return const Text('Gönderi geçmişi yüklenemedi.');
                if (!items.hasData) return const Center(child: CircularProgressIndicator());
                if (items.data!.docs.isEmpty) return const Text('Henüz içerik göndermedin.');
                return Column(children: items.data!.docs.map((doc) {
                  final item = doc.data();
                  final status = item['status'] as String? ?? 'pending';
                  final label = switch (status) {
                    'active' => 'Yayında',
                    'rejected' => 'Reddedildi',
                    _ => 'Onay bekliyor',
                  };
                  return Card(child: ListTile(
                    leading: const Icon(Icons.ondemand_video, color: AppColors.primaryRed),
                    title: Text(item['title'] as String? ?? 'İçerik'),
                    subtitle: Text(label),
                    trailing: status == 'pending' ? IconButton(
                      tooltip: 'Gönderiyi sil', icon: const Icon(Icons.delete_outline),
                      onPressed: () => FirebaseFirestore.instance.collection('campaigns').doc(doc.id).delete(),
                    ) : null,
                  ));
                }).toList());
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<IdTokenResult>(
              future: user.getIdTokenResult(true),
              builder: (context, token) {
                if (token.data?.claims?['admin'] != true) return const SizedBox.shrink();
                return FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryRed),
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminScreen())),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Yönetici paneli'),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout), label: const Text('Hesaptan çıkış yap')),
          ]);
        },
      ),
    );
  }
}
