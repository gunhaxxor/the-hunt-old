// import 'package:quiver/async.dart';
import 'dart:async';

// Stream<TimerThingy> untilRevealStream() { //                        <--- Stream
//   return Stream<TimerThingy>.periodic(Duration(seconds: 1),
//           (x) => TimerThingy(someValue: '$x'))
//       .take(10);
// }

class TimerThingy {
  int interval;
  int _nextInterval;
  bool _intervalChanged = false;
  Timer _timer;
  Stopwatch _stopWatch;
  void Function() callback;

  Stream<Duration> untilReveal;

  TimerThingy({this.interval, this.callback, triggerInstantly = false}) {
    print("TimerThingy created");
    this.interval = interval;
    _nextInterval = interval;
    _stopWatch = new Stopwatch();
    callback = callback;

    Duration dur = Duration(seconds: interval);
    _timer = Timer.periodic(dur, _triggerFunction);
    _stopWatch.start();
    if (triggerInstantly) {
      callback();
    }

    untilReveal = _streamFunction();
  }

  Stream<Duration> _streamFunction() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      Duration timeLeft = Duration(seconds: interval) -
          Duration(milliseconds: _stopWatch.elapsedMilliseconds);
      yield timeLeft;
      // if (timeLeft.inMilliseconds <= 0) break;
    }
  }

  void _triggerFunction(Timer timer) {
    print("TIMERTHINGY TRIGGERED");
    _stopWatch.reset();
    callback();

    if (_nextInterval != interval) {
      print("should change interval to $interval before starting next period");
      _timer.cancel();
      Duration dur = Duration(seconds: _nextInterval);
      interval = _nextInterval;
      _timer = Timer.periodic(dur, _triggerFunction);
    }
  }

  void setCallback(cb) {
    callback = cb;
  }

  int secondsLeft() {
    int secondsLeft = interval - _stopWatch.elapsedMilliseconds ~/ 1000;
    print("SECONDSLEFT: $secondsLeft");
    return secondsLeft;
  }

  void stop() {
    _timer.cancel();
    _stopWatch.stop();
  }

  changeIntervalOnNextTrigger(int interval) {
    print("timerthingy interval updated to $interval for next period!");
    _nextInterval = interval;
  }

  void changeIntervalNow(int interval) {
    _timer.cancel();
    Duration dur = Duration(seconds: interval);
    _timer = Timer.periodic(dur, (timer) {
      _stopWatch.reset();
      callback();
    });
  }
}
