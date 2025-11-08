import 'package:flutter_test/flutter_test.dart';
import 'package:liquifly/src/bridge/native_lib.dart';

void main() {
  group('Counter FFI Tests', () {
    test('should create counter and get initial value', () {
      final counter = Counter();
      expect(counter.value, equals(0));
      counter.dispose();
    });

    test('should increment counter', () {
      final counter = Counter();
      expect(counter.value, equals(0));

      counter.increment();
      expect(counter.value, equals(1));

      counter.increment();
      expect(counter.value, equals(2));

      counter.dispose();
    });

    test('should handle multiple increments', () {
      final counter = Counter();

      for (int i = 0; i < 10; i++) {
        counter.increment();
      }

      expect(counter.value, equals(10));
      counter.dispose();
    });

    test('should throw error when accessing disposed counter', () {
      final counter = Counter();
      counter.dispose();

      expect(() => counter.value, throwsStateError);
      expect(() => counter.increment(), throwsStateError);
    });

    test('should handle multiple counters independently', () {
      final counter1 = Counter();
      final counter2 = Counter();

      counter1.increment();
      counter1.increment();

      counter2.increment();

      expect(counter1.value, equals(2));
      expect(counter2.value, equals(1));

      counter1.dispose();
      counter2.dispose();
    });

    test('should not crash on double dispose', () {
      final counter = Counter();
      counter.dispose();

      expect(() => counter.dispose(), returnsNormally);
    });
  });
}
