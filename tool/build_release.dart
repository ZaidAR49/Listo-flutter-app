import 'dart:io';

void main() async {
  print('🚀 Starting release build process...');

  // 1. Read pubspec.yaml to get the version
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ Error: pubspec.yaml not found!');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionMatch = RegExp(r'version:\s+(\S+)').firstMatch(content);

  if (versionMatch == null) {
    print('❌ Error: Could not find version in pubspec.yaml');
    exit(1);
  }

  final version = versionMatch.group(1);
  print('📦 Found version: $version');

  // 2. Run flutter build apk --release
  print('🔨 Building APK... (this might take a minute)');
  final buildResult = await Process.run(
    'flutter', 
    ['build', 'apk', '--release'],
    runInShell: true,
  );

  if (buildResult.exitCode != 0) {
    print('❌ Build failed!');
    print(buildResult.stdout);
    print(buildResult.stderr);
    exit(1);
  }
  print('✅ Build successful!');

  // 3. Create releases directory if needed
  final releaseDir = Directory('releases');
  if (!releaseDir.existsSync()) {
    releaseDir.createSync();
    print('📂 Created releases directory');
  }

  // 4. Copy and rename the file
  final sourcePath = 'build/app/outputs/flutter-apk/app-release.apk';
  final sourceFile = File(sourcePath);
  
  if (!sourceFile.existsSync()) {
    print('❌ Error: Output APK not found at $sourcePath');
    exit(1);
  }

  final destinationName = 'Listo-v$version.apk';
  final destinationPath = 'releases/$destinationName';
  
  sourceFile.copySync(destinationPath);
  
  print('🎉 Release created successfully!');
  print('📍 Location: $destinationPath');
}
