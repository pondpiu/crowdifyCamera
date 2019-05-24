import 'dart:io';

import 'package:crowdifycamera/firebase/firebaseUtil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicorndial/unicorndial.dart';
import 'imagePick.dart';
import 'imageCanvas.dart';
import 'imageUpload.dart';
import 'imageFeeds.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snaplist/snaplist.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crowdify Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // When we navigate to the "/" route, build the FirstScreen Widget
        '/': (context) => FirstScreen(),
        // When we navigate to the "/second" route, build the SecondScreen Widget
        '/second': (context) => SecondScreen(),
        '/imagePick': (context) => ImagePick(),
        '/imageCanvas': (context) => ImageCanvas(),
        '/upload': (context) => ImageUpload(),
        '/feeds': (context) => ImageFeedsScreen(),
      },
    );
  }
}

class FirstScreen extends StatelessWidget {

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
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Upload",
        currentButton: FloatingActionButton(
            heroTag: "upload",
            backgroundColor: Colors.blue,
            mini: true,
            onPressed: () {
              getImageFromGallery();
            },
            tooltip: "Firebase Upload",
            child: Icon(Icons.arrow_upward))));

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "Create",
      currentButton: FloatingActionButton(
        heroTag: "create",
        backgroundColor: Colors.indigo,
        mini: true,
        onPressed: () => Navigator.pushNamed(context, '/imagePick'),
        tooltip: 'Create New',
        child: Icon(Icons.add),
      ),
    ));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Crowdify Camera'),
      ),
      body: 
        DefaultTabController(child: ImageFeedsScreen(), length: 1,),
        floatingActionButton: UnicornDialer(
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
          parentButtonBackground: Colors.redAccent,
          orientation: UnicornOrientation.VERTICAL,
          parentButton: Icon(Icons.add),
          childButtons: childButtons),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to the first screen by popping the current route
            // off the stack
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class ImageFeedsScreen extends StatefulWidget {
  @override
  _ImageFeedsScreenState createState() => new _ImageFeedsScreenState();
}

class _ImageFeedsScreenState extends State<ImageFeedsScreen> {
  List<String> urls = [];

  @override
  Widget build(BuildContext context) {
    return TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              FutureBuilder(
                  future: getImagesUrlFromFirebase(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      return ImageFeeds(images: snapshot.data);
                    else {
                      return ImageFeeds(images: new List());
                    }
                  })

              // ImageFeeds(images: urls, loadMore: _loadMoreItems)
            ],
        );
  }

  Future<List<String>> getImagesUrlFromFirebase() async {
    final QuerySnapshot snapshot =
        await Firestore.instance.collection("crowdifycamera").getDocuments();
    print(snapshot);
    List<String> imageUrlList = [];
    snapshot.documents.forEach((doc) => print(doc["url"]));
    snapshot.documents.forEach((doc) => imageUrlList.add(doc["url"]));
    return imageUrlList;
  }
}
