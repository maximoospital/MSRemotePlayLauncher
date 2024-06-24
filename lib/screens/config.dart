import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../components/global.dart';
import 'package:path/path.dart' as path;

class Config extends StatefulWidget {
  @override
  ConfigScreen createState() => ConfigScreen();
}
class ConfigScreen extends State<Config> {

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
                        const Center(
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
                        const Center(
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
                                setState((){
                                  GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), true);
                                });
                                final exeBitfiesta = '${GlobalVariables.bitfiestaFolder}nw.exe';
                                final bool bitfiestaExists = File(exeBitfiesta).existsSync();
                                final String folderName = path.basename(GlobalVariables.bitfiestaFolder);
                                // Check if the bitfiesta folder is called "8Bit Fiesta Steam"
                                final bool isCorrectFolderName = folderName == "8Bit Fiesta Steam";
                                if(bitfiestaExists && isCorrectFolderName) {
                                  bitFiestaCleanup();
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
                        const Center(
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
