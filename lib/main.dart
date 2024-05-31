
import 'dart:convert';
import 'dart:ffi';
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
import 'package:path/path.dart' as path;

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
  final recorder = FlutterSoundRecorder();
  bool wasLastActionRecording = false;
  bool _isRecording = false;
  Timer? _timer;
  int _start = 00;
  String? lastUploadedFileName;

  void startTimer() {
    _isRecording = true;
    lastUploadedFileName = null;
    _start = 00;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          _start++;
        },
      ),
    );
  }

  void stopTimer() {
    _isRecording = false;
    _timer?.cancel();
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsFormatted = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secondsFormatted';
  }


  // function to determine the  condition of thre previous state
  void onRefreshButtonPressed() {
    if (kDebugMode) {
      print('refreshed');
    }
  if (wasLastActionRecording) {
    // Send the request for the recorded audio
     Future<void> fetchData() async {
   final filePath = await recorder.stopRecorder();
    final file = File(filePath!);
    if (kDebugMode) {
      print('Recorded file path: $filePath');
    }

    var  request = http.MultipartRequest('POST', Uri.parse('http://192.168.81.203:8000/keyfinder/upload/'));
    request.files.add(http.MultipartFile(
      'file',
      file.readAsBytes().asStream(),
      file.lengthSync(),
      filename: path.basename(file.path),
    ));

    // Send the request
    var response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);
      if (data is Map && data.containsKey('predicted_key')) {
        setState(() {
          titleText = data['predicted_key'].toString();
        });
      } else {
        if (kDebugMode) {
          print(response);
          print('Unexpected response format');
        }
      } 
    } else {
      if (kDebugMode) {
        print('Failed to upload. : ${response.statusCode}');
      }
      String responseBody = await response.stream.bytesToString();
      if (kDebugMode) {
        print('Response body: $responseBody');
      }
    }
    stopTimer();

    setState(() {
      _isRecording = false; // Update the animation state
      wasLastActionRecording = true;
    });
  }
    fetchData();
    // stopRecorder();
  } else {
    // Send the request for the selected file
    uploadFile();
    if (kDebugMode) {
      print('upload refresh');
    }
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

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted!';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }
// start record 
// start record 
  Future startRecord() async {

  startTimer();
  
  setState(() {
  _isRecording = true; // Update the animation state
    });


    // get the directory 
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    String filePath = '${directory!.path}/my_recording.aac';
    await recorder.startRecorder(toFile: filePath);

    return filePath;
  }

// sending the request afrer  the recording stops


  Future stopRecorder() async {
    stopTimer();

    setState(() {
      _isRecording = false; // Update the animation state
      wasLastActionRecording = true;
    });

   final filePath = await recorder.stopRecorder();
    final file = File(filePath!);
    if (kDebugMode) {
      print('Recorded file path: $filePath');
    }

    var  request = http.MultipartRequest('POST', Uri.parse('http://192.168.81.203:8000/keyfinder/findKey'));
    request.files.add(http.MultipartFile(
      'file',
      file.readAsBytes().asStream(),
      file.lengthSync(),
      filename: path.basename(file.path),
    ));

    // Send the request
    var response = await request.send();

    // Handle the response
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = jsonDecode(responseBody);
      if (data is Map && data.containsKey('predicted_key')) {
        setState(() {
          titleText = data['predicted_key'].toString();
        });
      } else {
        if (kDebugMode) {
          print(response);
          print('Unexpected response format');
        }
      } 
    } else {
      if (kDebugMode) {
        print('Failed to upload. : ${response.statusCode}');
      }
      String responseBody = await response.stream.bytesToString();
      if (kDebugMode) {
        print('Response body: $responseBody');
      }
    }
   
  }
  // Function to handle file selection and create upload request
  Future<void> selectAndUploadFile() async {
    wasLastActionRecording = false;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      selectedFile = result.files.first;

      setState(() {
      lastUploadedFileName = selectedFile!.name;
    });
      
      fileUploadRequest = http.MultipartRequest('POST', Uri.parse('http://192.168.81.203:8000/keyfinder/findKey'));

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
  
  if (data is Map && data.containsKey('predicted_key')) {
    setState(() {
      titleText = data['predicted_key'].toString();
    });
  } else {
    if (kDebugMode) {
      print('Unexpected response format');
    }
  }
  } 
  else {
    if (kDebugMode) {
      print('Upload failed with status: ${response.statusCode}.');
    }
  }
    } else {
      // User canceled the picker
    }
  }


  // Function to send the upload requesR
  Future<void> uploadFile() async {
    wasLastActionRecording = false;
    fileUploadRequest = http.MultipartRequest('POST', Uri.parse('http://192.168.81.203:8000/keyfinder/upload/'));

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
        if (data is Map && data.containsKey('predicted_key')) {
          setState(() {
            titleText = data['predicted_key'].toString();
          });
        } else {
          if (kDebugMode) {
            print('Unexpected response format');
          }
        }
      } else {
        if (kDebugMode) {
          print("Not Uploaded!");
        }
      }
    } else {
      if (kDebugMode) {
        print("No file selected!");
      }
    }
  }



  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // backgroundColor: Colors.grey[200],//backround color
        appBar: AppBar(
          title: const Center(
            child:  Text('Note',
             style: TextStyle(
                  color: Colors.blue,),
                     
                    ),
          ),
         backgroundColor:  const Color.fromARGB(255, 35, 5, 110),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 35, 5, 110),
          ),
          child: Column(
          children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                   
                ),
                height: 280,
                child: Stack(
                  children:<Widget>[
                    Container(
                     
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        image: DecorationImage(
                          image: AssetImage('assets/images/images.jpeg'),
                          fit: BoxFit.cover,
                        ),

                      ),
                    ),
                  Container(

                    decoration: BoxDecoration(
                     
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          
                          const Color.fromARGB(255, 35, 5, 110).withOpacity(0.9),
                        ]
                    ),
                    ),
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(45)),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 35, 5, 110),
                        Color.fromARGB(255, 35, 5, 110),
                      ],
                    ),
                     border: Border.all(
                      color: Colors.blue, // Color of the border
                      width: 1, // Width of the border
                    ),
                  ),
                  child: Column(
                    children: [
                        Container(
                          height: 100,
                          child: MusicWaveAnimation(isRecording: _isRecording),
                        ),
                        SizedBox(
                        height: 50, 
                        child: Center(
                      child: _isRecording 
                        ? Text(
                            'Recording ${formatTime(_start)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : Text.rich(
                            TextSpan(
                              children: [
                                if (lastUploadedFileName != null) 
                                  TextSpan(
                                    text: lastUploadedFileName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                else 
                                  const TextSpan(
                                    text: "Let's determine the key",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ),


                      ), // key text
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              iconSize: 60,
                              onPressed: () async {
                                if (recorder.isRecording) {
                                  await stopRecorder();
                                  setState(() {});
                                } else {
                                  await startRecord();
                                  setState(() {});
                                }
                              },
                              icon: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    recorder.isRecording ? Icons.stop : Icons.mic,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    recorder.isRecording ? 'Stop' : 'Record',
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              iconSize: 60,
                              onPressed: () {
                                onRefreshButtonPressed();
                              },
                              icon: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.refresh, size: 40, color: Colors.white),
                                  Text('Refresh', style: TextStyle(fontSize: 10, color: Colors.white)),
                                ],
                              ),
                            ),
                            IconButton(
                              iconSize: 40,
                              icon: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.music_note, color: Colors.white),
                                  Text(
                                    'Upload',
                                    style: TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ),
                              onPressed: selectAndUploadFile,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Center(
                          child: Container(
                            height: 95,
                            width: 350,
                            margin: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.purple.withOpacity(0.13)
                            ),
                            child:Center(
                              child: _isRecording
                                  ? const Text(
                                      "Wait until 20-30 seconds for more accurate result",
                                   textAlign: TextAlign.center, 
                                  style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  // fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),
                                    )
                                  : const Text(
                                  ' "Playing a wrong note is insignificant   \n but \n playing without passion is inexcusable"\ \n-Beethoven',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  // fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),
                                ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

// animarion class
class MusicWaveAnimation extends StatefulWidget {
  final bool isRecording;

  const MusicWaveAnimation({Key? key, required this.isRecording}) : super(key: key);

  @override
  _MusicWaveAnimationState createState() => _MusicWaveAnimationState();
}

class _MusicWaveAnimationState extends State<MusicWaveAnimation> {
  late Timer _timer;
  final List<double> _waveValues = [];
  final int _numberOfWaves = 50;
  final double _amplitude = 50.0;
  final double _period = 6.0;
  var _phase = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
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
        double value = widget.isRecording ? _calculateWaveValue(i) : 0.0;
        _waveValues.add(value);
      }
    });
  }

  double _calculateWaveValue(int index) {
    double waveLength = 1.5 * pi / _period;
    double scaledIndex = index * 1.5;
    double scaledPhase = _phase - scaledIndex;
    double value1 = _amplitude * sin(waveLength * scaledPhase);
    double value2 = _amplitude * sin(waveLength * scaledPhase + 3.3 * waveLength);
    double value3 = _amplitude / 3 * sin(3 * waveLength * scaledPhase);
    double value4 = _amplitude / 2 * sin(2 * waveLength * scaledPhase);
    double value = value2 + value1 + value3 + value4;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
      width: 3,
      height: value.abs() + 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
          colors: [Colors.blue, Color.fromARGB(255, 214, 127, 193), Color.fromARGB(255, 144, 126, 244)],
        ),
      ),
    );
  }
}   