
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) :super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  String titleText = 'Music Key Finder';
  late PlatformFile? selectedFile;
  late http.MultipartRequest? fileUploadRequest;
  // function to determine the  condition of thre previous state
  void onRefreshButtonPressed() {
  if (wasLastActionRecording) {
    // Send the request for the recorded audio
    stopRecorder();
  } else {
    // Send the request for the selected file
    uploadFile();
  }
  }


   @override
  void initState() {
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  final recorder = FlutterSoundRecorder();
  bool wasLastActionRecording = false;

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted!';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    String filePath = '${directory!.path}/my_recording.aac';
    await recorder.startRecorder(toFile: filePath);
  }

  Future stopRecorder() async {
    final filePath = await recorder.stopRecorder();
    final file = File(filePath!);
    print('Recorded file path: $filePath');
     var request = http.MultipartRequest('POST', Uri.parse('Your API Endpoint'));
    request.files.add(await http.MultipartFile.fromPath('audio', file.path));


    // Send the request
    var response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      print('Uploaded!');
    } else {
      print('Failed to upload.');
    }

    wasLastActionRecording = true;
  }
  // Function to handle file selection and create upload request
  Future<void> selectAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      selectedFile = result.files.first;
      fileUploadRequest = http.MultipartRequest('POST', Uri.parse('http://192.168.184.203:8000/keyfinder/upload/'));
      fileUploadRequest!.files.add(http.MultipartFile(
        'file', // consider 'file' as a field name on the server
        File(selectedFile!.path!).readAsBytes().asStream(),
        File(selectedFile!.path!).lengthSync(),
        filename: selectedFile!.name,
      ));

      // Send the request and get the response
      var response = await fileUploadRequest!.send();
      if (response.statusCode == 200) {
  String responseBody = await response.stream.bytesToString();
  var data = jsonDecode(responseBody);
  
  if (data is Map && data.containsKey('likely_key')) {
    setState(() {
      titleText = data['likely_key'].toString();
    });
  } else {
    print('Unexpected response format');
  }
  } 
  else {
    print('Upload failed with status: ${response.statusCode}.');
  }
    } else {
      // User canceled the picker
    }
  }


  // Function to send the upload request
  Future<void> uploadFile() async {
    wasLastActionRecording = false;//setting the status of the refresh
    fileUploadRequest = http.MultipartRequest('POST', Uri.parse('http://192.168.184.203:8000/keyfinder/upload/'));

    if (selectedFile != null) {
      fileUploadRequest!.files.add(http.MultipartFile(
        'file',
        File(selectedFile!.path!).readAsBytes().asStream(),
        File(selectedFile!.path!).lengthSync(),
        filename: selectedFile!.name,
      ));
    if (fileUploadRequest != null) {
      var response = await fileUploadRequest!.send();
      if (response.statusCode == 200) {

        String responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        if (data is Map && data.containsKey('likely_key')) {
          setState(() {
            titleText = data['likely_key'].toString();
          });
        } else {
          if (kDebugMode) {
            print('Unexpected response format');
          }
        };
      } else {
        print("Not Uploaded!");
      }
    } else {
      print("No file selected!");
    }
  }



  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Colors.grey[200],//backround color
        appBar: AppBar(
          title: const Text('My App'),
          backgroundColor:  const Color.fromARGB(255, 37, 125, 189),
        ),
        body: Column(
        children: <Widget>[
            Expanded(
              child: Stack(
                children:<Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/images.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Container(
                  color: Colors.black.withOpacity(0.1),
                  alignment:  Alignment.center,
                  child:  
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  )
                )
                ]
                ),
            ),
            Container(
              height: 100,
              child: MusicWaveAnimation(),
              
              color: Colors.white,
            ),
            Expanded(
              child: Container(//button container
              margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration:BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:[
                      Color.fromARGB(255, 25, 16, 116).withOpacity(0.02),
                       Color.fromARGB(255, 37, 125, 189),
                     ]
                     ),
                ),
                // color: Color.fromARGB(255, 9, 222, 172),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                    child: const Center(
                      child: Text('lets determine the key',
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,)
                      
                      
                    )),),// key text
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 37, 125, 189),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color.fromARGB(255, 9, 222, 172),
                                  width: 2,
                                  )
                              ),
                              child:
                              ElevatedButton(
                                onPressed: () async {
                                  if (recorder.isRecording) {
                                    await stopRecorder();
                                    setState(() {});
                                  } else {
                                    await startRecord();
                                    setState(() {});
                                  }
                                },
                                child: Icon(
                                  recorder.isRecording ? Icons.stop : Icons.mic,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              
                              height: 100,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 37, 125, 189),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Color.fromARGB(255, 9, 222, 172),
                                  width: 2,
                                  )
                              ),
                              child: 
                              ElevatedButton(
                                onPressed: onRefreshButtonPressed,
                                child: Text('Refresh'),
                              )
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 37, 125, 189),
                                borderRadius: BorderRadius.circular(50), 
                                border: Border.all(
                                  color: Color.fromARGB(255, 9, 222, 172),
                                  width: 2,
                                  )
                              ),
                              child: 
                                IconButton(
                                  iconSize: 60,
                                  icon: Icon(Icons.music_note),
                                  onPressed: 
                                  selectAndUploadFile,
                                )
                                
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('      listen',
                        style: TextStyle
                        (fontSize: 20),
                        textAlign: TextAlign.center,),
                        Text('refresh',
                        style: TextStyle
                        (fontSize: 20),
                        textAlign: TextAlign.center,),
                        Text('Upload     ',
                        style: TextStyle
                        (fontSize: 20),
                        textAlign: TextAlign.center,),
                      ],
                    ),
                  ],
                ), 
              ),
            ),
            Container(
              height:100,
              color:   Colors.white,
              child: Center(
                child: Container(
                  height:95,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:[ 
                          Color.fromARGB(255, 37, 125, 189).withOpacity(0.5),
                          Color.fromARGB(255, 189, 71, 197).withOpacity(0.5),
                          Color.fromARGB(255, 53, 81, 220).withOpacity(0.5)]
                      ),
                  ),
                  child: const Center(child: Text(' \"Playing a wrong note is insignificant   \n but \n playing without passion is inexcusable"\ \n-Beethoven',
                  textAlign: TextAlign.center
                  ,
                  style: TextStyle(
                    color:Color.fromARGB(255, 3, 16, 13),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),)
                  ),
            
                ),
              ), 
            ),
          ],
        ),
      ),
    );
  }
}

