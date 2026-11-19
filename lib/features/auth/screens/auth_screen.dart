import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() { _busy = true; _error = null; });
    try {
      final googleUser = await GoogleSignIn(scopes: const ['email']).signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Google ile giriş yapılamadı.');
    } catch (e) {
      if (mounted) setState(() => _error =
        'Google girişi başarısız. Firebase Google sağlayıcısı ve SHA-1 ayarlarını kontrol edin.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD71920);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: red, size: 82),
                  const SizedBox(height: 14),
                  const Text('YT MUTUAL', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text('İçerik üreticileri birlikte büyür.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
                  const SizedBox(height: 38),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _signInWithGoogle,
                      icon: _busy
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.account_circle_outlined, color: Colors.black87),
                      label: Text(_busy ? 'Bağlanıyor…' : 'Google ile devam et',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFDADCE0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center,
                      style: const TextStyle(color: red, fontSize: 13)),
                  ],
                  const SizedBox(height: 22),
                  const Text('Devam ederek kullanım koşullarını ve gizlilik politikasını kabul etmiş olursun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
