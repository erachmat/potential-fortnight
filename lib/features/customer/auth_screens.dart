import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/brand/brand.dart';
import '../../core/brand/logo.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/visuals.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/motion.dart';
import '../../data/scope.dart';
import '../../demo/sound.dart';
import '../../domain/models/models.dart';
import 'customer_app.dart';
import 'shell.dart';

void _replaceAll(BuildContext c, Widget w) => Navigator.of(c).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => w), (_) => false);

/// C-01 — Masuk.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _login() {
    final b = context.api;
    final key = _id.text.trim().toLowerCase();
    final c = b.customers.where((c) => c.email.toLowerCase() == key || c.nim == key).firstOrNull;
    if (c == null || _pw.text.isEmpty) {
      setState(() => _error = 'NIM/email atau kata sandi belum cocok. Coba lagi ya.');
      return;
    }
    b.customerId = c.id;
    if (c.status == AccountStatus.active) {
      _replaceAll(context, const CustomerShell());
    } else {
      _replaceAll(context, const PendingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
          const SizedBox(height: 24),
          const NitipMark(size: 56),
          const SizedBox(height: 20),
          RichText(text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 28, height: 1.2, color: NColors.ink600), children: [TextSpan(text: 'Masuk ke '), TextSpan(text: 'Nitip', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink))])),
          const SizedBox(height: 4),
          const Text(Brand.tagline, style: NText.body),
          const SizedBox(height: 28),
          TextField(controller: _id, decoration: const InputDecoration(hintText: 'NIM atau email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          TextField(controller: _pw, obscureText: true, decoration: const InputDecoration(hintText: 'Kata sandi'), onSubmitted: (_) => _login()),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: NText.caption.copyWith(color: NColors.danger))).animate().shakeX(hz: 6, amount: 4),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.bolt_rounded, size: 18, color: NColors.brandText),
              label: const Text('Pakai akun demo'),
              backgroundColor: NColors.brandSoft,
              side: BorderSide.none,
              onPressed: () { _id.text = '2023010145'; _pw.text = 'demo1234'; setState(() => _error = null); },
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Masuk', onPressed: _login),
          const SizedBox(height: 16),
          Center(child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen())), child: const Text.rich(TextSpan(style: NText.body, children: [TextSpan(text: 'Belum punya akun? '), TextSpan(text: 'Daftar', style: TextStyle(fontWeight: FontWeight.w700, color: NColors.brandText))])))),
          Center(child: TextButton(onPressed: CustomerHost.of(context).onExit, child: const Text('Ganti peran', style: NText.caption))),
        ]),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar(this.step);
  final int step;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 1; i <= 2; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 1 ? 6 : 0),
              child: ClipRRect(
                borderRadius: NRadius.pillBr,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: i <= step ? 1 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => LinearProgressIndicator(value: v, minHeight: 6, backgroundColor: NColors.line, color: NColors.brand),
                ),
              ),
            ),
          ),
      ]);
}

