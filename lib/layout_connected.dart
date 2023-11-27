import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'layout_gallery.dart';
import 'package:toastification/toastification.dart';

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

    //Singleton para toast
    ShowFlutterToast singletonToast = ShowFlutterToast.instance;
    singletonToast.setContext(context);

    return CupertinoPageScaffold(
      navigationBar:  CupertinoNavigationBar(
        middle: const Text("Connected"),
        trailing: CupertinoButton(
            padding: const EdgeInsets.all(0.0),
            onPressed: () {  
              print("Boton para ver personas");
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: const Text("Users"),
                    content: Container(
                      height: 200, // Set a specific height for the ListView
                      child: ListView.builder(
                        itemCount: appData.connectedUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Center( 
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  const TextSpan(
                                    text: "User ",
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  TextSpan(
                                    text: "'${appData.connectedUsers[index]["id"]}'",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
                                  ),
                                  const TextSpan(
                                    text: " from platform ",
                                    style: TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                  TextSpan(
                                    text: "'${appData.connectedUsers[index]["platform"]}'",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
                                  ),
                                ],
                              ),
                          ));
                        },
                      ),
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
                  CupertinoIcons.sidebar_left,
                  color:  CupertinoColors.activeBlue,

                  size: 24.0,
                  semanticLabel: 'Text to announce in accessibility modes',
            )),
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
                      ),
                    CupertinoButton.filled(
                      onPressed: () {  
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LayoutGallery(),
                            ),
                          );
                      },
                    child: const Text(
                          "Gallery",
                          style: TextStyle(
                            fontSize: 14,
                          ),),
                )],
                ),
                
              ],
            ),

            
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
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
                    
                    appData.text = OnTaptext;
                    String textToSend = appData.text;
                    bool toSend = await appData.boolYesNoDialog(context, "Send Message", "Would you like to send again [ $textToSend ]?");
                    if (toSend) {
                      appData.send(appData.text);
                    }
                
                  },
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

class ShowFlutterToast {
  ShowFlutterToast._();

  BuildContext? _contextToUse;

  static final ShowFlutterToast _instance = ShowFlutterToast._();

  static ShowFlutterToast get instance => _instance;

  void setContext(BuildContext context) {
    _instance._contextToUse = context;
  }

  void showToastFunction(String toastTile, String toastDescription) {
    print("Funcion para mostrar toast");
    if (_contextToUse != null) {
      toastification.show(
        context: _contextToUse!,
        title: toastTile,
        description: toastDescription,
        autoCloseDuration: const Duration(seconds: 5),
      );
    } else {
      print('Context is null. Cannot show toast.');
    }
  }
}
