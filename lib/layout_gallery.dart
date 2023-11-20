import 'package:flutter/cupertino.dart';

class LayoutGallery extends StatefulWidget {
  const LayoutGallery({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LayoutGalleryState();

  
}

class _LayoutGalleryState extends State<LayoutGallery> {
    @override
    Widget build(BuildContext context) {
      return CupertinoPageScaffold(
        child: Text("Textito de la galeria"),
      );
    }
}