/// C-02 — Daftar 1/2: data diri.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _nim, _email, _phone, _pw]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _req(String? v, String label) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  int get _strength {
    final p = _pw.text;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('Daftar', style: NText.title)),
      body: SafeArea(
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
            const _StepBar(1),
            const SizedBox(height: 20),
            const Text('Data diri', style: NText.h1),
            const Text('Pakai data yang sama persis dengan KTM kamu ya.', style: NText.body),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ActionChip(
                avatar: const Icon(Icons.bolt_rounded, size: 18, color: NColors.brandText),
                label: const Text('Isi data contoh'),
                backgroundColor: NColors.brandSoft,
                side: BorderSide.none,
                onPressed: () => setState(() {
                  _name.text = 'Rina Ayu Lestari';
                  _nim.text = '2023010145';
                  _email.text = 'rina.ayu@unc.ac.id';
                  _phone.text = '81234567890';
                  _pw.text = 'Demo1234';
                }),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _name, decoration: const InputDecoration(hintText: 'Nama lengkap'), textCapitalization: TextCapitalization.words, validator: (v) => _req(v, 'Nama')),
            const SizedBox(height: 12),
            TextFormField(controller: _nim, decoration: const InputDecoration(hintText: 'NIM'), keyboardType: TextInputType.number, validator: (v) => _req(v, 'NIM') ?? (RegExp(r'^\d{8,12}$').hasMatch(v!.trim()) ? null : 'NIM harus 8–12 angka')),
            const SizedBox(height: 12),
            TextFormField(controller: _email, decoration: const InputDecoration(hintText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => _req(v, 'Email') ?? (RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim()) ? null : 'Format email belum benar')),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, decoration: const InputDecoration(hintText: 'No. HP', prefixText: '+62 '), keyboardType: TextInputType.phone, validator: (v) => _req(v, 'No. HP') ?? (RegExp(r'^\d{9,13}$').hasMatch(v!.trim()) ? null : 'No. HP 9–13 angka, tanpa 0 di depan')),
            const SizedBox(height: 12),
            TextFormField(controller: _pw, obscureText: true, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Kata sandi'), validator: (v) => (v == null || v.length < 8) ? 'Minimal 8 karakter' : null),
            const SizedBox(height: 8),
            Row(children: [for (var i = 0; i < 3; i++) Expanded(child: AnimatedContainer(duration: Dur.base, height: 4, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: i < _strength ? (_strength == 3 ? NColors.success : NColors.warning) : NColors.line, borderRadius: NRadius.pillBr)))]),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Lanjut',
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => KtmUploadScreen(name: _name.text.trim(), nim: _nim.text.trim(), email: _email.text.trim(), phone: '0${_phone.text.trim()}')));
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}

/// C-03 — Daftar 2/2: upload KTM.
class KtmUploadScreen extends StatefulWidget {
  const KtmUploadScreen({super.key, required this.name, required this.nim, required this.email, required this.phone});

  final String name, nim, email, phone;

  @override
  State<KtmUploadScreen> createState() => _KtmUploadScreenState();
}

class _KtmUploadScreenState extends State<KtmUploadScreen> with SingleTickerProviderStateMixin {
  Uint8List? _bytes;
  bool _demoKtm = false;
  bool _scanning = false;
  bool _ok = false;
  late final AnimationController _scan = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

  bool get _has => _bytes != null || _demoKtm;

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() { _scanning = true; _ok = false; });
    if (!reduceMotion(context)) {
      await _scan.repeat(reverse: true, count: 4).orCancel.catchError((_) {});
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (mounted) setState(() { _scanning = false; _ok = true; });
    Sound.pop();
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final f = await ImagePicker().pickImage(source: src, maxWidth: 1200, imageQuality: 80);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      setState(() { _bytes = bytes; _demoKtm = false; });
      await _startScan();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamera/galeri belum bisa dibuka. Izinkan akses dulu, atau pakai KTM contoh.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: const Text('Upload KTM', style: NText.title)),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
          const _StepBar(2),
          const SizedBox(height: 20),
          const Text('Foto KTM kamu', style: NText.h1),
          const Text('Admin akan mencocokkan data dengan KTM.', style: NText.body),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.58,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: NColors.surfaceAlt, borderRadius: NRadius.cardBr, border: Border.all(color: _ok ? NColors.success : NColors.line, width: _ok ? 2 : 1.5)),
              child: Stack(fit: StackFit.expand, children: [
                if (_bytes != null) Image.memory(_bytes!, fit: BoxFit.cover),
                if (_demoKtm) FittedBox(fit: BoxFit.cover, child: KtmCard(name: widget.name, nim: widget.nim)),
                if (!_has) const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.badge_outlined, size: 48, color: NColors.ink400), SizedBox(height: 8), Text('Belum ada foto', style: NText.body)])),
                if (_scanning)
                  AnimatedBuilder(
                    animation: _scan,
                    builder: (_, _) => Align(alignment: Alignment(0, -1 + 2 * _scan.value), child: Container(height: 3, decoration: BoxDecoration(color: NColors.brand, boxShadow: [BoxShadow(color: NColors.brand.withValues(alpha: .6), blurRadius: 12, spreadRadius: 2)]))),
                  ),
                if (_ok) const Positioned(right: 10, top: 10, child: Icon(Icons.check_circle_rounded, color: NColors.success, size: 32)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: Dur.base,
            child: Text(_scanning ? 'Mengecek kualitas foto…' : (_ok ? 'Foto jelas ✓' : 'Pastikan nama & NIM terbaca jelas, tanpa pantulan cahaya.'), key: ValueKey('$_scanning$_ok'), style: NText.caption.copyWith(color: _ok ? NColors.success : NColors.ink600)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: SecondaryButton(label: 'Kamera', icon: Icons.photo_camera_rounded, onPressed: () => _pick(ImageSource.camera))),
            const SizedBox(width: 8),
            Expanded(child: SecondaryButton(label: 'Galeri', icon: Icons.photo_library_rounded, onPressed: () => _pick(ImageSource.gallery))),
          ]),
          const SizedBox(height: 8),
          Center(child: TextButton.icon(onPressed: () { setState(() { _demoKtm = true; _bytes = null; }); _startScan(); }, icon: const Icon(Icons.bolt_rounded, size: 18), label: const Text('Pakai KTM contoh (demo)'))),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Kirim Pendaftaran',
            onPressed: (_has && !_scanning)
                ? () {
                    context.api.register(name: widget.name, nim: widget.nim, email: widget.email, phone: widget.phone);
                    _replaceAll(context, const PendingScreen());
                  }
                : null,
          ),
        ]),
      ),
    );
  }
}

