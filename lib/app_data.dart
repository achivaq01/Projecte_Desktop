import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'package:path_provider/path_provider.dart';
import 'layout_connected.dart';

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
  login,
}

typedef ToastCallback = void Function({
    BuildContext? context,
    String? title,
    Duration? autoCloseDuration,
  });

class AppData with ChangeNotifier {
  IOWebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String ip = "";
  String message = "";
  String text = "";
  String selectImagePath = "";
  String userId = "";

  List<dynamic> connectedUsers = List.empty();

  bool onGallery = false;
  bool showErrorLoginMessage = false;

  List<dynamic> messagesAsList = List.empty();
  List<dynamic> imagesAsList = List.empty();

  // WebSocket management
  Future<void> connectToServer() async {
    connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));

    _socketClient = IOWebSocketChannel.connect("ws://$ip:8888");
    _socketClient!.stream.listen(
        (message) {     
          final data = jsonDecode(message);
          print(data);
          String jsonType = data["type"];
          switch (jsonType) {
            case "connected":
                print("En contected");
                userId = data["id"];
                connectionStatus = ConnectionStatus.login;
                notifyListeners();
              break;
            case "login":
                if (data["success"] == true) {
                  showErrorLoginMessage = false;
                  connectionStatus = ConnectionStatus.connected;
                  notifyListeners();
                } else {
                  print("NO FUE MANIN");
                  showErrorLoginMessage = true;
                  notifyListeners();
                }
              break;
            case "list":
                print("RECOJO LISTA DE PERSONAS");
                connectedUsers = data["list"];
                notifyListeners();
              break;
            case "new message":
                print("New message");
                if (connectionStatus == ConnectionStatus.connected) {
                  print("En pantalla contected, se puede mostrar toast");
                  ShowFlutterToast singletonToast = ShowFlutterToast.instance;
                  singletonToast.showToastFunction("New message", "There is a new message from user ${data['id']}");
                }
              break;
            default:
          }
          
        },onDone: () {
          print("Conexion Websocket cortada");
          connectionStatus = ConnectionStatus.disconnected;
          notifyListeners();
        },
        onError: (error) {
          print("WebSocket Error:");
          
          connectionStatus = ConnectionStatus.disconnected;
          notifyListeners();
        },
    );
  }

  privateMessage(String msg) {
    final message = {
      'type': "string",
      'text': text
    };
    print(message);
    _socketClient!.sink.add(jsonEncode(message));
  }

  messageOnConnect() {
    final message = {
      'type':'connect',
      'platform':'flutter'
    };
    _socketClient!.sink.add(jsonEncode(message));
  }

  send(String msg) {
    privateMessage(msg);
    print("Se envio: $msg");
  }

  sendAnyJson(Map<String, dynamic> message) {
    _socketClient!.sink.add(jsonEncode(message));
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

    messagesAsList = jsonDecode(jsonString);

  }

  void readImageJson() async {
    final directory = await getApplicationDocumentsDirectory();
    File imagesJson = File('${directory.path}/imageGallery.json');
    String jsonString = imagesJson.readAsStringSync();

    imagesAsList = jsonDecode(jsonString);
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

  Future<void> createOrAccesImageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    File imagesJson = File('${directory.path}/imageGallery.json');

  // Check if the file exists
  if (!await imagesJson.exists()) {
    // If the file doesn't exist, create it and write an empty JSON array
    await imagesJson.create();
    await imagesJson.writeAsString('[]');
    print("Json de imagenes creado");
  }
  }

  void canSaveImageLocally(Map<String, dynamic> imageAsMap) async {
      for (var jsonObject in imagesAsList) {
        if (jsonObject['img'] == imageAsMap['img']) {
          return;
        }
      }
      imagesAsList.add(imageAsMap);
      // En cas de no trobar un string similar retorna True i l'afegeix tant en RAM com en l'arxiu Json de documents
      final directory = await getApplicationDocumentsDirectory();

      String jsonString = jsonEncode(imagesAsList);
      File imagesJson = File('${directory.path}/imageGallery.json');
      // Write the JSON string to the file
      imagesJson.writeAsString(jsonString);
      print("Nueva imagen en JSON");

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

      // Guardar imagen en lista para galeria si no es repe
      canSaveImageLocally(message);
    }
  }

  void sendGalleryImage(String base64String) {
    // Enviar la imagen via JSON
    final message = {
    'type':'image',
    'img':base64String
    };
    print("Se envio la imagen desde la galeria");
    _socketClient!.sink.add(jsonEncode(message));
  }

}