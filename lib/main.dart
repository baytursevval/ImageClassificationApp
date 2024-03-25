//import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File? filePath;

  //String label= '';
  //double confidence= 0.0;


  Future<void> _tfliteInit() async{
    String? res = await Tflite.loadModel(
        model: "assets/1.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
  // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath=imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );

    if(recognitions==null) {
      devtools.log("recognitions is null");
      return;
    }
    devtools.log(recognitions.toString());
    //setState(() {
      //confidence= (recognitions[0]['confidence']*100);
      //label=recognitions[0]['label'].toString();
    //});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfliteInit();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child:SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage("assets/img.jpg"),
                            ),
                          ),
                          child: filePath == null ? const Text('')
                              : Image.file(filePath!, fit: BoxFit.fill),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("label",
                                style:  TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              ),
                               SizedBox(
                                height: 12,
                              ),
                              Text("Confidence: ",
                                style:  TextStyle(
                                fontSize: 18,
                              ),
                              ),
                               SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ) ,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child:
                const Text("Take a photo",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: (){
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child:
                const Text("Pick from gallery",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
