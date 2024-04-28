// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: VoiceRecorder(),
//     );
//   }
// }

// class VoiceRecorder extends StatefulWidget {
//   @override
//   _VoiceRecorderState createState() => _VoiceRecorderState();
// }

// class _VoiceRecorderState extends State<VoiceRecorder> {
//   late FlutterSoundRecorder _recorder;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _recorder = FlutterSoundRecorder();
//     _init();
//   }

// Future<void> _init() async {
//   var status = await Permission.microphone.request();
//   if (status != PermissionStatus.granted) {
//     throw RecordingPermissionException('Microphone permission not granted');
//   }
//   await _recorder.openRecorder();
// }
//   Future<void> _startRecording() async {
//     try {
//       await _recorder.startRecorder(toFile: 'voice_record.aac');
//       setState(() {
//         _isRecording = true;
//       });
//     } catch (e) {
//       print('There was an error starting the recording: $e');
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       await _recorder.stopRecorder();
//       setState(() {
//         _isRecording = false;
//       });
//     } catch (e) {
//       print('There was an error stopping the recording: $e');
//     }
//   }
//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sound Recorder'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(_isRecording ? 'Recording...' : 'Press to record'),
//             ElevatedButton(
//               onPressed: _isRecording ? _stopRecording : _startRecording,
//               child: Icon(_isRecording ? Icons.stop : Icons.mic),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecordingPermissionException implements Exception {
//   final String message;

//   RecordingPermissionException(this.message);
// }
