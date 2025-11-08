#!/usr/bin/env dart

import 'dart:io';

/// Скрипт для компиляции Rust библиотеки и копирования в пакет
void main(List<String> args) async {
  final isRelease = args.contains('--release');
  final buildProfile = isRelease ? 'release' : 'debug';

  print('🔨 Building Rust library ($buildProfile mode)...\n');

  // Определяем пути
  final scriptDir = Directory.current.path;
  final projectRoot = _findProjectRoot(scriptDir);
  final coreDir = Directory('$projectRoot/core');
  final targetDir = Directory('$projectRoot/core/target/$buildProfile');
  final libDir = Directory('$scriptDir/lib');

  print('📂 Project root: $projectRoot');
  print('📂 Core directory: ${coreDir.path}');
  print('📂 Target directory: ${targetDir.path}');
  print('📂 Library output: ${libDir.path}\n');

  // Проверяем что core директория существует
  if (!coreDir.existsSync()) {
    print('❌ Core directory not found at ${coreDir.path}');
    exit(1);
  }

  // Компилируем Rust библиотеку
  print('⚙️  Running cargo build...');
  final buildArgs = isRelease ? ['build', '--release'] : ['build'];

  final result = await Process.run(
    'cargo',
    buildArgs,
    workingDirectory: coreDir.path,
  );

  if (result.exitCode != 0) {
    print('❌ Cargo build failed:');
    print(result.stderr);
    exit(1);
  }

  print(result.stdout);
  print('✅ Rust library compiled successfully!\n');

  // Определяем имя файла библиотеки в зависимости от платформы
  final libInfo = _getLibraryInfo();
  final sourceLib = File('${targetDir.path}/${libInfo.sourceFileName}');

  if (!sourceLib.existsSync()) {
    print('❌ Library file not found: ${sourceLib.path}');
    exit(1);
  }

  // Создаем lib директорию если нужно
  if (!libDir.existsSync()) {
    libDir.createSync(recursive: true);
  }

  // Копируем библиотеку с именем платформы
  final targetLib = File('${libDir.path}/${libInfo.targetFileName}');
  sourceLib.copySync(targetLib.path);

  final fileSize = (targetLib.lengthSync() / 1024 / 1024).toStringAsFixed(2);
  print('📦 Copied library to: ${targetLib.path}');
  print('📊 Library size: $fileSize MB\n');

  print('✨ Build completed successfully!');
}

/// Находит корень проекта (где находится core/)
String _findProjectRoot(String startPath) {
  var current = Directory(startPath);

  while (current.path != current.parent.path) {
    final coreDir = Directory('${current.path}/core');
    if (coreDir.existsSync()) {
      return current.path;
    }
    current = current.parent;
  }

  throw Exception('Could not find project root (directory with core/)');
}

class LibraryInfo {
  final String sourceFileName;
  final String targetFileName;

  LibraryInfo(this.sourceFileName, this.targetFileName);
}

/// Получает информацию о библиотеке для текущей платформы
LibraryInfo _getLibraryInfo() {
  if (Platform.isMacOS) {
    final arch = _getArch();
    return LibraryInfo('libliquifly.dylib', 'macos_$arch.dylib');
  } else if (Platform.isLinux) {
    final arch = _getArch();
    return LibraryInfo('libliquifly.so', 'linux_$arch.so');
  } else if (Platform.isWindows) {
    final arch = _getArch();
    return LibraryInfo('liquifly.dll', 'windows_$arch.dll');
  } else {
    throw UnsupportedError(
      'Platform not supported: ${Platform.operatingSystem}',
    );
  }
}

/// Определяет архитектуру процессора
String _getArch() {
  // Простое определение архитектуры
  // В реальности можно использовать Platform.version или другие методы
  if (Platform.version.contains('x64') || Platform.version.contains('x86_64')) {
    return 'x64';
  } else if (Platform.version.contains('arm64') ||
      Platform.version.contains('aarch64')) {
    return 'arm64';
  } else {
    return 'unknown';
  }
}
