import 'dart:io';

import 'package:chat/helpers/firebase_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  TextEditingController controller = TextEditingController();
  FireBaseHelper helper = FireBaseHelper();
  bool isComposing = false;
  bool isSendingImage = false;

  void reset() {
    controller.clear();
    setState(() {
      isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(children: [
        isSendingImage ? LinearProgressIndicator() : Container(),
        Row(children: [
          IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () async {
                File file = File((await ImagePicker.platform
                        .pickImage(source: ImageSource.camera))
                    .path);
              }),
          Expanded(
              child: TextField(
            decoration:
                InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
            onChanged: (text) {
              setState(() {
                isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (text) {
              helper.sendMessage(text);
              reset();
            },
          )),
          IconButton(
              icon: Icon(Icons.send),
              onPressed: isComposing
                  ? () {
                      helper.sendMessage(controller.text);
                      reset();
                    }
                  : null),
        ])
      ]),
    );
  }
}
