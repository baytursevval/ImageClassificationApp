import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devtools;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label= '';
  double confidence = 0.0;
  final FlutterTts flutterTts = FlutterTts();
/*
  Future<void> _uploadImage(File imageFile) async {
    var request =
    http.MultipartRequest('POST', Uri.parse('http://192.168.218.77:9090/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseBody);
        setState(() {
          _label = jsonData['class'];
          _confidence = jsonData['confidence'];
        });
      } else {
        print('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e' + "hataaaaaaa..........");
    }
  }
  */
  Future<void> uploadFile(File imageFile) async { //bu fonksiyon çağrıldığında, resim dosyasının yükleme işlemi tamamlanana kadar diğer işlemler devam eder.
    // Dio isteklerini yapmak için bir Dio nesnesi oluştur
    var dio = Dio();

    // POST isteği göndermek için FormData oluştur
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path),
    });

    print("sifirinci cikis");
    try {
      print("birinci cikis");
      // API'ye POST isteği gönder
      var response = await dio.post(
        //'https://us-central1-vegetables-420118.cloudfunctions.net/predict',
        //'https://us-central1-mydemoproject-421621.cloudfunctions.net/predict',
        'https://us-central1-mysecproject-421708.cloudfunctions.net/predict',
        data: formData,
      );

      print("ikinci cikis");
      // Yanıtı kontrol et ve etiket ve güvenlik değerini al
      if (response.statusCode == 200) {
        // API'den gelen yanıtı işle
        var responseData = response.data;
        print("ucuncu cikis");

        setState(() { //yapılan değişiklikleri bildirmek için
          label = responseData['class'];
          confidence = responseData['confidence'];
          print("upload file setstate"+imageFile.toString());
        });

        print('Label: $label');
        print('Confidence: $confidence');
      } else {
        print('HTTP isteğinde hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('İstek gönderilirken hata oluştu: $e');
    }
  }
  Future<void> pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    try{
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      //resim seçmek için xfile kullan. xfile resim bilgilerini tutar
      if (image == null) return;

      var imageFile = File(image.path); //file nesnesi oluştur (image'i jpg olarak aldık)
      print(imageFile);
      //print(imageMap.toString());
      print("galerideyiz");
      setState(() { //durum değişikliklerini bu fonk.a koyarız
        filePath = imageFile;
      });
      // Görsel seçildikten sonra dosyayı yükle
      await uploadFile(imageFile);
    } catch (e) {
      print('Resim seçilirken hata oluştu: $e');
    }
  }
  Future<void> _speakLabel() async {
    if (label.isNotEmpty) {
      // Label boş değilse sesli olarak oku
      await flutterTts.speak(label);
    } else {
      // Label boşsa kullanıcıya uyarı ver
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Uyarı"),
              content: Text("Etiket bilgisi bulunamadı."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Tamam"),
                ),
              ],
            ),
      );
    }
  }
  Future<void> pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    try{
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      //resim seçmek için xfile kullan. xfile resim bilgilerini tutar
      if (image == null) return;

      var imageFile = File(image.path); //file nesnesi oluştur (image'i jpg olarak aldık)
      print(imageFile);
      //print(imageMap.toString());
      print("galerideyiz");
      setState(() { //durum değişikliklerini bu fonk.a koyarız
        filePath = imageFile;
      });
      // Görsel seçildikten sonra dosyayı yükle
      await uploadFile(imageFile);
    } catch (e) {
      print('Resim seçilirken hata oluştu: $e');
    }
  }

  Future<void> _speakText(String text) async {

    //await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }


/*
  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
    });

    await _uploadImage(_imageFile!);
  }

  Future<void> _pickImageGallery() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
    });

    await _uploadImage(_imageFile!);
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold( //temel layout
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            // Metni sesli olarak oku
            _speakText("Let's classify vegetables");
          },
          child: Container(
            //width: 200,
            height: 200,
            alignment: Alignment.center,
            //padding: EdgeInsets.symmetric(horizontal: 16.0), // Kenarlardan boşluk
            decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(5.0), // Kenar yuvarlatma
          ),
          child: const Text(
            "Let's Classify Vegetables..",
            style: TextStyle(
            color: Colors.white, // Metin rengi
            ),
          ),
          ),
        ),
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
                                  image: AssetImage('assets/img.jpg'),
                                )
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (label != null) {
                                  _speakLabel();
                                }
                              },
                            child: filePath == null ? const Text('')
                                : Image.file(filePath!,
                                fit: BoxFit.fill)// Show text if filePath is null
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                "Label: " + label,
                                //"Label: $label",
                                style:  const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Confidence: % ${confidence.toStringAsFixed(0)}",
                                style:  const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
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
                onPressed: () async {
                  pickImageCamera();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.cyan),
                child:
                const Text(" Take a photo   ",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () async {
                  pickImageGallery();
                  print("hello galeri iicinde");

                  /*
                if (result != null) {
                  File filePath = File(result.files.single.path ?? "");
                  await uploadFile(filePath);
                  print("filepath "+ filePath.toString()+ filePath.toString());
                }
                */
                  /*
                  final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                  if(returnedImage == null) return;
                  setState(() {
                    filePath=File(returnedImage!.path);

                    print("set state pick im from gal ");
                  });
*/
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.cyan),
                child:
                const Text("Pick from gallery",
                ),

              ),
              IconButton(
                icon: const Icon(Icons.speaker_phone_outlined, size: 110),
                onPressed: () async {
                  _speakLabel();
                  //flutterTts.speak('Hello, Flutter Text-to-Speech!');
                  //_speak();
                },
              ),
              Container(
                  height: 110,
                  width: 400,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/img2.jpg'),
                      )
                  ),

              ),
            ],

          ),
        ),
      ),
    );
  }
}
