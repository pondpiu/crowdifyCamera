import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  static Future<StorageTaskSnapshot> uploadImage(File image) {
    print(" ==== uploading file =====");
    String imagePath = image.path;
    String originalFileName = basenameWithoutExtension(imagePath);
    String calculatedFileName =
        originalFileName += Random().nextInt(10000).toString();

    print(calculatedFileName);

    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(calculatedFileName);

    StorageUploadTask uploadTask = storageRef.putFile(image);
    return uploadTask.onComplete;
  }

  static Future<QuerySnapshot> retrieveImageList() {
    /* Firestore.instance
    .collection('talks')
    .where("topic", isEqualTo: "flutter")
    .snapshots()
    .listen((data) =>
        data.documents.forEach((doc) => print(doc["title"]))); */
     return Firestore.instance.collection("crowdifycamera").getDocuments();
  }

  static void downloadImage(String imageName) {}

  static void uploadUrlToDatabase(String url) {
    Firestore.instance.collection('crowdifycamera').add({'url': url});
  }
}
