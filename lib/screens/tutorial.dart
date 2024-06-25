import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../components/global.dart';
import 'package:path/path.dart' as path;

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  TutorialScreen createState() => TutorialScreen();

}
class TutorialScreen extends State<Tutorial> {

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
          child: Tooltip(
      message: 'Requires Steam and 200mb of space, which will be shortened to barely 35mb.',
      child: ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse('steam://install/382260'));
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 50),
            ),
            child: const Text("Install 8 Bit Fiesta"),
          ),
        )
          
          
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
                Tooltip(
                  message: 'Usually located in C:/Program Files (x86)/Steam/steamapps/common/8Bit Fiesta Steam/',
                  child: ElevatedButton(
                                onPressed: () async {
                                  // Open file picker to select 8 Bit Fiesta's nw.exe
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['exe'],
                                  );
                                  if (result != '') {
                                    setState(() {
                                      GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), false);  
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(200, 50),
                                ),
                                child: const Text("Find 8BF's executable.", style: TextStyle(fontSize: 15.0)),
                              ),
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
          final bitFiestaExe = '${GlobalVariables.bitfiestaFolder}/nw.exe';
          final bool bitfiestaExists = File(bitFiestaExe).existsSync();
          // CHeck if the bitfiesta folder is called 8Bit Fiesta Steam
          final String folderName = path.basename(GlobalVariables.bitfiestaFolder);
          // Check if the bitfiesta folder is called "8Bit Fiesta Steam"
          final bool isCorrectFolderName = folderName == "8Bit Fiesta Steam";
          if(bitfiestaExists && isCorrectFolderName) {
            bitFiestaCleanup();
          }
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