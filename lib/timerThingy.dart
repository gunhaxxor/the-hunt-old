// import 'package:quiver/async.dart';
import 'dart:async';

class TimerThingy {
  int _interval;
  bool _intervalChanged = false;
  Timer _timer;
  Stopwatch _stopWatch;
  void Function() _callback;

  TimerThingy(int interval, void Function() callback, triggerInstantly) {
    _interval = interval;
    _stopWatch = new Stopwatch();
    _callback = callback;

    Duration dur = Duration(seconds: _interval);
    _timer = Timer.periodic(dur, triggerFunction);
    _stopWatch.start();
    if (triggerInstantly) {
      _callback();
    }
  }

  void triggerFunction(Timer timer) {
    _stopWatch.reset();
    _callback();

    if (_intervalChanged) {
      _intervalChanged = false;
      _timer.cancel();
      Duration dur = Duration(seconds: _interval);
      _timer = Timer.periodic(dur, triggerFunction);
    }
  }

  int secondsLeft() {
    return _interval - _stopWatch.elapsedMilliseconds ~/ 1000;
  }

  void stop() {
    _timer.cancel();
    _stopWatch.stop();
  }

  changeIntervalOnNextTrigger(int interval) {
    _intervalChanged = true;
    _interval = interval;
  }

  void changeIntervalNow(int interval) {
    _timer.cancel();
    Duration dur = Duration(seconds: interval);
    _timer = Timer.periodic(dur, (timer) {
      _stopWatch.reset();
      _callback();
    });
  }
}
