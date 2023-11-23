import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
class LayoutGallery extends StatefulWidget {
  const LayoutGallery({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LayoutGalleryState();

  
}

class _LayoutGalleryState extends State<LayoutGallery> {
  
    @override
    Widget build(BuildContext context) {
      AppData appData = Provider.of<AppData>(context);

      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        middle: Text("Gallery"),
        ),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, 
        ),
          itemCount: appData.imagesAsList.length,
          itemBuilder: (context, index) {
              String base64Image = appData.imagesAsList[index]['img'];
              Uint8List _bytesImage = Base64Decoder().convert(base64Image);
              return GestureDetector(
                  onTap: () {
                    print("Imagen desde galeria!!");
                    appData.sendGalleryImage(base64Image);
                  },
                  child: Image.memory(
                    _bytesImage,
                    fit: BoxFit.cover,
                  ),
              );
          }
        )
      );
    }
}