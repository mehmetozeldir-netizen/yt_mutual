import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/youtube_helper.dart';

class CreateTaskScreen extends StatefulWidget {
  final String ownerUid;
  const CreateTaskScreen({super.key, required this.ownerUid});
  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  bool _busy = false;

  @override
  void dispose() { _title.dispose(); _url.dispose(); _description.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('campaigns').add({
        'ownerUid': widget.ownerUid, 'title': _title.text.trim(),
        'youtubeUrl': _url.text.trim(), 'videoId': YouTubeHelper.extractVideoId(_url.text.trim()),
        'description': _description.text.trim(), 'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('İçerik gönderildi. Yönetici onayından sonra keşfette yayınlanacak.')));
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilemedi: ${e.message ?? e.code}')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu. Tekrar deneyin.')));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('İçerik gönder')),
    body: SafeArea(child: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('İçeriğini topluluğa tanıt. Gönderiler yayınlanmadan önce kontrol edilir.',
        style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      TextFormField(controller: _title, maxLength: 80,
        decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().length < 3 ? 'En az 3 karakter gir.' : null),
      const SizedBox(height: 14),
      TextFormField(controller: _url, keyboardType: TextInputType.url,
        decoration: const InputDecoration(labelText: 'YouTube bağlantısı', border: OutlineInputBorder()),
        validator: (v) => v == null || YouTubeHelper.extractVideoId(v.trim()) == null
          ? 'Geçerli bir YouTube video bağlantısı gir.' : null),
      const SizedBox(height: 14),
      TextFormField(controller: _description, maxLines: 4, maxLength: 500,
        decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)', border: OutlineInputBorder())),
      const SizedBox(height: 18),
      const Text('Not: İzlenme, beğeni, yorum veya abone karşılığında ödül/puan vaat edilemez.',
        style: TextStyle(color: Colors.deepOrange, fontSize: 13)),
      const SizedBox(height: 18),
      FilledButton(onPressed: _busy ? null : _submit,
        child: _busy ? const CircularProgressIndicator() : const Text('İncelemeye gönder')),
    ]))),
  );
}
