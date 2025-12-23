// ignore_for_file: avoid_print
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
  
  print('🎉 APK Release created successfully!');
  print('📍 Location: $destinationPath');

  // 5. Build for Windows if on Windows
  if (Platform.isWindows) {
    print('\n🪟 Starting Windows build...');
    
    final windowsBuildResult = await Process.run(
      'flutter', 
      ['build', 'windows', '--release'],
      runInShell: true,
    );

    if (windowsBuildResult.exitCode != 0) {
      print('❌ Windows Build failed!');
      print(windowsBuildResult.stdout);
      print(windowsBuildResult.stderr);
      // Don't exit here, as APK was already successful
    } else {
      print('✅ Windows Build successful!');

      // Find the build output
      // It's usually in build/windows/x64/runner/Release or build/windows/runner/Release
      var buildPath = 'build/windows/x64/runner/Release';
      if (!Directory(buildPath).existsSync()) {
        buildPath = 'build/windows/runner/Release';
      }

      if (Directory(buildPath).existsSync()) {
        final zipName = 'Listo-v$version-windows.zip';
        final zipPath = 'releases/$zipName';

        print('📦 Zipping Windows build to $zipPath...');
        
        // Use PowerShell to zip
        final zipResult = await Process.run(
          'powershell',
          [
            'Compress-Archive', 
            '-Path', '$buildPath/*', 
            '-DestinationPath', zipPath, 
            '-Force'
          ],
          runInShell: true,
        );

        if (zipResult.exitCode == 0) {
           print('🎉 Windows Release created successfully!');
           print('📍 Location: $zipPath');
        } else {
           print('❌ Failed to zip Windows build');
           print(zipResult.stderr);
        }
      } else {
        print('❌ Could not find Windows build output at $buildPath');
      }
    }
  }
}
