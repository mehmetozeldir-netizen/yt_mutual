import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class WalletScreen extends StatelessWidget {
  final User user;
  const WalletScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseFirestore.instance.collection('users').doc(user.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puan cüzdanım', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: profile.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Cüzdan bilgisi yüklenemedi.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() ?? {};
          final points = (data['points'] as num?)?.toInt() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOPLAM PUAN', style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.white, size: 34),
                        const SizedBox(width: 10),
                        Text(
                          '$points',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Yt Mutual puan bakiyen', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('Puan sistemi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user_outlined, color: AppColors.primaryRed),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('Güvenli ve şeffaf puanlama', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Puan hareketleri yalnızca sunucu tarafından doğrulanmış uygulama içi işlemlerle eklenir. '
                        'YouTube izlenmesi, beğenisi veya aboneliği karşılığında puan verilmez.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.history, color: AppColors.primaryRed),
                  title: Text('Puan geçmişi'),
                  subtitle: Text('Henüz görüntülenecek doğrulanmış puan hareketi bulunmuyor.'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
