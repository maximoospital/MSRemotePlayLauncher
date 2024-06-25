import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/global.dart';

class Main extends StatefulWidget {
  const Main({super.key});
  @override
  MainScreen createState() => MainScreen();
}

Future<void> launch(String name, String gamepath, BuildContext context) async {
  final batName = gamepath.split('/').last.split('.').first;
  final appDirectory = await getApplicationCacheDirectory();
  final batFile = File('${appDirectory.path}/$name.$batName.exe');
  if(batFile.existsSync()) {
  ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Launching $name...'),
              animation: CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
              behavior: SnackBarBehavior.floating,
            ),
    );    
      final bitFiesta = GlobalVariables.bitfiestaFolder;
  final nwFile = File('$bitFiesta/nw.exe');
  await nwFile.delete();
  await batFile.copy('$bitFiesta/nw.exe');
  // Launch
  await launchUrl(Uri.parse('steam://launch/382260'));

  } else {
  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Launch file missing. Please re-add the game.'),
          animation: CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
          behavior: SnackBarBehavior.floating,
        ),
  );
  }
  // Copy the batFile to the GlobalVariables.bitfiestaFolder 
}

class MainScreen extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.only(left: 13.0),
          child: IconButton(
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            tooltip: 'About this app',
          onPressed: () {
              showDialog(
                builder: (context) => AboutDialog(
                  applicationName: "Maxi's Remote Play Launcher",
                  applicationIcon: Container(margin: const EdgeInsets.only(top: 7.0), child: const Icon(FontAwesomeIcons.steamSquare, size: 30.0),),
                  applicationVersion: "v1.0",
                  applicationLegalese: "© Copyright Maximo Ospital 2024"
                ), context: context,
              );
            },
        icon: const Icon(FontAwesomeIcons.steamSquare))
        ),
        title: const Text("Maxi's Remote Play Launcher"),
        elevation: 5.0,
        shadowColor: Colors.black,
        // Add a button to go to the config screen
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15.0),
            child: Tooltip(
      message: 'Settings',
      child: IconButton(
            icon: const Icon(FontAwesomeIcons.bars),
            onPressed: () {
              Navigator.pushNamed(context, '/config');
            },
          ),
        ),)
        ],
      ),
      
      body: GlobalVariables.gamesEmpty
            ? Center(
        // If there are no games, show a message to add a game and a button to add a game, else show a text count of the games
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(margin: const EdgeInsets.only(bottom: 15.0), child: const Text("No games added yet.")),
                ],
              )
            ) : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: GlobalVariables.gamesList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(GlobalVariables.gamesList[index]['name']),
                            leading: Tooltip(
                              message: 'Play',
                              child: IconButton(
                              icon: const Icon(FontAwesomeIcons.playCircle),
                              onPressed: () {
                                launch(GlobalVariables.gamesList[index]['name'], GlobalVariables.gamesList[index]['path'], context);
                              },
                            ),
                            ),
                            subtitle: Text(GlobalVariables.gamesList[index]['path']),
                            contentPadding: const EdgeInsets.only(left: 15.0, right: 15.0),
                            trailing: PopupMenuButton(
                              icon: const Icon(FontAwesomeIcons.ellipsisV),
                              itemBuilder: (BuildContext context) { 
                              return [
                                PopupMenuItem(
                                  value: 0,
                                  child: const Text('Play'),
                                  onTap: () => launch(GlobalVariables.gamesList[index]['name'], GlobalVariables.gamesList[index]['path'], context),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: const Text('Edit'),
                                  onTap: () {
                                    setState(() {
                                      GlobalVariables.index = index;
                                      Navigator.pushNamed(context, '/edit');
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: const Text('Remove'),
                                  onTap: () async {
                                    final name = GlobalVariables.gamesList[index]['name'];
                                    final appDirectory = await getApplicationCacheDirectory();
                                    final batName = GlobalVariables.gamesList[index]['path'].split('/').last.split('.').first;
                                    final batFile = File('${appDirectory.path}/${GlobalVariables.gamesList[index]['name']}.$batName.exe');
                                    final bat = File('${appDirectory.path}/${GlobalVariables.gamesList[index]['name']}.$batName.bat');
                                    if(batFile.existsSync()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Removed $name'),
                                                animation: CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                      ); 
                                      await bat.delete();
                                      await batFile.delete();
                                      setState(() {
                                        GlobalVariables.removeGame(index+1);
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Removed $name'),
                                                animation: CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                      );
                                      setState(() {
                                        GlobalVariables.removeGame(index+1);
                                      });
                                    }
                                  },
                                ),
                              ];
                             },
                            ),
                            
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.blueGrey[50],
        onPressed: () {
          setState(() {
            Navigator.pushNamed(context, '/add');          
          });
        },
        tooltip: 'Add a game',
        child: const Icon(FontAwesomeIcons.plus),
      )
    );
  }
}