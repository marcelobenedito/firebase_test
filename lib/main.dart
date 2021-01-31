import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    )
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  File _image;
  String _statusUpload = "Status not initialized!";
  String _url;

  Future _getImage(bool fromCamera) async {
    File selectedImage;
    if (fromCamera) {
      selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      selectedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _image = selectedImage;
    });
  }

  Future _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference rootPath = storage.ref();
    Reference file = rootPath.child("photos").child("photo1.jpg");
    UploadTask task = file.putFile(_image);

    task.snapshotEvents.listen((TaskSnapshot event) {
      if (event.state == TaskState.running) {
        setState(() {
          _statusUpload = "In progress";
        });
      } else if (event.state == TaskState.success) {
        setState(() {
          _statusUpload = "Upload success!";
        });
      }
    });

    task.then((TaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });
  }

  Future _getUrlImage(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    print("Url result: $url");
    setState(() {
      _url = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Image"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(_statusUpload),
            RaisedButton(
              child: Text("Camera"),
                onPressed: () {
                  _getImage(true);
                }
            ),
            RaisedButton(
              child: Text("Gallery"),
                onPressed: () {
                  _getImage(false);
                }
            ),
            _image == null
            ? Container()
            : Image.file(_image),
            _image == null
            ? Container()
            : RaisedButton(
              child: Text("Upload"),
              onPressed: _uploadImage
            ),
            _url == null
            ? Container()
            : Image.network(_url)
          ],
        ),
      ),
    );
  }
}
