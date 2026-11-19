import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MyCampaignsScreen extends StatelessWidget {
  final String ownerUid;
  final VoidCallback onCreate;

  const MyCampaignsScreen({
    super.key,
    required this.ownerUid,
    required this.onCreate,
  });

  String _statusLabel(String status) => switch (status) {
        'active' => 'Yayında',
        'rejected' => 'Reddedildi',
        _ => 'İncelemede',
      };

  Color _statusColor(String status) => switch (status) {
        'active' => Colors.green,
        'rejected' => AppColors.primaryRed,
        _ => Colors.orange,
      };

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('campaigns')
        .where('ownerUid', isEqualTo: ownerUid)
        .limit(50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampanyalarım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Kampanyalar yüklenemedi.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.campaign_outlined, size: 60, color: AppColors.primaryRed),
                    const SizedBox(height: 12),
                    const Text(
                      'Henüz kampanyan yok.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'YouTube içeriğini topluluğa tanıtmak için ilk kampanyanı oluştur.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Kampanya oluştur'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data();
              final status = data['status'] as String? ?? 'pending';
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.softRed,
                    child: Icon(Icons.ondemand_video, color: AppColors.primaryRed),
                  ),
                  title: Text(
                    data['title'] as String? ?? 'Kampanya',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status))),
                  ),
                  trailing: status == 'pending'
                      ? IconButton(
                          tooltip: 'Sil',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Kampanya silinsin mi?'),
                                content: const Text('Bu işlem geri alınamaz.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext, false),
                                    child: const Text('Vazgeç'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(dialogContext, true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await doc.reference.delete();
                            }
                          },
                        )
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
