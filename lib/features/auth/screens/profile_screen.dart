import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        title: const Text('Profilim', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Çıkış yap',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profile.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Profil bilgileri yüklenemedi.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() ?? <String, dynamic>{};
          final displayName = data['displayName'] as String? ??
              user.displayName ?? 'Yt Mutual Üyesi';
          final email = data['email'] as String? ?? user.email ?? '';
          final points = (data['points'] as num?)?.toInt() ?? 0;
          final watched = (data['watchedVideosCount'] as num?)?.toInt() ?? 0;
          final completed = (data['completedTasksCount'] as num?)?.toInt() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.softRed,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Y',
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(displayName, style: const TextStyle(
                    color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: AppColors.textMuted)),
                ]),
              ),
              const SizedBox(height: 16),
              _StatCard(label: 'Puan bakiyesi', value: '$points', icon: Icons.stars),
              const SizedBox(height: 12),
              _StatCard(label: 'İzlenen video sayısı', value: '$watched',
                icon: Icons.play_circle_fill),
              const SizedBox(height: 12),
              _StatCard(label: 'Tamamlanan görev sayısı', value: '$completed',
                icon: Icons.check_circle),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _signOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Hesaptan çıkış yap'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(color: AppColors.primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.softRed,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.primaryRed, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(
        color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w500))),
      Text(value, style: const TextStyle(
        color: AppColors.darkRed, fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );
}
