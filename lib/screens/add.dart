import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../components/global.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  AddScreen createState() => AddScreen();

}
class AddScreen extends State<Add> {
  String name = '';
  String gamepath = '';
  int screenValue = 0;
  late TextEditingController nameController;
  
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: name);
  }

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "Adding a game",
        body: "First off, type the game's name.",
        footer: Container (
          margin: const EdgeInsets.only(left: 200.0, right: 200.0, top: 25.0),
          child: Column(
            children: [
              TextField(
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
                ),
            ],
          ),
        ),
        image: const Center(child: Icon(FontAwesomeIcons.edit, size: 50.0)),
      ),
      PageViewModel(
        title: "Adding a game",
        body: "Please specify the game's executable's path.",
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
                child: const Text("Find the executable.", style: TextStyle(fontSize: 15.0)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Text(gamepath, style: const TextStyle(fontSize: 10.0)),
              ),
            ],
          ),
        ),
        image: const Center(child: Icon(FontAwesomeIcons.edit, size: 50.0)),
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

        if(name != '' && gamepath != ''){
          testAdd(name, gamepath.toString());
          GlobalVariables.addGame(name, gamepath.toString());
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
      showSkipButton: screenValue == 0 ? true : false,
      showNextButton: true,
      showBackButton: screenValue == 0 ? false : true,
      back: const Text("Go Back"),
      overrideSkip: screenValue == 0 ? ElevatedButton(
                    onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 25),
                    ),
                    // If screenValue is 0, the skip button will be "Skip", else it will be "Cancel"
                    child: Text(screenValue == 0 ? "Cancel" : "Go Back"),
      ) : null,
      onChange: (value) {
        setState(() {
          screenValue = value;
        });
      },
      next: const Text("Next"),
      done: const Text("Done!", style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
  
  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is disposed
    nameController.dispose();
    super.dispose();
  }
}
