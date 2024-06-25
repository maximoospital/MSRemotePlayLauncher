import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../components/global.dart';
import 'package:path/path.dart' as path;

class Error extends StatefulWidget {
  const Error({super.key});

  @override
  ErrorScreen createState() => ErrorScreen();

}
class ErrorScreen extends State<Error> {
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
                    setState(() {
                       GlobalVariables.editConfig(result!.files.single.path!.replaceFirst('nw.exe', ''), true);                      
                    });
                    final bitFiestaExe = '${GlobalVariables.bitfiestaFolder}/nw.exe';
                    final bool bitfiestaExists = File(bitFiestaExe).existsSync();
                    final String folderName = path.basename(GlobalVariables.bitfiestaFolder);
                    // Check if the bitfiesta folder is called "8Bit Fiesta Steam"
                    final bool isCorrectFolderName = folderName == "8Bit Fiesta Steam";
                    if(bitfiestaExists && isCorrectFolderName) {
                      bitFiestaCleanup();
                    }
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
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/error', (route) => false);
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
