/// Abstraksi waktu supaya timer bisa dites & dipercepat (Panel Demo).
abstract class Clock {
  DateTime now();
}

/// Waktu simulasi: berjalan dari [start], dengan kecepatan [speed] (1x/2x/5x).
class SimClock implements Clock {
  SimClock(DateTime start) : _anchor = start, _wall = DateTime.now();

  DateTime _anchor;
  DateTime _wall;
  double _speed = 1;

  double get speed => _speed;

  set speed(double v) {
    _anchor = now();
    _wall = DateTime.now();
    _speed = v;
  }

  void reset(DateTime start) {
    _anchor = start;
    _wall = DateTime.now();
    _speed = 1;
  }

  @override
  DateTime now() {
    final real = DateTime.now().difference(_wall);
    return _anchor.add(Duration(microseconds: (real.inMicroseconds * _speed).round()));
  }
}

class ManualClock implements Clock {
  ManualClock(this._t);
  DateTime _t;

  @override
  DateTime now() => _t;

  void advance(Duration d) => _t = _t.add(d);
}
