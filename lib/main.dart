import 'package:flutter/material.dart';
import 'dart:io';
import 'components/global.dart';
import 'components/window.dart';
import 'screens/config.dart';
import 'screens/error.dart';
import 'screens/main.dart';
import 'screens/tutorial.dart';
import 'package:path/path.dart' as path;

void main() async {
  WindowSetup();
  
  await GlobalVariables.loadConfig();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final bitFiestaExe = '${GlobalVariables.bitfiestaFolder}/nw.exe';
    final bool bitfiestaExists = File(bitFiestaExe).existsSync();
    final String folderName = path.basename(GlobalVariables.bitfiestaFolder);
    final bool isCorrectFolderName = folderName == "8Bit Fiesta Steam";
    copyB2Exe();
    if(bitfiestaExists && isCorrectFolderName) {
      bitFiestaCleanup();
    }
    if(bitfiestaExists && !isCorrectFolderName) {
      GlobalVariables.bitfiestaFolder = '';
      GlobalVariables.saveConfig();
    }
    return MaterialApp(
      initialRoute: GlobalVariables.tutorialDone && bitfiestaExists ? '/main' : GlobalVariables.tutorialDone ? '/error' : '/tutorial',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        '/tutorial': (context) => const Tutorial(),
        '/error': (context) => const Error(),
        '/main': (context) => const Main(),
        '/config': (context) => const Config(),
      },
    );
  }
}