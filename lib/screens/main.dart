import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/global.dart';

class Main extends StatefulWidget {
  const Main({super.key});
  @override
  MainScreen createState() => MainScreen();
}
class MainScreen extends State<Main> {
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
        child: GlobalVariables.gamesEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(margin: const EdgeInsets.only(bottom: 15.0), child: const Text("No games added yet.")),
                  ElevatedButton(
                    onPressed: () {
                      print("Adding test game");
                      testAdd("Test Game", "C:/Program Files/Ablaze Floorp/floorp.exe");
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),),
                    child: const Text("Add a game")
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(margin: const EdgeInsets.only(bottom: 15.0), child: Text("Games: ${GlobalVariables.gamesList.length}")),
                  ElevatedButton(
                    onPressed: () {
                      print("Adding test game");
                      setState(() {
                        testAdd("Test Game", "C:/Program Files/Ablaze Floorp/floorp.exe");   
                        GlobalVariables.addGame("Test Game", "C:/Program Files/Ablaze Floorp/floorp.exe");    
                        GlobalVariables.gamesList = GlobalVariables.games.sublist(1);                  
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 50),),
                    child: const Text("Add a game")
                  ),
                  // Add a table with the games, they can be launched by double clicking them and right clicking opens a context menu to edit or remove them.
                ],
              )
      ),
    );
  }// Add a table with the games, they can be launched by double clicking them and right clicking opens a context menu to edit or remove them.
        // Add a button to add a new game
        // If there are no games, show a message to add a game and a button to add a game
        
}