import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class UI extends StatefulWidget {
  const UI({Key? key}) : super(key: key);

  @override
  _UIState createState() => _UIState();
}

class _UIState extends State<UI> {
  List? _outputs;
  XFile? _image;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future getImageCamera() async {
    var image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(File(_image!.path));
  }

  Future getImageGallery() async {
    var image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(File(_image!.path));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        "Animal Bird Detection",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Example of Machine Learning Model integrated with Flutter',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: _image == null
                      ? Container(
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4DCFF),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.all(20),
                              child: const Text(
                                "Upload an image",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(File(_image!.path)),
                                fit: BoxFit.cover),
                            color: Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25.0)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _outputs?[0]["label"] ?? "",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(0),
                    color: const Color(0xFFD4DCFF),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.0),
                        topLeft: Radius.circular(15.0),
                      ),
                    ),
                    child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15.0),
                            topLeft: Radius.circular(15.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF65708F),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    getImageCamera();
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  )),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF65708F),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    getImageGallery();
                                  },
                                  icon: const Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  )),
                            )
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
