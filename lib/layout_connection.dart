import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';


class LayoutConnection extends StatefulWidget {
  const LayoutConnection({Key? key}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _LayoutDisconnectedState();
}

class _LayoutDisconnectedState extends State<LayoutConnection> {
  final _ipController = TextEditingController();

  Widget _buildTextFormField(
    String label,
    String defaultValue,
    TextEditingController controller,
  ) {
    controller.text =defaultValue;

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
        middle: Text("WebSockets Client"),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 50),
          _buildTextFormField("Server IP", "", _ipController),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 96,
              height: 32,
              child: CupertinoButton.filled(
                onPressed: () {
                  appData.ip = _ipController.text;
                  appData.connectToServer();
                },
                padding: EdgeInsets.zero,
                child: const Text(
                  "Connect",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

}

