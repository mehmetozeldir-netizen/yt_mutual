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
  bool _automatic = false;

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
        _showInfo(title, 'Destek e-posta adresi henüz tanımlanmadı. Yayın öncesinde doğrulanmış iletişim adresi eklenecek.');
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
      HomeScreen(ownerUid: widget.user.uid, taskType: 'İzle'),
      HomeScreen(ownerUid: widget.user.uid, taskType: 'Abone Ol'),
      HomeScreen(ownerUid: widget.user.uid, taskType: 'Beğen'),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(104),
        child: SafeArea(
          bottom: false,
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 54,
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          tooltip: 'Menü',
                          color: const Color(0xFF1A1A1A),
                          icon: const Icon(Icons.menu, size: 27),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Text('yt mutual', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 17, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots(),
                        builder: (context, snapshot) {
                          final points = (snapshot.data?.data()?['points'] as num?)?.toInt() ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 18),
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WalletScreen(user: widget.user))),
                              child: Row(children: [
                                Text('$points', style: const TextStyle(color: Color(0xFF171717), fontSize: 16, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                const Icon(Icons.favorite, color: Color(0xFFE53935), size: 23),
                              ]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEAEAEA)),
                SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text('Otomatik', style: TextStyle(color: Color(0xFF777777), fontSize: 14)),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: _automatic,
                          activeColor: const Color(0xFFE53935),
                          onChanged: (value) => setState(() => _automatic = value),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Bildir / şikayet et',
                          onPressed: () => _showInfo('Bildirim', 'Uygunsuz içerikleri destek ekibine bildirebilirsin.'),
                          icon: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.hexagon_outlined, color: Color(0xFF777777), size: 27),
                                Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Text('!', style: TextStyle(color: Color(0xFF777777), fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.transparent,
        height: 68,
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt, color: Color(0xFFE53935)), label: 'Kampanya'),
          NavigationDestination(icon: _YoutubeNavIcon(active: false), selectedIcon: _YoutubeNavIcon(active: true), label: 'İzle'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library, color: Color(0xFFE53935)), label: 'Abone Ol'),
          NavigationDestination(icon: Icon(Icons.thumb_up_alt_outlined), selectedIcon: Icon(Icons.thumb_up_alt, color: Color(0xFFE53935)), label: 'Beğen'),
        ],
      ),
    );
  }
}

class _YoutubeNavIcon extends StatelessWidget {
  final bool active;
  const _YoutubeNavIcon({required this.active});
  @override
  Widget build(BuildContext context) => Container(
    width: 25, height: 18,
    decoration: BoxDecoration(color: active ? const Color(0xFFE53935) : const Color(0xFFBDBDBD), borderRadius: BorderRadius.circular(5)),
    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
  );
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
