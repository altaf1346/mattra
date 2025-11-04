import 'dart:math';

class RetryBackoff {
  final int maxRetries;
  final Duration baseDelay;
  final double multiplier;
  final Random _rand = Random();

  RetryBackoff({
    this.maxRetries = 5,
    this.baseDelay = const Duration(seconds: 1),
    this.multiplier = 2.0,
  });

  /// Return duration for a given attempt (0-based)
  Duration getDelay(int attempt) {
    final exp = pow(multiplier, attempt);
    // jitter between -0.5..+0.5 of baseDelay
    final jitter = (_rand.nextDouble() - 0.5) * baseDelay.inMilliseconds;
    final ms = (baseDelay.inMilliseconds * exp + jitter).clamp(0, 60000).toInt();
    return Duration(milliseconds: ms);
  }
}