// animarion class
class MusicWaveAnimation extends StatefulWidget {
  const MusicWaveAnimation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MusicWaveAnimationState createState() => _MusicWaveAnimationState();
}

class _MusicWaveAnimationState extends State<MusicWaveAnimation> {
  late Timer _timer;
  final List<double> _waveValues = [];
  final int _numberOfWaves = 50; // Increased number of waves
  final double _amplitude = 50.0;
  final double _period = 6.0;
  var _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) { // Reduced time of reaction
      _phase += 0.1;
      _updateWaveValues();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateWaveValues() {
    setState(() {
      _waveValues.clear();
      for (int i = 0; i < _numberOfWaves; i++) {
        double value = _calculateWaveValue(i);
        _waveValues.add(value);
      }
    });
  } 

  double _calculateWaveValue(int index) {
    double waveLength = 1.5 * pi / _period; 
    double scaledIndex = index * 1.5;
    double scaledPhase = _phase - scaledIndex;
    double value1 = _amplitude * sin(waveLength * scaledPhase);
    double value2 = _amplitude * sin(waveLength * scaledPhase + 3.3*waveLength);
    double value3 = _amplitude / 3 * sin(3 * waveLength * scaledPhase);
    double value4 = _amplitude / 2 * sin(2 * waveLength * scaledPhase);
    double value = value2 + value1 + value3 + value4;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _waveValues
            .map((value) => _buildWave(value))
            .toList(),
      ),
    );
  }

  Widget _buildWave(double value) {
    return Container(
      width: 4, // Adjust the width of each wave
      height: value.abs() + 10, // Adjust the height of each wave
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
          colors:[Colors.blue,Color.fromARGB(255, 214, 127, 193), Color.fromARGB(255, 144, 126, 244)]
        )
      ),
    );
  }
}




