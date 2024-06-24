import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';

class GlobalVariables {
  static String bitfiestaFolder = '';
  static bool tutorialDone = false;
  static List<Map<String, dynamic>> games = [
    {'gamenames': [], 'gamepaths': []},
  ];
  static bool gamesEmpty = games[0]['gamenames'].isEmpty;
  static Future<void> loadConfig() async {
    final appDirectory = await getApplicationCacheDirectory();
    final configFile = File('${appDirectory.path}/config.json');

    if (await configFile.exists()) {
      // Config file exists, load it
      String content = await configFile.readAsString();
      Map<String, dynamic> config = json.decode(content);

      bitfiestaFolder = config['bitfiestaFolder'] ?? '';
      tutorialDone = config['tutorialDone'] ?? false;
      games = List<Map<String, dynamic>>.from(config['games'] ?? []);
    } else {
      // Config file doesn't exist, create it with default values
      Map<String, dynamic> defaultConfig = {
        'bitfiestaFolder': bitfiestaFolder,
        'tutorialDone': tutorialDone,
        'games': games,
      };
      await configFile.writeAsString(json.encode(defaultConfig));
    }
  }
  static Future<void> saveConfig() async {
    final appDirectory = await getApplicationCacheDirectory();
    final configFile = File('${appDirectory.path}/config.json');

    Map<String, dynamic> config = {
      'bitfiestaFolder': bitfiestaFolder,
      'tutorialDone': tutorialDone,
      'games': games,
    };
    await configFile.writeAsString(json.encode(config));
  }
  static Future<void> editGame(int index, String name, String path) async {
    games[index] = {'name': name, 'path': path};
    await saveConfig();
  }
  static Future<void> addGame(String name, String path) async {
    games.add({'name': name, 'path': path});
    await saveConfig();
  }
  static Future<void> removeGame(int index) async {
    games.removeAt(index);
    await saveConfig();
  }
  static Future<void> editConfig(String bitfiestaFolder, bool tutorialDone) async {
    GlobalVariables.bitfiestaFolder = bitfiestaFolder;
    GlobalVariables.tutorialDone = tutorialDone;
    await saveConfig();
  }  
}

// Function that deletes all files in the BitFiesta folder that are not needed
void bitFiestaCleanup() async {
  final bitfiestaFolder = GlobalVariables.bitfiestaFolder;
  final bitfiestaFiles = Directory(GlobalVariables.bitfiestaFolder).listSync();
  // Delete all files in the BitFiesta folder and folders, including their contents, except for the nw.exe
  for (var file in bitfiestaFiles) {
      file.deleteSync(recursive: true);
  }
    // Copy the file nw.zip from the app's assets to the BitFiesta folder and unzip it
  final appDirectory = await getApplicationDocumentsDirectory();
  final nwZipBytes = await rootBundle.load('assets/nw.zip');
  final nwZipFile = File('${appDirectory.path}/nw.zip');
  await nwZipFile.writeAsBytes(nwZipBytes.buffer.asUint8List());
  
  final destinationDir = Directory(bitfiestaFolder);
  if (!await destinationDir.exists()) {
    await destinationDir.create(recursive: true);
  }
  await nwZipFile.copy('${destinationDir.path}/nw.zip');

  // Unzip the nw.zip file
  try {
  final zipFile = File('${destinationDir.path}/nw.zip');
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File('${destinationDir.path}/$filename')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory('${destinationDir.path}/$filename').create(recursive: true);
    }
  }
  print('Unzip successful');
} catch (e) {
  print('Failed to unzip: $e');
}
}