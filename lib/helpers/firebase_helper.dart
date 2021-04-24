import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBaseHelper {
  static final FireBaseHelper _instance = FireBaseHelper.internal();

  User currentUser;

  factory FireBaseHelper() => _instance;

  FireBaseHelper.internal() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      this.currentUser = user;
    });
  }

  Future<User> getUser() async {
    if (currentUser != null) return currentUser;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    return userCredential.user;
  }

  Stream<QuerySnapshot> snapshots() {
    FirebaseFirestore.instance
        .collection("message")
        .orderBy("time")
        .snapshots();
  }

  Future<void> sendMessage(String text) async {
    User user = await getUser();

    FirebaseFirestore.instance.collection("message").add({
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhoto": user.photoURL,
      "text": text,
      "time": Timestamp.now()
    });
  }

  Future<void> sendImage(File file) async {
    User user = await getUser();

    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child("imgs")
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(file);
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();

    FirebaseFirestore.instance.collection("message").add({
      "imgURL": url,
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhoto": user.photoURL,
      "time": Timestamp.now()
    });
  }
}
