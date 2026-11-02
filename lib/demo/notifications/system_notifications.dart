import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/scope.dart';
import '../../domain/models/models.dart';

/// Notifikasi sistem Android sungguhan (heads-up) lewat flutter_local_notifications.
/// Di web tidak aktif (banner in-app sudah cukup). Semua error ditelan: tidak boleh merusak demo.
class SystemNotifier {
  const SystemNotifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static int _id = 0;

  static bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> init() async {
    if (!supported || _ready) return;
    try {
      await _plugin.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      // abaikan
    }
  }

  static Future<void> show(String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: _id++,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails('nitip_orders', 'Pesanan', channelDescription: 'Notifikasi pesanan Nitip', importance: Importance.max, priority: Priority.high),
        ),
      );
    } catch (_) {
      // abaikan
    }
  }
}

/// Menampilkan notifikasi sistem untuk setiap notifikasi baru saat app TIDAK sedang di layar.
class SystemNotifyHook extends StatefulWidget {
  const SystemNotifyHook({super.key, required this.child});
  final Widget child;

  @override
  State<SystemNotifyHook> createState() => _SystemNotifyHookState();
}

class _SystemNotifyHookState extends State<SystemNotifyHook> with WidgetsBindingObserver {
  String? _lastId;
  AppLifecycleState _state = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemNotifier.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) => _state = s;

  @override
  Widget build(BuildContext context) {
    final n = context.backend.lastNotification;
    if (n != null && n.id != _lastId) {
      _lastId = n.id;
      if (_state != AppLifecycleState.resumed && n.role != AppRole.admin) SystemNotifier.show(n.title, n.body);
    }
    return widget.child;
  }
}
