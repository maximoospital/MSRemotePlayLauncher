import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';


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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    title: "Maxi's Steam Remote Play Launcher",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.show();
    await windowManager.focus();
  });
  
  await GlobalVariables.loadConfig();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  // Check config, if tutorial is done and the bitfiesta folder contains nw.exe, show main screen, else show tutorial screen

  Widget build(BuildContext context) {
    final bitFiestaExe = '${GlobalVariables.bitfiestaFolder}/nw.exe';
    final bool bitfiestaExists = File(bitFiestaExe).existsSync();

    return MaterialApp(
      initialRoute: GlobalVariables.tutorialDone && bitfiestaExists ? '/main' : GlobalVariables.tutorialDone ? '/error' : '/tutorial',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        '/tutorial': (context) => const TutorialScreen(),
        '/error': (context) => const ErrorScreen(),
        '/main': (context) => const MainScreen(),
        '/config': (context) => const ConfigScreen(),
      },
    );
  }
}

const result = '';
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "Welcome",
        body: "Welcome to Maxi's Steam Remote Play Launcher!\nThis is the inital setup.",
        image: const Center(child: Icon(FontAwesomeIcons.steam, size: 100.0)),
      ),
      PageViewModel(
        title: "Requirements",
        body: "This app uses both Steam and 8 Bit Fiesta.\n If you're here i'm assuming you already have Steam installed though.",
        footer: Container (
          margin: const EdgeInsets.only(left: 220.0, right: 220.0, top: 25.0),
          child: ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse('steam://install/382260'));
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 50),
            ),
            child: const Text("Install 8 Bit Fiesta"),
          ),
        ),
        image: const Center(child: Icon(FontAwesomeIcons.list, size: 50.0)),
      ),
      PageViewModel(
        title: "The Most Important Part",
        body: "After installing 8 Bit Fiesta, click the button down below and\npick 8 Bit Fiesta's executable.",
        footer: Container (
          margin: const EdgeInsets.only(left: 200.0, right: 200.0, top: 25.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Open file picker to select 8 Bit Fiesta's nw.exe
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['exe'],
                  );
                  if (result != '') {
                    await GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                ),
                child: const Text("Find 8BF's executable.", style: TextStyle(fontSize: 15.0)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(GlobalVariables.bitfiestaFolder, style: const TextStyle(fontSize: 10.0)),
              ),
            ],
          ),
        ),
        image: const Center(child: Icon(FontAwesomeIcons.exclamationCircle, size: 50.0)),
      ),
      PageViewModel(
        title: "And that's it!",
        body: "Let's get started!",
        image: const Center(child: Icon(FontAwesomeIcons.checkCircle, size: 100.0)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: getPages(),
      onDone: () async {
        final exeBitfiesta = '${GlobalVariables.bitfiestaFolder}nw.exe';
        final bool bitfiestaExists = File(exeBitfiesta).existsSync();
        if(bitfiestaExists) {
          await GlobalVariables.editConfig(GlobalVariables.bitfiestaFolder, true);
          bitFiestaCleanup();
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/error');
        }
      },
      showSkipButton: false,
      showNextButton: true,
      showBackButton: true,
      back: const Text("Go Back"),
      next: const Text("Next"),
      done: const Text("Finish Tutorial", style: TextStyle(fontWeight: FontWeight.w600)),
    );
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
  // Copy all the files and folders from the app's local assets/nwreplacement folder to the BitFiesta folder. Merge the folders and overwrite the files.
  copyNwReplacementToBitFiesta();

}

Future<void> copyNwReplacementToBitFiesta() async {
  final String sourcePath = 'assets/nwreplacement';

  await copyDirectory(Directory(sourcePath), Directory(GlobalVariables.bitfiestaFolder));
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    if (entity is File) {
      await copyFile(entity, destination.path);
    } else if (entity is Directory) {
      final newDirectory = Directory('${destination.path}/${entity.path.split('/').last}');
      if (!await newDirectory.exists()) {
        await newDirectory.create(recursive: true);
      }
      await copyDirectory(entity, newDirectory);
    }
  }
}

