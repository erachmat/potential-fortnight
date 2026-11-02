import 'package:flutter/material.dart';

import '../../core/design_system/components.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/format.dart';
import '../../core/motion/effects.dart';
import '../../core/motion/odometer.dart';
import '../../data/scope.dart';
import '../../domain/models/models.dart';
import '../../domain/wallet.dart';

/// K-07 — saldo & mutasi.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final id = b.courierId;
    final entries = b.ledger.where((e) => e.courierId == id).toList().reversed.take(30).toList();
    return Scaffold(
      backgroundColor: NColors.surfaceAlt,
      appBar: AppBar(title: const Text('Saldo', style: NText.title), backgroundColor: NColors.surfaceAlt, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
        NCard(
          color: NColors.ink,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Saldo tersedia', style: NText.caption.copyWith(color: Colors.white70)),
            const SizedBox(height: 4),
            RupiahText(b.availableOf(id), size: 36, weight: FontWeight.w800, color: Colors.white),
            if (b.heldOf(id) > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Ditahan untuk penarikan: ${rupiah(b.heldOf(id))}', style: NText.caption.copyWith(color: NColors.brand))),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Tukar Saldo', light: true, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WithdrawScreen()))),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Mutasi', style: NText.h2),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          const NCard(child: Text('Belum ada mutasi.', style: NText.body))
        else
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NCard(
                child: Row(children: [
                  CircleAvatar(backgroundColor: (e.amount >= 0 ? NColors.success : NColors.danger).withValues(alpha: .12), child: Icon(e.amount >= 0 ? Icons.south_west_rounded : Icons.north_east_rounded, color: e.amount >= 0 ? NColors.success : NColors.danger, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.note, style: NText.bodyStrong), Text(clock(e.at), style: NText.caption)])),
                  Text(rupiah(e.amount, sign: true), style: NText.number(15, color: e.amount >= 0 ? NColors.success : NColors.danger)),
                ]),
              ),
            ),
      ]),
    );
  }
}

/// K-08 — tukar saldo; status live dari admin.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amount = TextEditingController();
  String _dest = 'GoPay';
  String? _error;
  String? _submittedId;
  int _shake = 0;

  static const _dests = ['GoPay', 'OVO', 'DANA', 'Transfer bank', 'Tunai ke admin'];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int get _value => int.tryParse(_amount.text.replaceAll('.', '')) ?? 0;

  void _submit() {
    final b = context.api;
    final err = b.requestWithdrawal(b.courierId, _value, _dest);
    if (err != null) {
      setState(() { _error = err; _shake++; });
      return;
    }
    setState(() { _error = null; _submittedId = b.withdrawals.first.id; });
  }

  @override
  Widget build(BuildContext context) {
    final b = context.backend;
    final avail = b.availableOf(b.courierId);
    final w = _submittedId == null ? null : b.withdrawals.where((w) => w.id == _submittedId).firstOrNull;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Tukar Saldo', style: NText.title), backgroundColor: Colors.white, elevation: 0),
      body: w != null ? _Status(w: w) : ListView(padding: const EdgeInsets.all(NSpace.gutter), children: [
        Text('Saldo tersedia ${rupiah(avail)}', style: NText.body),
        const SizedBox(height: 12),
        TextField(controller: _amount, keyboardType: TextInputType.number, onChanged: (_) => setState(() => _error = null), decoration: InputDecoration(hintText: 'Nominal (min. Rp10.000)', prefixText: 'Rp ', errorText: _error)).shakeOn(_shake),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final v in [50000, 100000]) ActionChip(label: Text(rupiah(v)), onPressed: () => setState(() => _amount.text = '$v')),
          ActionChip(label: const Text('Semua'), onPressed: () => setState(() => _amount.text = '$avail')),
        ]),
        const SizedBox(height: 20),
        const Text('Tujuan', style: NText.title),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final d in _dests) ChoiceChip(label: Text(d), selected: _dest == d, onSelected: (_) => setState(() => _dest = d))]),
        const SizedBox(height: 28),
        SlideToConfirm(label: 'Geser untuk ajukan ${_value >= Wallet.minWithdrawal ? rupiah(_value) : ''}'.trim(), onConfirmed: _submit),
      ]),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.w});
  final Withdrawal w;

  @override
  Widget build(BuildContext context) {
    final step = switch (w.status) { WithdrawalStatus.requested => 0, WithdrawalStatus.approved => 1, WithdrawalStatus.paid => 2, WithdrawalStatus.rejected => -1 };
    Widget row(String t, int i) {
      final done = step >= i;
      return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [AnimatedContainer(duration: const Duration(milliseconds: 400), width: 28, height: 28, decoration: BoxDecoration(color: done ? NColors.success : Colors.white, shape: BoxShape.circle, border: Border.all(color: done ? NColors.success : NColors.line, width: 2)), child: done ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null), const SizedBox(width: 12), Text(t, style: done ? NText.bodyStrong : NText.body)]));
    }
    return Padding(
      padding: const EdgeInsets.all(NSpace.gutter),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${rupiah(w.amount)} ke ${w.destination}', style: NText.h2),
        const SizedBox(height: 16),
        if (step == -1) const StatusBadge('Ditolak admin', color: NColors.danger) else ...[row('Diajukan', 0), row('Disetujui admin', 1), row('Sudah dibayar', 2)],
        const Spacer(),
        SecondaryButton(label: 'Kembali', onPressed: () => Navigator.of(context).pop()),
      ]),
    );
  }
}
