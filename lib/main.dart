import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Future<void> _menuAction(String title) async {
    switch (title) {
      case 'Puan satın al':
        _showInfo(title, 'Puan satın alma henüz etkin değil. Güvenli ödeme altyapısı kurulmadan ödeme alınmaz.');
        break;
      case 'VIP üye ol':
        _showInfo(title, 'VIP üyelik paketleri ve avantajları hazırlanıyor. Şu anda üyelik satışı yapılmıyor.');
        break;
      case 'Salla kazan':
        _showInfo(title, 'Salla Kazan özelliği henüz kullanıma açılmadı.');
        break;
      case 'Sıkça sorulan sorular':
        _showInfo(title, 'Yt Mutual; içerik keşfi ve topluluk etkileşimi için tasarlanmıştır. Puanlar yalnızca uygun uygulama içi işlemlerle verilebilir. YouTube izlenmesi, beğenisi veya aboneliği için puan verilmez.');
        break;
      case 'Gizlilik politikası':
        _showInfo(title, 'Hesap bilgilerin oturum açma ve uygulama hizmetlerini sunmak için kullanılır. Gizlilik politikası bağlantısı yayın öncesinde eklenecektir.');
        break;
      case 'Uygulamayı paylaş':
        await Clipboard.setData(const ClipboardData(text: 'Yt Mutual uygulaması'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uygulama adı panoya kopyalandı.')),
          );
        }
        break;
      case 'Uygulamayı değerlendir':
        final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.mycompany.ytmutual');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        break;
      case 'Bize ulaşın':
        final uri = Uri(scheme: 'mailto', path: 'destek@ytmutual.com', queryParameters: {'subject': 'Yt Mutual destek'});
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        break;
      case 'Çıkış yap':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Çıkış yapılsın mı?'),
            content: const Text('Hesabından çıkış yapmak istediğine emin misin?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Vazgeç')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Çıkış yap')),
            ],
          ),
        );
        if (confirmed == true) await FirebaseAuth.instance.signOut();
        break;
    }
  }

  void _openTopAction(String action) {
    if (action == 'Otomatik izle') {
      _showInfo(action, 'Otomatik izleme ve izlenme artırma işlemi yapılmaz. Videoları İzle sekmesinden kendin seçip açabilirsin.');
      setState(() => _index = 1);
    } else if (action == 'Abone ol') {
      setState(() => _index = 2);
    } else {
      setState(() => _index = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MyCampaignsScreen(ownerUid: widget.user.uid, onCreate: _openCreate),
      HomeScreen(ownerUid: widget.user.uid),
      const _CommunityInfoScreen(
        title: 'Abone ol',
        icon: Icons.person_add_alt_1,
        description: 'YouTube kanallarını kendi tercihinle ziyaret edebilirsin. Abonelik karşılığında puan verilmez ve otomatik abonelik yapılmaz.',
      ),
      const _CommunityInfoScreen(
        title: 'Beğen',
        icon: Icons.thumb_up_alt_outlined,
        description: 'İçerikleri inceleyip görüşünü özgürce belirtebilirsin. Beğeni karşılığında puan verilmez ve otomatik beğeni yapılmaz.',
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: SafeArea(
          bottom: false,
          child: Material(
            color: AppColors.primaryRed,
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          tooltip: 'Menü',
                          color: Colors.white,
                          icon: const Icon(Icons.menu, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Spacer(),
                      const Text('YT MUTUAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      const Spacer(),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots(),
                        builder: (context, snapshot) {
                          final points = (snapshot.data?.data()?['points'] as num?)?.toInt() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WalletScreen(user: widget.user))),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.stars_rounded, color: AppColors.primaryRed, size: 19),
                                    const SizedBox(width: 5),
                                    Text('$points', style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      _TopAction(icon: Icons.play_circle_outline, label: 'Otomatik izle', onTap: () => _openTopAction('Otomatik izle')),
                      _TopAction(icon: Icons.person_add_alt_1, label: 'Abone ol', onTap: () => _openTopAction('Abone ol')),
                      _TopAction(icon: Icons.thumb_up_alt_outlined, label: 'Beğen', onTap: () => _openTopAction('Beğen')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                color: AppColors.primaryRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white, size: 42),
                    const SizedBox(height: 8),
                    const Text('YT MUTUAL', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(widget.user.email ?? '', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerEntry(icon: Icons.add_card, title: 'Puan satın al', onTap: () { Navigator.pop(context); _menuAction('Puan satın al'); }),
                    _DrawerEntry(icon: Icons.workspace_premium, title: 'VIP üye ol', onTap: () { Navigator.pop(context); _menuAction('VIP üye ol'); }),
                    _DrawerEntry(icon: Icons.casino_outlined, title: 'Salla kazan', onTap: () { Navigator.pop(context); _menuAction('Salla kazan'); }),
                    const Divider(height: 1),
                    _DrawerEntry(icon: Icons.help_outline, title: 'Sıkça sorulan sorular', onTap: () { Navigator.pop(context); _menuAction('Sıkça sorulan sorular'); }),
                    _DrawerEntry(icon: Icons.privacy_tip_outlined, title: 'Gizlilik politikası', onTap: () { Navigator.pop(context); _menuAction('Gizlilik politikası'); }),
                    _DrawerEntry(icon: Icons.share_outlined, title: 'Uygulamayı paylaş', onTap: () { Navigator.pop(context); _menuAction('Uygulamayı paylaş'); }),
                    _DrawerEntry(icon: Icons.star_outline, title: 'Uygulamayı değerlendir', onTap: () { Navigator.pop(context); _menuAction('Uygulamayı değerlendir'); }),
                    _DrawerEntry(icon: Icons.mail_outline, title: 'Bize ulaşın', onTap: () { Navigator.pop(context); _menuAction('Bize ulaşın'); }),
                    const Divider(height: 1),
                    _DrawerEntry(icon: Icons.logout, title: 'Çıkış yap', color: AppColors.primaryRed, onTap: () { Navigator.pop(context); _menuAction('Çıkış yap'); }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
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
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Kampanyalarım'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle_fill), label: 'İzle'),
          NavigationDestination(icon: Icon(Icons.person_add_alt_1_outlined), selectedIcon: Icon(Icons.person_add_alt_1), label: 'Abone ol'),
          NavigationDestination(icon: Icon(Icons.thumb_up_alt_outlined), selectedIcon: Icon(Icons.thumb_up_alt), label: 'Beğen'),
        ],
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TopAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}

class _DrawerEntry extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerEntry({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryRed),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        onTap: onTap,
        dense: true,
      );
}

class _CommunityInfoScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  const _CommunityInfoScreen({required this.title, required this.icon, required this.description});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), automaticallyImplyLeading: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.primaryRed, size: 64),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ),
      );
}
