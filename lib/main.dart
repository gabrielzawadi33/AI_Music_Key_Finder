import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.grey,
        appBarTheme: const AppBarTheme(
          color: Colors.grey,
        ),
      ),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height - 14 - 314,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {
                                  // Add your menu button functionality here
                                },
                              ),
                              const Text(
                                'Menu',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.person),
                                onPressed: () {
                                  // Add your profile button functionality here
                                },
                              ),
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 166,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Container(
                      height: 228, // Decreased height to 228
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            height: 100,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            color: Colors.green,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Updated mainAxisAlignment to spaceBetween
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        border: Border.all(color: const Color.fromARGB(255, 117, 93, 93)),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.mic),
                                        iconSize: 48, // Increased icon size to 48
                                        onPressed: () {
                                          // Add your profile button functionality here
                                        },
                                      ),
                                    ),
                                    const Text(
                                      'Microphone',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                //refresh button
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.refresh),
                                        iconSize: 48, // Increased icon size to 48
                                        onPressed: () {
                                          // Add your refresh button functionality here
                                        },
                                      ),
                                    ),
                                    const Text(
                                      'Refresh',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(0),
                                        border: Border.all(color: Colors.black),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.music_note),
                                        iconSize: 48, // Increased icon size to 48
                                        onPressed: () async {
                                          final result = await FilePicker.platform.pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['mp3'],
                                          );
                                          if (result != null) {
                                            final filePath = result.files.single.path;
                                            // Use the filePath to access the selected MP3 file
                                          }
                                        },
                                      ),
                                    ),
                                    const Text(
                                      'MP3',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
