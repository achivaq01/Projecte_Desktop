import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
        middle: Text("Conected"),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 50),
          _buildTextFormField("message", "hi!", _messageController),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 96,
              height: 32,
              child: CupertinoButton.filled(
                onPressed: () {
                  appData.text = _messageController.text;
                  appData.send(appData.text);
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
          ]),

        ],
      ),
    );
  }
}








