import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase/firebaseUtil.dart';

import 'dart:io';

class ImageUpload extends StatelessWidget {
  Future getImageFromGallery() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    print('Image');

    final StorageTaskSnapshot downloadUrl =
        await FirebaseUtil.uploadImage(image);

    final String url = (await downloadUrl.ref.getDownloadURL());

    print('URL Is $url');
    FirebaseUtil.uploadUrlToDatabase(url);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uploading Image',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase upload'),
        ),
        body: Center(
          child: UnicornButton(
            hasLabel: true,
            labelText: "Sticker",
            currentButton: FloatingActionButton(
              heroTag: "sticker",
              backgroundColor: Colors.orangeAccent,
              mini: true,
              onPressed: getImageFromGallery,
              child: Icon(Icons.arrow_upward),
            ),
          ),
        ),
      ),
    );
  }
}
