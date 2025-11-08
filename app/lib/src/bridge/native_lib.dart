import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'native_bindings.dart';

/// Singleton для работы с нативной библиотекой
class NativeLib {
  static NativeLib? _instance;
  late final NativeLibrary _bindings;
  late final ffi.DynamicLibrary _lib;

  NativeLib._() {
    // Загружаем библиотеку
    _lib = _loadLibrary();
    _bindings = NativeLibrary(_lib);
  }

  static NativeLib get instance {
    _instance ??= NativeLib._();
    return _instance!;
  }

  NativeLibrary get bindings => _bindings;

  ffi.DynamicLibrary _loadLibrary() {
    const libName = 'liquifly';

    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      // В dev режиме ищем в core/target/debug
      try {
        return ffi.DynamicLibrary.open('core/target/debug/lib$libName.dylib');
      } catch (_) {
        // Пробуем относительный путь
        return ffi.DynamicLibrary.open('../core/target/debug/lib$libName.dylib');
      }
    } else if (Platform.isLinux) {
      return ffi.DynamicLibrary.open('lib$libName.so');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('$libName.dll');
    }
    throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
  }
}

/// Обертка над счетчиком из Rust
class Counter {
  final int _id;
  final NativeLibrary _bindings;
  bool _disposed = false;

  Counter._(this._id, this._bindings);

  /// Создать новый счетчик
  factory Counter() {
    final bindings = NativeLib.instance.bindings;
    final id = bindings.create_counter();
    return Counter._(id, bindings);
  }

  /// Увеличить счетчик на 1
  void increment() {
    _checkDisposed();
    _bindings.increment_counter(_id);
  }

  /// Получить текущее значение
  int get value {
    _checkDisposed();
    return _bindings.get_counter_value(_id);
  }

  /// Освободить ресурсы
  void dispose() {
    if (!_disposed) {
      _bindings.destroy_counter(_id);
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('Counter has been disposed');
    }
  }
}

