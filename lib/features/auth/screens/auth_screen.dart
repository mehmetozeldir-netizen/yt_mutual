import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (_register) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await credential.user!.updateDisplayName(_name.text.trim());
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = switch (e.code) {
        'email-already-in-use' => 'Bu e-posta zaten kayıtlı.',
        'invalid-email' => 'E-posta adresi geçersiz.',
        'weak-password' => 'Şifre en az 6 karakter olmalı.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-posta veya şifre hatalı.',
        'network-request-failed' => 'İnternet bağlantınızı kontrol edin.',
        _ => e.message ?? 'İşlem tamamlanamadı.',
      });
    } catch (_) {
      setState(() => _error = 'Bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD32F2F);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Icon(Icons.play_circle_fill, color: red, size: 64),
                  const SizedBox(height: 12),
                  const Text('Yt Mutual', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_register ? 'Yeni hesabını oluştur' : 'Hesabına giriş yap',
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 28),
                  if (_register) ...[
                    TextFormField(controller: _name, textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Adın', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().length < 2 ? 'Adını gir.' : null),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                    validator: (v) => v == null || !v.contains('@') ? 'Geçerli bir e-posta gir.' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _password, obscureText: true,
                    decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.length < 6 ? 'Şifre en az 6 karakter olmalı.' : null),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(height: 50, child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: red),
                    onPressed: _busy ? null : _submit,
                    child: _busy ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_register ? 'Hesap oluştur' : 'Giriş yap'))),
                  TextButton(onPressed: _busy ? null : () => setState(() {
                    _register = !_register; _error = null;
                  }), child: Text(_register ? 'Zaten hesabın var mı? Giriş yap' : 'Hesabın yok mu? Kayıt ol')),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
