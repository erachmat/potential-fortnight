import 'dart:async';

import 'package:flutter/material.dart';

/// Membangun ulang tiap [interval] (untuk durasi berjalan / timer live).
class Ticking extends StatefulWidget {
  const Ticking({super.key, required this.builder, this.interval = const Duration(seconds: 1)});

  final WidgetBuilder builder;
  final Duration interval;

  @override
  State<Ticking> createState() => _TickingState();
}

class _TickingState extends State<Ticking> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(widget.interval, (_) { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
