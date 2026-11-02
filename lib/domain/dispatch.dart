import 'dart:math';

import 'models/models.dart';

/// Pemilihan kurir (PLAN §6.2). Murni & deterministik.
class Dispatch {
  const Dispatch._();

  /// Kandidat: online, tidak sibuk, belum pernah ditawari/dikecualikan untuk order ini.
  /// Urut rating tertinggi; seri diacak dengan seed tetap (id order) supaya demo deterministik.
  static List<Courier> candidates(Iterable<Courier> couriers, Order order, {int seed = 7}) {
    final list = couriers.where((c) => c.online && !c.busy && !order.excludedCouriers.contains(c.id)).toList();
    final rng = Random(seed ^ order.id.hashCode);
    final tie = {for (final c in list) c.id: rng.nextInt(1 << 20)};
    list.sort((a, b) {
      final r = b.rating.compareTo(a.rating);
      return r != 0 ? r : tie[a.id]!.compareTo(tie[b.id]!);
    });
    return list;
  }

  static Courier? pick(Iterable<Courier> couriers, Order order, {int seed = 7}) {
    final c = candidates(couriers, order, seed: seed);
    return c.isEmpty ? null : c.first;
  }
}
