import 'dart:io';
import 'package:ftoast/ftoast.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:dio/dio.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path_provider/path_provider.dart';

import '../videoPlayer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _desFile;
  String? _displayedFile;
  late int _duration;
  String? _failureMessage;
  String? _filePath;
  bool _isVideoCompressed = false;
  late File url;
  final LightCompressor _lightCompressor = LightCompressor();
  ImageSource imageType = ImageSource.gallery;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: const Text('Compressor Video'),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.teal.shade900)),
            child: const Icon(
              Icons.cancel,
              size: 35,
            ),
            onPressed: () async {
            FToast.toast(context, msg: "compressor turned off");
              LightCompressor.cancelCompression();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.teal.shade600)),
            child: Icon(Icons.select_all_outlined),
            onPressed: () {
              myShowDialog();
            },
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            _filePath == null
                ? Center(
                    child: Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 244, 242, 241),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          "You have not selected a video yet",
                          style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                        ),
                      ),
                    ),
                  )
                : Container(),



            if (_filePath != null)
              Text(
                'Original size: ${_getVideoSize(file: File(_filePath!))}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            if (_isVideoCompressed)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Size after compression: ${_getVideoSize(file: File(_desFile))}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Duration: $_duration seconds',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Visibility(
              visible: !_isVideoCompressed,
              child: StreamBuilder<double>(
                stream: _lightCompressor.onProgressUpdated,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.data != null && snapshot.data > 0) {
                    return Column(
                      children: <Widget>[
                        LinearProgressIndicator(
                          minHeight: 8,
                          value: snapshot.data / 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.data.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 20),
                        )
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: 24),
            if (_isVideoCompressed !=false)
              Builder(
                builder: (BuildContext context) => Container(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoApp(url: url)));
                      },
                      child: const Text('Play and download Video')),
                ),
              ),
            Text(
              _failureMessage ?? '',
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FloatingActionButton.extended(
          onPressed: () => _pickVideo(),
          label: const Text('Select Video'),
          icon: const Icon(Icons.video_library),
          backgroundColor: const Color(0xFFA52A2A),
        ),
      ),
    );
  }

  myShowDialog() async {
    return await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Container(
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 231, 228, 228),
            title: Text(
              "Select Compresson path Type",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: (() {
                        setState(() {
                          imageType = ImageSource.gallery;
                        });
                        Navigator.pop(context);
                      }),
                      title: Text(
                        "Galerry",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      onTap: (() {
                        setState(() {
                          imageType = ImageSource.camera;
                        });

                        Navigator.pop(context);
                      }),
                      title: Text(
                        "Camera",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<PickedFile?> diaog() async {
    final PickedFile? result =
        await ImagePicker.platform.pickVideo(source: imageType);

    return result;
  }



  // Pick a video form device's storage
  Future<void> _pickVideo() async {
    _isVideoCompressed = false;

    final PickedFile? result = await diaog();

    final PickedFile? file = result!;

    if (file == null) {
      return;
    }

    _filePath = file.path;

    setState(() {

      _failureMessage = null;
    });

    _desFile = await _destinationFile;
    final Stopwatch stopwatch = Stopwatch()..start();
    final dynamic response = await _lightCompressor.compressVideo(
        path: _filePath!,
        destinationPath: _desFile,
        videoQuality: VideoQuality.medium,
        isMinBitrateCheckEnabled: false,
        iosSaveInGallery: false);

    stopwatch.stop();
    final Duration duration =
        Duration(milliseconds: stopwatch.elapsedMilliseconds);
    _duration = duration.inSeconds;

    if (response is OnSuccess) {
      _desFile = response.destinationPath;

      setState(() {
        _displayedFile = _desFile;
        _isVideoCompressed = true;
        url = File(_desFile);
      });
    } else if (response is OnFailure) {
      setState(() {
        _failureMessage = response.message;
      });
    } else if (response is OnCancelled) {
      print(response.isCancelled);
    }
  }
}

Future<String> get _destinationFile async {
  String directory;
  final String videoName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
  if (Platform.isAndroid) {
    // Handle this part the way you want to save it in any directory you wish.
    final List<Directory>? dir = await path.getExternalStorageDirectories(
        type: path.StorageDirectory.movies);
    directory = dir!.first.path;
    return File('$directory/$videoName').path;
  } else {
    final Directory dir = await path.getLibraryDirectory();
    directory = dir.path;
    return File('$directory/$videoName').path;
  }
}

String _getVideoSize({required File file}) => filesize(file.lengthSync(), 2);
