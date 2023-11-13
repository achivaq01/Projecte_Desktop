import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

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
    _socketClient!.sink.add(jsonEncode(message));
  }

  send(String msg) {
    privateMessage(msg);

  }
}