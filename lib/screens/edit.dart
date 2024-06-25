import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../components/global.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  EditScreen createState() => EditScreen();
}
class EditScreen extends State<Edit> {
  String name = GlobalVariables.gamesList[GlobalVariables.index]['name'];
  String gamepath = GlobalVariables.gamesList[GlobalVariables.index]['path'];

  late TextEditingController nameController;
  
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing $name'),
        // Add a button to go back to the main screen
        // Disable the back button
        leading: IconButton(
            icon: const Icon(FontAwesomeIcons.arrowLeft),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
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
                          child: Text(' Name ')
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0, left: 20.0),
                            child: TextField(
                  controller: nameController,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(FontAwesomeIcons.gamepad),
                    filled: false,
                    labelText: "Game name", 
                    hintText: "Write the game's name here.",
                  ),
                ),)
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            child: const Text('', style: TextStyle(fontSize: 10.0))
                          )
                        ),
                      ],)),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Center(
                          child: Text(' Game Location ')
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
                              if (result != null) {
                                setState(() {
                                  gamepath = result.files.single.path!;
                                  // Replace all backslashes with forward slashes for compatibility
                                  gamepath = gamepath.replaceAll('\\', '/');
                                });
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
                            child: Text(gamepath.toString(), style: const TextStyle(fontSize: 10.0))
                          )
                        ),
                      ],))
                      ,
                    ])
      ),
      floatingActionButton: FloatingActionButton( 
        onPressed: () async {
          if(name != '' && gamepath != ''){
            await testAdd(name, gamepath.toString());
            await GlobalVariables.editGame(GlobalVariables.index+1, name, gamepath.toString());
          }
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game $name added!'),
              animation: CurvedAnimation(parent: const AlwaysStoppedAnimation(1), curve: Curves.easeInOut),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: Colors.blueGrey[900],
        child: const Icon(FontAwesomeIcons.save),
      ),
    );
  }
  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is disposed
    nameController.dispose();
    super.dispose();
  }
}
