import 'package:flutter/cupertino.dart';

class LayoutConnected extends StatelessWidget{
  const LayoutConnected({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Conected"),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Conected",
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(0, 200, 0, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
