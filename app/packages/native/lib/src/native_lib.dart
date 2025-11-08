import 'dart:ffi' as ffi;
import 'dart:io' show Platform, File, Directory;

import 'native_bindings.dart';

/// Singleton для работы с нативной библиотекой
class NativeLib {
  static NativeLib? _instance;
  late final NativeLibrary _bindings;
  late final ffi.DynamicLibrary _lib;

  NativeLib._() {
    _lib = _loadLibrary();
    _bindings = NativeLibrary(_lib);
  }

  static NativeLib get instance {
    _instance ??= NativeLib._();
    return _instance!;
  }

  NativeLibrary get bindings => _bindings;

  ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libliquifly.so');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    } else if (Platform.isMacOS) {
      return _loadMacOSLibrary();
    } else if (Platform.isLinux) {
      return _loadLinuxLibrary();
    } else if (Platform.isWindows) {
      return _loadWindowsLibrary();
    }
    throw UnsupportedError(
      'Platform ${Platform.operatingSystem} is not supported',
    );
  }

  ffi.DynamicLibrary _loadMacOSLibrary() {
    final arch = _getArch();
    final libFileName = 'macos_$arch.dylib';

    // Список путей для поиска библиотеки
    final searchPaths = <String>[
      'packages/native/$libFileName',
      // 1. Относительно корня приложения (для Flutter приложения)
      'packages/native/lib/$libFileName',
      // 2. В пакете native/lib/ (после сборки через build.dart) - абсолютный путь
      '${_getPackageRoot()}/lib/$libFileName',
      // 3. Для тестов внутри пакета
      'lib/$libFileName',
      // 4. Dev режим - прямо из core/target/debug
      '${_getPackageRoot()}/../../../core/target/debug/libliquifly.dylib',
      '../../core/target/debug/libliquifly.dylib',
      '../core/target/debug/libliquifly.dylib',
      'core/target/debug/libliquifly.dylib',
    ];

    return _tryLoadFromPaths(searchPaths);
  }

  ffi.DynamicLibrary _loadLinuxLibrary() {
    final arch = _getArch();
    final libFileName = 'linux_$arch.so';

    final searchPaths = <String>[
      'packages/native/lib/$libFileName',
      '${_getPackageRoot()}/lib/$libFileName',
      'lib/$libFileName',
      '${_getPackageRoot()}/../../../core/target/debug/libliquifly.so',
      '../../core/target/debug/libliquifly.so',
      '../core/target/debug/libliquifly.so',
      'core/target/debug/libliquifly.so',
    ];

    return _tryLoadFromPaths(searchPaths);
  }

  ffi.DynamicLibrary _loadWindowsLibrary() {
    final arch = _getArch();
    final libFileName = 'windows_$arch.dll';

    final searchPaths = <String>[
      'packages/native/lib/$libFileName',
      '${_getPackageRoot()}/lib/$libFileName',
      'lib/$libFileName',
      '${_getPackageRoot()}/../../../core/target/debug/liquifly.dll',
      '../../core/target/debug/liquifly.dll',
      '../core/target/debug/liquifly.dll',
      'core/target/debug/liquifly.dll',
    ];

    return _tryLoadFromPaths(searchPaths);
  }

  /// Пытается загрузить библиотеку из списка путей
  ffi.DynamicLibrary _tryLoadFromPaths(List<String> paths) {
    for (final path in paths) {
      if (File(path).existsSync()) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (e) {
          // Пробуем следующий путь
          continue;
        }
      }
    }

    // Если ничего не нашли, пробуем первый путь для получения подробной ошибки
    return ffi.DynamicLibrary.open(paths.first);
  }

  /// Получает путь к lib директории пакета
  String _getPackageLibPath(String fileName) {
    // Пытаемся найти packages/native/lib/
    final currentScript = Platform.script.toFilePath();
    final currentDir = Directory(File(currentScript).parent.path);

    // Поиск вверх по дереву директорий
    var dir = currentDir;
    while (dir.path != dir.parent.path) {
      final nativePackage = Directory('${dir.path}/packages/native/lib');
      if (nativePackage.existsSync()) {
        return '${nativePackage.path}/$fileName';
      }
      dir = dir.parent;
    }

    // Fallback - возвращаем относительный путь
    return 'packages/native/lib/$fileName';
  }

  /// Получает корневую директорию пакета native
  String _getPackageRoot() {
    final script = Platform.script.toFilePath();
    final scriptDir = File(script).parent;

    // Если мы внутри пакета (тесты), ищем корень пакета
    var dir = scriptDir;
    while (dir.path != dir.parent.path) {
      // Проверяем наличие pubspec.yaml с именем пакета native
      final pubspec = File('${dir.path}/pubspec.yaml');
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        if (content.contains('name: native')) {
          return dir.path;
        }
      }
      dir = dir.parent;
    }

    // Если не нашли, возвращаем текущую директорию
    return Directory.current.path;
  }

  /// Определяет архитектуру процессора
  String _getArch() {
    // Простое определение на основе версии платформы
    final version = Platform.version.toLowerCase();

    if (version.contains('arm64') || version.contains('aarch64')) {
      return 'arm64';
    } else if (version.contains('x64') ||
        version.contains('x86_64') ||
        version.contains('amd64')) {
      return 'x64';
    } else {
      // По умолчанию x64 для десктопа
      return 'x64';
    }
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
