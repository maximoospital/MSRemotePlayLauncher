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
      String content = await configFile.readAsString();
      Map<String, dynamic> config = json.decode(content);

      bitfiestaFolder = config['bitfiestaFolder'] ?? '';
      tutorialDone = config['tutorialDone'] ?? false;
      games = List<Map<String, dynamic>>.from(config['games'] ?? []);
    } else {
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

void copyB2Exe() async {
  final appDirectory = await getApplicationCacheDirectory();
  final isb2Exe = File('${appDirectory.path}/b2exe.exe').existsSync();

  if(!isb2Exe) {
    final b2ExeBytes = await rootBundle.load('assets/b2exe.exe');
    final b2ExeFile = File('${appDirectory.path}/b2exe.exe');
    await b2ExeFile.writeAsBytes(b2ExeBytes.buffer.asUint8List());
  }
}

void bitFiestaCleanup() async {
  final bitfiestaFolder = GlobalVariables.bitfiestaFolder;
  final bitfiestaFiles = Directory(GlobalVariables.bitfiestaFolder).listSync();
  for (var file in bitfiestaFiles) {
      file.deleteSync(recursive: true);
  }
  final appDirectory = await getApplicationCacheDirectory();
  final nwZipBytes = await rootBundle.load('assets/nw.zip');
  final nwZipFile = File('${appDirectory.path}/nw.zip');
  await nwZipFile.writeAsBytes(nwZipBytes.buffer.asUint8List());
  
  final destinationDir = Directory(bitfiestaFolder);
  if (!await destinationDir.exists()) {
    await destinationDir.create(recursive: true);
  }
  await nwZipFile.copy('${destinationDir.path}/nw.zip');

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