import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicorndial/unicorndial.dart';
import 'imageCanvas.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

// REMOVE BG API ENDPOINTS
// final String REMOVEBG_ENDPOINT = 'http://192.168.200.37:5000/removebg';
final String REMOVEBG_ENDPOINT = 'https://api.remove.bg/v1.0/removebg';
final String REMOVEBG_APIKEY = "REMOVED :P get api key from api above ^^^";


class ImagePick extends StatefulWidget {
  @override
  _ImagePickState createState() => _ImagePickState();
}

class _ImagePickState extends State<ImagePick> {
  Uint8List _imageOriByte;
  Uint8List _imageNoBGByte;
  bool isLoading = false;

  // Get image, either from Gallary or Camera
  // FIXME: Do permission check
  getImage(ImageSource imgSource) async {

    setState(() {
      isLoading = true;
    });

    var imageFile = await ImagePicker.pickImage(source: imgSource, maxHeight: 3000, maxWidth: 3000);

    if(imageFile == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var serverImageBytes = await removeBG(imageFile);

    _imageOriByte = imageFile.readAsBytesSync();
    _imageNoBGByte = serverImageBytes;

    isLoading = false;

    Navigator.popAndPushNamed(
      context,
      '/imageCanvas',
      arguments: ImageCanvasArguments(_imageOriByte, _imageNoBGByte)
    );
  }
  
  Future<Uint8List> removeBG(File imageFile) async {

    final mimeTypeData = lookupMimeType(imageFile.path).split('/');
    final request = http.MultipartRequest("POST", Uri.parse(REMOVEBG_ENDPOINT));

    request.headers['X-Api-Key'] = REMOVEBG_APIKEY;
    request.fields['size'] = 'auto';

    final file = await http.MultipartFile.fromPath(
      'image_file', 
      imageFile.path, 
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1])
    );

    request.files.add(file);

    print(imageFile.lengthSync());

    print(mimeTypeData);
    print('sending request');

    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      print(response.headers);
      return response.bodyBytes;
    } else {
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      print('error');
      setState(() {
        isLoading = false;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Gallery",
        currentButton: FloatingActionButton(
            heroTag: "gallery",
            backgroundColor: Colors.blue,
            mini: true,
            onPressed: () => getImage(ImageSource.gallery),
            tooltip: "Image From Gallery",
            child: Icon(Icons.photo_library))));

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Camera",
      currentButton: FloatingActionButton(
        heroTag: "camera",
        backgroundColor: Colors.indigo,
        mini: true,
        onPressed: () => getImage(ImageSource.camera) ,
        tooltip: 'Image From Camera',
        child: Icon(Icons.add_a_photo),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New'),
      ),
      body: Center(
        child: isLoading
            ? SpinKitCubeGrid (
            color: Colors.blue,
            size: 60.0,
        ): Text('Selected an image to begin.')
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons),
    );
  }
}
