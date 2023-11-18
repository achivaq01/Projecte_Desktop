import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

import 'app_data.dart';

class LayoutConnected extends StatefulWidget {
  const LayoutConnected({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LayoutConnectedState();
}

class _LayoutConnectedState extends State<LayoutConnected> {
  final _messageController = TextEditingController();

  Widget _buildTextFormField(
      String label,
      String defaultValue,
      TextEditingController controller,
      ) {
    controller.text = defaultValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: CupertinoTextField(controller: controller,),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Connected"),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 50),
                _buildTextFormField("message", "hi!", _messageController),
                     
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 32,
                      child: CupertinoButton.filled(
                        onPressed: () {
                          appData.text = _messageController.text;
                          appData.send(appData.text);
                          
                          // Mirar si el nuevo mensaje es repetido y sino añadirlo a la lista de mensajes
                          if (appData.modifyListOfMessages(appData.text)) {
                            setState(() {});
                          }
                          print(appData.messagesAsList);
                        },
                        padding: EdgeInsets.zero,
                        child: const Text(
                          "Send",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "Pick an Image from the System: ${appData.selectImagePath}"
                    ),
                    CupertinoButton(
                      onPressed: () async {
                        print("Escogiendo imagen...");
                        const XTypeGroup typeGroup = XTypeGroup(
                          label: 'images',
                          extensions: <String>['jpg', 'png'],
                        );
                        XFile? imagFile =
                            await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                        if (imagFile != null) {
                          final FileStat fileStat = await File(imagFile.path).stat();
                           if (fileStat.type != FileSystemEntityType.directory) {
                            print("imagen valida");
                            appData.selectImagePath = imagFile.path;
                            setState(() {
                              
                            });
                          }
                        }
                      },
                      child: const Text("Choose File"),
                    ),
                    CupertinoButton(
                      child: const Text("Send Image"), 
                      onPressed: () async {
                        appData.sendImageJson();
                      }
                      )
                  ],
                ),
                
              ],
            ),

            
          ),

          Expanded(
            child: ListView.builder(
              itemCount: appData.messagesAsList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> jsonObject = appData.messagesAsList[index];
                String date = jsonObject['date'];
                String OnTaptext = jsonObject['text'];
                String wholeTile = 'Date: $date | Text: $OnTaptext';
        
                return CupertinoListTile(
                  title: Text(wholeTile),
                  onTap: () async {
                    // Cuando tapeas elemento lista
                    appData.text = OnTaptext;
                    String textToSend = appData.text;
                    bool toSend = await appData.boolYesNoDialog(context, "Send Message", "Would you like to send again [ $textToSend ]?");
                    if (toSend) {
                      appData.send(appData.text);
                    }
                
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}








