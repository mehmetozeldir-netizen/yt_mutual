import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/profile_screen.dart';
import 'features/tasks/screens/create_task_screen.dart';
import 'features/tasks/screens/home_screen.dart';
import 'features/tasks/screens/my_campaigns_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const YtMutualApp());
}

class YtMutualApp extends StatelessWidget {
  const YtMutualApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Yt Mutual',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
          scaffoldBackgroundColor: AppColors.backgroundLight,
          useMaterial3: true,
        ),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _ensureProfile(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? 'Yt Mutual Üyesi',
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, auth) {
          if (auth.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = auth.data;
          if (user == null) return const AuthScreen();
          return FutureBuilder<void>(
            future: _ensureProfile(user),
            builder: (context, profile) {
              if (profile.hasError) {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Profil yüklenemedi. Firebase Firestore kurallarını kontrol edin.'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            child: const Text('Çıkış yap'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (profile.connectionState != ConnectionState.done) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return MainShellScreen(user: user);
            },
          );
        },
      );
}

class MainShellScreen extends StatefulWidget {
  final User user;
  const MainShellScreen({super.key, required this.user});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreateTaskScreen(ownerUid: widget.user.uid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(ownerUid: widget.user.uid),
      MyCampaignsScreen(ownerUid: widget.user.uid, onCreate: _openCreate),
      WalletScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index < 2
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Kampanya oluştur'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Kampanyalarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Puanlarım',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
