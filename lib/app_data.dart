import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path_provider/path_provider.dart';


enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
}

class AppData with ChangeNotifier {
  IOWebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String ip = "";
  String message = "";
  String text = "";
  String selectImagePath = "";

  List<dynamic> messagesAsList = List.empty();

  Future<void> connectToServer() async {
    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));

    _socketClient = IOWebSocketChannel.connect("ws://$ip");
    _socketClient!.stream.listen(
        (message) {
          final data = jsonDecode(message);

          if(connectionStatus != ConnectionStatus.connected) {
            connectionStatus = ConnectionStatus.connected;
            //mensaje inicial al conectarse
            messageOnConnect();
            notifyListeners();
          }
        }
    );
  }

  privateMessage(String msg) {
    final message = {
      'platform': "Flutter",
      'text': text
    };
    print(message);
    _socketClient!.sink.add(jsonEncode(message));
  }

  messageOnConnect() {
    final message = {
      'type':'platform',
      'platform':'flutter'
    };
    _socketClient!.sink.add(jsonEncode(message));
  }

  send(String msg) {
    privateMessage(msg);
    print("Se envio: $msg");
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/messages.json');
  }

  Future<void> createFileIfNotExists() async {
    final file = await _localFile;
    if (!await file.exists()) {
      await file.create();
      DateTime now = DateTime.now();
      await file.writeAsString('[{"date":"$now","text":"hello world!"}]');
    }
    
  }

  void readJson() async {
    File file = await _localFile;
    String jsonString = file.readAsStringSync();
    print(jsonString);

    messagesAsList = jsonDecode(jsonString);

  }

  bool modifyListOfMessages(String newString) {
    print("EL nuevo string:$newString");

    for (var jsonObject in messagesAsList) {
      if (jsonObject['text'] == newString) {
        return false;
      }
    }
    // En cas de no trobar un string similar retorna True i l'afegeix tant en RAM com en l'arxiu Json de documents
    DateTime now = DateTime.now();
    Map<String, dynamic> newEntry = {"date":"$now","text":newString};
    messagesAsList.add(newEntry);
    addElementToJson();
    return true;
  }

  Future<void> addElementToJson() async {
    File file = await _localFile;

    // Convert messagesAsList to JSON string
    String jsonString = jsonEncode(messagesAsList);

    // Write the JSON string to the file
    await file.writeAsString(jsonString);
  }

  Future<bool> boolYesNoDialog(BuildContext context, String title, String message) async {
    bool result = false;
    await showCupertinoDialog(
      context: context, 
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop(false); // User chose No
            },
          ),
          CupertinoDialogAction(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop(true); // User chose Yes
            },
          ),
        ],
        );
      }).then((value) {
        result = value ?? false;
      });

      return result;
  }
  Future<void> sendImageJson() async {
    Future<bool> imageExists = File(selectImagePath).exists();
    if (await imageExists) {
      File imageFile = File(selectImagePath);
      List<int> imageBytes = imageFile.readAsBytesSync();
      String base64Img = base64Encode(imageBytes);

      // Enviar la imagen via JSON
      final message = {
      'type':'image',
      'img':base64Img
      };
      print("Se envio la imagen: $selectImagePath");
      _socketClient!.sink.add(jsonEncode(message));
    }
  }
}