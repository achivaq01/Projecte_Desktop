import 'package:client_flutter/layout_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';
import 'layout_connected.dart';
import 'layout_connecting.dart';
import 'layout_login.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  // Definir el contingut del widget 'App'
  Widget _setLayout(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    
    // Carreguem la llista a AppData amb els missatges i imatges en memoria
    appData.createFileIfNotExists();
    appData.readJson();
    appData.createOrAccesImageFile();
    appData.readImageJson();

    // Para ir a galeria
    if (appData.onGallery) {
      print("Cambio a galeria");
    }

    print(appData.connectionStatus);
    switch (appData.connectionStatus) {
      case ConnectionStatus.connected:
        return const LayoutConnected();
      case ConnectionStatus.connecting:
        return const LayoutConnecting();
      case ConnectionStatus.login:
        return const LoginPage();
      default:
        return const LayoutConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.light),
      home: _setLayout(context),
    );
  }
}