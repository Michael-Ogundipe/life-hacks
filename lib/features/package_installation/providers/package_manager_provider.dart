// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:beamer/beamer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:package_maneger_desktop/model/device_emulator_menu_item.dart';
// import 'package:package_maneger_desktop/model/package_model.dart';
// import 'package:package_maneger_desktop/routes/routes.dart';
// import 'package:package_maneger_desktop/utils/toast_utils.dart';
// import 'package:package_maneger_desktop/utils/utils.dart';
// import 'package:pub_semver/pub_semver.dart';
// import 'package:yaml/yaml.dart';
//
// final packageManagerProvider =
//     ChangeNotifierProvider((_) => PackageManagerProvider());
//
// class PackageManagerProvider extends ChangeNotifier {
//   PackageModel? selectedPackage;
//
//   PackageManagerProvider();
//   String? selectedPackageSdkConstraints;
//   BuildContext? context;
//
//   Future<void> runFlutterProject(
//       String selectedDevice, String selectedProject) async {
//     try {
//       if (selectedProject.isEmpty) {
//         throw Exception('No project selected');
//       }
//       final uri = Uri.parse(selectedProject);
//
//       final filePath = uri.toFilePath(windows: Platform.isWindows);
//
//       await Process.run(
//         'flutter',
//         ['run', '-d', selectedDevice],
//         runInShell: true,
//         workingDirectory: filePath,
//       );
//     } catch (e) {
//       throw Exception('ERROR: $e');
//     }
//   }
//
//   Future<void> validateAndRunProject(DeviceAndEmulatorMenuItem? selectedDevice,
//       String? selectedProject) async {
//     if (selectedDevice == null) {
//       ToastUtils.showToastError('Device must not be empty', context!);
//     } else if (selectedProject == null || selectedProject.isEmpty) {
//       ToastUtils.showToastError('Project must not be empty', context!);
//     } else {
//       context!.beamToNamed(Routes.genratingPage);
//       final result = await _validateYamlFile(context!, selectedProject);
//       if (result == null) {
//         String? packageResult = '';
//         if (context!.mounted) {
//           packageResult = await addPackage(context!, selectedProject);
//         }
//
//         if (packageResult == null) {
//           if (context!.mounted) {
//             context!.beamToNamed(Routes.successPage);
//             await runFlutterProject(selectedDevice.id, selectedProject);
//           }
//         } else {
//           if (context!.mounted) {
//             context!.beamToNamed(Routes.packagePage);
//             await Future.delayed(
//               Duration.zero,
//               () async => await Utils.showAlertDialog(
//                 context!,
//                 'Error',
//                 packageResult!,
//               ),
//             );
//           }
//         }
//       } else {
//         if (context!.mounted) {
//           context!.beamToNamed(Routes.packagePage);
//           await Future.delayed(
//             Duration.zero,
//             () async => await Utils.showAlertDialog(context!, 'Error', result),
//           );
//         }
//       }
//     }
//   }
//
//   /// Validate Package for Project Functionality
//
//   Future<String?> _validateYamlFile(
//       BuildContext context, String selectedProject) async {
//     final uri = Uri.parse(selectedProject);
//
//     final filePath = uri.toFilePath(windows: Platform.isWindows);
//     final pubspecFile = File('$filePath/pubspec.yaml');
//
//     if (await pubspecFile.exists()) {
//       final pubspecContent = await pubspecFile.readAsString();
//       await _parseYaml(pubspecContent);
//       return null;
//     } else {
//       return 'pubspec.yaml file not found in the selected directory.';
//     }
//   }
//
//   Future<void> _parseYaml(String yamlString) async {
//     final parsedYaml = loadYaml(yamlString) as Map;
//     final sdkConstraints = parsedYaml['environment']?['sdk']?.toString() ??
//         'No SDK constraints found';
//     final dependencies = parsedYaml['dependencies'] as Map? ?? {};
//     final devDependencies = parsedYaml['dev_dependencies'] as Map? ?? {};
//     String output = 'SDK Constraints: $sdkConstraints\n\n';
//     output += 'Dependencies:\n';
//
//     dependencies.forEach((key, value) {
//       if (key == 'flutter') {
//         output += '$key: {sdk: flutter}\n';
//       } else {
//         output += '$key: $value\n';
//       }
//     });
//     output += dependencies.isEmpty ? 'No dependencies found.\n' : '';
//
//     output += '\nDev Dependencies:\n';
//     devDependencies.forEach((key, value) {
//       output += '$key: $value\n';
//     });
//     output += devDependencies.isEmpty ? 'No dev dependencies found.\n' : '';
//
//     selectedPackageSdkConstraints = sdkConstraints;
//   }
//
//   Future<String?> addPackage(
//       BuildContext context, String? selectedProject) async {
//     final packageName = selectedPackage!.name;
//     print('PACKAGE NAME: $packageName');
//     if (selectedProject != null && packageName.isNotEmpty) {
//       try {
//         // Utils.showProgressDialog(context, 'Installing package $packageName');
//
//         if (await _checkPackageCompatibility(packageName)) {
//           String? result;
//           if (context.mounted) {
//             result = await managePackageInstallation(context, selectedProject);
//           }
//
//           return result;
//         } else {
//           // if (context.mounted) Navigator.pop(context);
//           return 'Package $packageName is not compatible with your project\'s SDK constraints ($selectedPackageSdkConstraints).';
//         }
//       } catch (e) {
//         if (context.mounted) Navigator.pop(context);
//         return 'An error occurred: $e';
//       }
//     } else {
//       return 'No project selected or package name is empty.';
//     }
//   }
//
//   Future<bool> _checkPackageCompatibility(String packageName) async {
//     try {
//       final response = await http
//           .get(Uri.parse('https://pub.dev/api/packages/$packageName'));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final packageSdkConstraints =
//             data['latest']['pubspec']['environment']['sdk'];
//         return _isCompatible(
//             selectedPackageSdkConstraints!, packageSdkConstraints);
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }
//
//   bool _isCompatible(String currentSdk, String packageSdk) {
//     final currentConstraint = VersionConstraint.parse(currentSdk);
//     final packageConstraint = VersionConstraint.parse(packageSdk);
//     return currentConstraint.allowsAny(packageConstraint);
//   }
//
//   /// Github Snapshot Functionality
//
//   /// Ensure Git is initialized, or initialize it if necessary.
//   Future<void> ensureGitInitialized(String projectDir) async {
//     final gitFolder = Directory('$projectDir/.git');
//     if (await gitFolder.exists()) {
//       print('.git folder already exists. Skipping Git initialization.');
//     } else {
//       print('.git folder does not exist. Initializing Git in the project.');
//       await initializeGit(projectDir); // Function to initialize git
//     }
//   }
//
//   Future<void> initializeGit(String selectedProject) async {
//     final path = selectedProject.replaceFirst('file://', '');
//     final filePath =
//         Platform.isWindows && path.startsWith('/') ? path.substring(1) : path;
//
//     final result = await Process.run(
//       'git',
//       ['init'],
//       workingDirectory: filePath,
//       runInShell: true,
//     );
//     if (result.exitCode != 0) {
//       throw Exception('Git initialization failed: ${result.stderr}');
//     } else {
//       print('Git initialized in $path');
//     }
//   }
//
//   /// Full process for managing package installation and snapshot creation
//   Future<String?> managePackageInstallation(
//       BuildContext context, String selectedProject) async {
//     try {
//       final uri = Uri.parse(selectedProject);
//       final projectDir = uri.toFilePath(windows: Platform.isWindows);
//       final packageName = selectedPackage!.name;
//
//       await ensureGitInitialized(projectDir);
//
//       await createPrePackageSnapshot(projectDir, packageName);
//
//       String? result = '';
//       if (context.mounted) {
//         result = await installPackage(projectDir, packageName, context);
//       }
//
//       if (result == null) {
//         await createPostPackageSnapshot(projectDir, packageName);
//         return null;
//       } else {
//         return result;
//       }
//     } catch (e) {
//       return 'Unknown Error: $e';
//     }
//   }
//
//   /// Create a pre-package integration snapshot
//   Future<void> createPrePackageSnapshot(
//       String projectDir, String packageName) async {
//     final message = 'Pre package integration snapshot $packageName';
//     await createSnapshot(projectDir, message);
//   }
//
//   Future<void> createSnapshot(String projectDir, String commitMessage) async {
//     await Process.run(
//       'git',
//       ['add', '.'],
//       workingDirectory: projectDir,
//       runInShell: true,
//     );
//
//     final result = await Process.run(
//       'git',
//       ['commit', '-m', commitMessage],
//       workingDirectory: projectDir,
//       runInShell: true,
//     );
//
//     if (result.exitCode == 0) {
//       print('Snapshot created with message: $commitMessage');
//     } else {
//       print('Error: ${result.stdout}');
//     }
//   }
//
//   /// Create a post-package integration snapshot
//   Future<void> createPostPackageSnapshot(
//       String projectDir, String packageName) async {
//     final message = 'Post package integration snapshot $packageName';
//     await createSnapshot(projectDir, message);
//   }
//
//   /// Revert to the snapshot before the package integration
//   Future<void> revertToPrePackageSnapshot(String selectedProject) async {
//     final uri = Uri.parse(selectedProject);
//     final projectDir = uri.toFilePath(windows: Platform.isWindows);
//     final packageName = selectedPackage!.name;
//
//     print('Reverting project to pre-package snapshot for $packageName');
//     await revertToSnapshot(
//         projectDir, 'Pre package integration snapshot $packageName');
//   }
//
//   /// Revert to a specific commit by commit message
//   Future<void> revertToSnapshot(String projectDir, String commitMessage) async {
//     try {
//       // Get the commit hash based on the commit message
//       final result = await Process.run(
//           'git', ['log', '--grep=${commitMessage.trim()}', '--format=%H'],
//           workingDirectory: projectDir);
//       final commitHash = result.stdout.trim();
//       if (commitHash.isEmpty) {
//         throw Exception('Could not find commit with message: $commitMessage');
//       }
//
//       // Reset to the found commit hash
//       final resetResult = await Process.run(
//           'git', ['reset', '--hard', commitHash],
//           workingDirectory: projectDir);
//       if (resetResult.exitCode != 0) {
//         throw Exception('Failed to reset to snapshot: ${resetResult.stderr}');
//       }
//       print('Project successfully reset to: $commitMessage');
//     } catch (e) {
//       throw Exception('Failed to revert to snapshot: $e');
//     }
//   }
//
//   Future<String?> installPackage(
//       String projectDir, String packageName, BuildContext context) async {
//     final result = await Process.run(
//       'flutter',
//       ['pub', 'add', packageName],
//       workingDirectory: projectDir,
//       runInShell: true,
//     );
//
//     final exitCode = result.exitCode;
//
//     if (exitCode == 0) {
//       final pubspecFile = File('$projectDir/pubspec.yaml');
//       final pubspecContent = await pubspecFile.readAsString();
//       _parseYaml(pubspecContent);
//       return null;
//     } else {
//       if (context.mounted) {
//         Navigator.pop(context);
//         Utils.showAlertDialog(
//             context, 'Error', 'Failed to add package: $packageName');
//       }
//       return 'Failed to add package: $packageName';
//     }
//   }
//
//   Future<bool> isGitInstalled() async {
//     try {
//       final result = await Process.run('git', ['--version']);
//       return result.exitCode == 0;
//     } catch (e) {
//       return false;
//     }
//   }
// }
