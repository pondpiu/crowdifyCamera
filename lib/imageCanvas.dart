import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'stickerPainter.dart';

class ImageCanvasArguments {
  final Uint8List mainImageByte;
  final Uint8List mainPeopleImageByte;

  ImageCanvasArguments(this.mainImageByte, this.mainPeopleImageByte);
}

class ImageCanvas extends StatefulWidget {
  @override
  _ImageCanvasState createState() => _ImageCanvasState();
}

class _ImageCanvasState extends State<ImageCanvas> {
  bool firstLoad = true;
  Uint8List mainImageByte;
  Uint8List mainPeopleImageByte;
  List<Uint8List> _peopleImagesByte = List<Uint8List>();

  Future<ui.Image> getImageFromByte(imageByte) async {
    final image = await decodeImageFromList(imageByte);
    return image;
  }

  Future addImageFromCamera() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    final imageByte = await imageFile.readAsBytes();
    setState(() {
      _peopleImagesByte.add(imageByte);
    });
  }

  Future addImageFromGallery() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final imageByte = await imageFile.readAsBytes();
    setState(() {
      _peopleImagesByte.add(imageByte);
    });
  }

  Future<Object> getUiImageForCanvas() async {
    var map = new Map();
    var uiImages = List<ui.Image>();
    for (var i = 0; i < _peopleImagesByte.length; i++) {
      final image = await getImageFromByte(_peopleImagesByte[i]);
      uiImages.add(image);
    }
    map['peopleImages'] = uiImages;
    final mainImage = await getImageFromByte(mainImageByte);
    map['mainImage'] = mainImage;
    final mainPeopleImage = await getImageFromByte(mainPeopleImageByte);
    map['mainPeopleImage'] = mainPeopleImage;
    map['peopleImagesByte'] = _peopleImagesByte;
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      final ImageCanvasArguments args =
          ModalRoute.of(context).settings.arguments;
      mainImageByte = args.mainImageByte;
      mainPeopleImageByte = args.mainPeopleImageByte;
      _peopleImagesByte.add(mainPeopleImageByte);
      firstLoad = false;
    }

    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Gallery",
        currentButton: FloatingActionButton(
            heroTag: "gallery",
            backgroundColor: Colors.greenAccent,
            mini: true,
            onPressed: addImageFromGallery,
            tooltip: "Image From Gallery",
            child: Icon(Icons.photo_library))));

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Camera",
      currentButton: FloatingActionButton(
        heroTag: "camera",
        backgroundColor: Colors.blueAccent,
        mini: true,
        onPressed: addImageFromCamera,
        tooltip: 'Image From Camera',
        child: Icon(Icons.add_a_photo),
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Crowdify Camera'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'Save image',
            onPressed: () {
              print("onPressed");
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_upload),
            tooltip: 'publish image',
            onPressed: () {
              print("onPressed");
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder(
                future: getUiImageForCanvas(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    ui.Image mainImage = snapshot.data['mainImage'];
                    ui.Image mainPeopleImage = snapshot.data['mainPeopleImage'];
                    List<ui.Image> peopleImages = snapshot.data['peopleImages'];
                    List<Uint8List> peopleImagesByte =
                        snapshot.data['peopleImagesByte'];
                    return FittedBox(
                      child: SizedBox(
                        width: mainImage.width.toDouble(),
                        height: mainImage.height.toDouble(),
                        child: CustomPaint(
                          painter: StickerPainter(mainImage, mainPeopleImage,
                              peopleImages, peopleImagesByte),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text('Something went wrong');
                  } else {
                    return Text('Loading');
                  }
                }),
            Expanded(
              // flex: 1,
              child: CarouselSlider(
                enableInfiniteScroll: false,
                items: _peopleImagesByte.length > 0
                    ? _peopleImagesByte.map((imageByte) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _peopleImagesByte.remove(imageByte);
                            });
                          },
                          child: Container(
                            child: Image.memory(imageByte),
                          ),
                        );
                      }).toList()
                    : mockList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.accessibility),
          childButtons: childButtons),
    );
  }

  List<Widget> mockList() {
    return [1, 2, 3, 4, 5].map((i) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.amber),
              child: Text(
                'text $i',
                style: TextStyle(fontSize: 16.0),
              ));
        },
      );
    }).toList();
  }
}
