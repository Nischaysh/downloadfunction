import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'D O W N L O A D',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[300],
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return const Tiles();
        },
        itemCount: 10,
      ),
    );
  }
}

class Tiles extends StatelessWidget {
  const Tiles({Key? key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 15),
                  child: Icon(Icons.person_2_sharp, size: 40),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 8),
                      child: Container(
                        child: const Text(
                          'File Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Container(
                        child: const Text(
                          'Subject ',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const DownloadingDialog(),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 55.0, top: 10),
                      child: Text(
                        'DOWNLOAD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DownloadingDialog extends StatefulWidget {
  const DownloadingDialog({Key? key}) : super(key: key);

  @override
  _DownloadingDialogState createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  Dio dio = Dio();
  double progress = 0.0;
  bool fileDownloaded = false;

  void startDownloading() async {
    const String url =
        'https://sample-videos.com/pdf/Sample-pdf-5mb.pdf';

    const String fileName = "Sample-pdf-5m.pdf";

    String path = await _getFilePath(fileName);
    print(path);

    if (await _isFileExists(path)) {
      setState(() {
        fileDownloaded = true;
      });
    } else {
      await dio.download(
        url,
        path,
        onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            progress = receivedBytes / totalBytes;
          });

          print(progress);
        },
        deleteOnError: true,
      ).then((_) {
        setState(() {
          fileDownloaded = true;
        });
      });
    }
  }

  Future<String> _getFilePath(String filename) async {
    final dir = await getApplicationSupportDirectory();
    return "${dir.path}/$filename";
  }

  Future<bool> _isFileExists(String filePath) async {
    File file = File(filePath);
    return await file.exists();
  }

  void openFile() async {
    const String fileName = "Sample-pdf-5m.pdf";
    String path = await _getFilePath(fileName);
    OpenFile.open(path);
  }

  @override
  void initState() {
    super.initState();
    startDownloading();
  }

  @override
  Widget build(BuildContext context) {
    String downloadingprogress = (progress * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: Colors.deepPurple[200],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fileDownloaded)
            ElevatedButton(
              onPressed: openFile,
              child: const Text(
                "Open File",
                style: TextStyle(color: Colors.black),
              ),
            ),
          if (!fileDownloaded)
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Downloading: $downloadingprogress%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
