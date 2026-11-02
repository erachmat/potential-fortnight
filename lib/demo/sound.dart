import 'package:audioplayers/audioplayers.dart';

/// SFX buatan sendiri (tool/gen_sfx.py). Semua error diabaikan: suara tidak boleh merusak demo.
class Sound {
  const Sound._();

  static bool enabled = true;
  static final AudioPlayer _p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static Future<void> play(String name) async {
    if (!enabled) return;
    try {
      await _p.stop();
      await _p.play(AssetSource('sfx/$name.wav'), volume: .7);
    } catch (_) {
      // abaikan
    }
  }

  static void ding() => play('order_ding');
  static void success() => play('success_chime');
  static void coin() => play('coin');
  static void tick() => play('tick');
  static void pop() => play('pop');
}