/// C-04 — menunggu verifikasi; otomatis berubah saat admin memutuskan (live).
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.backend.me;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (me.status) {
            AccountStatus.pending => _Waiting(key: const ValueKey('w'), name: me.name),
            AccountStatus.active => const ActivatedScreen(key: ValueKey('a')),
            AccountStatus.rejected => _Rejected(key: const ValueKey('r'), reason: me.rejectReason ?? '-'),
          },
        ),
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(NSpace.gutter),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 120, height: 120, decoration: const BoxDecoration(color: NColors.brandSoft, shape: BoxShape.circle), child: const Icon(Icons.hourglass_top_rounded, size: 56, color: NColors.brandText))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(.94, .94), end: const Offset(1.04, 1.04), duration: 1600.ms, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          const Text('Menunggu verifikasi', style: NText.h1),
          const SizedBox(height: 8),
          const Text('Admin lagi mencocokkan data kamu dengan KTM. Biasanya kurang dari 1×24 jam. Kami kabari lewat email & WhatsApp.', style: NText.body, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextButton(onPressed: CustomerHost.of(context).onExit, child: const Text('Ganti peran')),
        ]),
      );
}

class _Rejected extends StatelessWidget {
  const _Rejected({super.key, required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(NSpace.gutter),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 110, height: 110, decoration: BoxDecoration(color: NColors.danger.withValues(alpha: .1), shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, size: 52, color: NColors.danger)),
          const SizedBox(height: 24),
          const Text('Pendaftaran belum bisa disetujui', style: NText.h1, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Alasan: $reason', style: NText.body, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Perbaiki Data', onPressed: () => _replaceAll(context, const RegisterScreen())),
        ]),
      );
}

/// C-05 — akun aktif.
class ActivatedScreen extends StatelessWidget {
  const ActivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.backend.me.name.split(' ').first;
    Widget notif(IconData i, String t, String b, Color c) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: NColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(i, color: c),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: NText.bodyStrong), Text(b, style: NText.caption)])),
          ]),
        );
    return ConfettiBurst(
      child: Padding(
        padding: const EdgeInsets.all(NSpace.gutter),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const DrawnCheck(size: 110),
          const SizedBox(height: 20),
          RichText(textAlign: TextAlign.center, text: const TextSpan(style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 28, color: NColors.ink600), children: [TextSpan(text: 'Akun kamu '), TextSpan(text: 'aktif', style: TextStyle(fontWeight: FontWeight.w800, color: NColors.ink)), TextSpan(text: '! 🎉')])),
          const SizedBox(height: 20),
          notif(Icons.mail_rounded, 'Email terkirim', 'Halo $name, akun Nitip kamu sudah aktif…', NColors.info).animate(delay: 500.ms).fadeIn().slideY(begin: .2),
          notif(Icons.chat_rounded, 'WhatsApp terkirim', 'Akun Nitip kamu sudah aktif. Selamat jajan! 🍌', NColors.success).animate(delay: 700.ms).fadeIn().slideY(begin: .2),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Mulai Jajan', onPressed: () { Sound.success(); _replaceAll(context, const CustomerShell()); }),
        ]),
      ),
    );
  }
}
