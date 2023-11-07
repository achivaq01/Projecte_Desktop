import 'package:flutter/cupertino.dart';

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
}

class AppData with ChangeNotifier {
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  String ip = "";
  String message = "";
}