Future<void> copyFile(File source, String destinationPath) async {
  final newFile = File('$destinationPath/${source.path.split('/').last}');
  await newFile.create(recursive: true);
  await source.copy(newFile.path);
}


class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "8 Bit Fiesta not found!",
        body: "8 Bit Fiesta's executable was not found.\n Please point to it's location to continue.",
        footer: Container (
          margin: const EdgeInsets.only(left: 200.0, right: 200.0, top: 25.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Open file picker to select 8 Bit Fiesta's nw.exe
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['exe'],
                  );
                  if (result != '') {
                    await GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                ),
                child: const Text("Find 8BF's executable.", style: TextStyle(fontSize: 15.0)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(GlobalVariables.bitfiestaFolder, style: const TextStyle(fontSize: 10.0)),
              ),
            ],
          ),
        ),
        image: const Center(child: Icon(FontAwesomeIcons.exclamationTriangle, size: 50.0)),
      ),
      PageViewModel(
        title: "And that's it!",
        body: "Let's get started!",
        image: const Center(child: Icon(FontAwesomeIcons.checkCircle, size: 100.0)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: getPages(),
      onDone: () async {
        final exeBitfiesta = '${GlobalVariables.bitfiestaFolder}nw.exe';
        final bool bitfiestaExists = File(exeBitfiesta).existsSync();
        if(bitfiestaExists) {
          await GlobalVariables.editConfig(GlobalVariables.bitfiestaFolder, true);
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          Navigator.pushReplacementNamed(context, '/error');
        }
      },
      showSkipButton: false,
      showNextButton: true,
      showBackButton: true,
      back: const Text("Go Back"),
      next: const Text("Next"),
      done: const Text("Done!", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maxi's Remote Play Launcher"),
        // Add a button to go to the config screen
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.bars),
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
          ),
        ],
      ),
      
      body: Center(
        // If there are no games, show a message to add a game and a button to add a game, else show a text count of the games
        child: GlobalVariables.games[0]['gamenames'].isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No games added yet."),
                  ElevatedButton(
                    onPressed: () {
                      // Add a game
                    },
                    child: const Text("Add a game"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Games: ${GlobalVariables.games.length}"),
                  // Add a table with the games, they can be launched by double clicking them and right clicking opens a context menu to edit or remove them.
                ],
              )
      ),
    );
  }// Add a table with the games, they can be launched by double clicking them and right clicking opens a context menu to edit or remove them.
        // Add a button to add a new game
        // If there are no games, show a message to add a game and a button to add a game
        
}

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings (not much)'),
        // Add a button to go back to the main screen
        // Disable the back button
        leading: IconButton(
            icon: const Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
      ),
      body: Center(
        child: Row(
                  children:[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Center(
                          child: Text(' Requirements ')
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('https://store.steampowered.com/about/download'));
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text("Install Steam"),
                          )
                          )
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('steam://install/382260'));
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text("Install 8 Bit Fiesta"),
                          )
                          )
                        ),
                      ],)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Center(
                          child: Text(' 8 Bit Fiesta Location ')
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['exe'],
                              );
                              if (result != '') {
                                await GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), true);
                                final exeBitfiesta = '${GlobalVariables.bitfiestaFolder}nw.exe';
                                final bool bitfiestaExists = File(exeBitfiesta).existsSync();
                                if(bitfiestaExists) {
                                  Navigator.pop(context);
                                } else {
                                  // Delete all previous navigation history and go to the error screen
                                  Navigator.pushNamedAndRemoveUntil(context, '/error', (route) => false);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text("Search for 8BF"),
                          )
                          )
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: Text(GlobalVariables.bitfiestaFolder, style: const TextStyle(fontSize: 10.0))
                          )
                        ),
                      ],)),
                      Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Center(
                          child: Text(' App by Maximo Ospital ')
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('https://maximoospital.xyz/'));
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text("Visit my website!"),
                          )
                          )
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('https://github.com/maximoospital/'));
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 50),
                            ),
                            child: const Text("Visit my Github!"),
                          )
                          )
                        ),
                      ],)),
                    ])
      ),
    );
  }
}
