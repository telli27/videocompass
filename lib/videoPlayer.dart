import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ftoast/ftoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  final File url;
  const VideoApp({Key? key, required this.url}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController controller;
  bool downloading = false;
  var progressString = "";
  int count = 0;
  void _recordVideo() async {
    if (widget.url != null) {
      setState(() {
        progressString = 'saving in progress...';
        downloading = false;
      });
     if(count==0){
       GallerySaver.saveVideo(widget.url.path).then((value) {
          setState(() {
            progressString = 'video saved!';
            downloading = true;
            count++;
          });
        });
     }else{
       FToast.toast(context, msg: "This video has already been downloaded");
        
     }
    }
  }

  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
    print("url******************** ${widget.url.path} ");
  }

  loadVideoPlayer() {
    controller = VideoPlayerController.file(widget.url);
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Player"),
        backgroundColor: Colors.teal.shade900,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.teal.shade900)),
            child: const Icon(
              Icons.downloading_outlined,
              size: 35,
            ),
            onPressed: () async {
              setState(() {
                _recordVideo();
              });
            },
          ),
        ],
      ),
      body: Container(
          child: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 3 / 3,
                child: ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: VideoPlayer(controller)),
                ),
              ),
            ),
            Container(
              //duration of video
              child: Text(
                  "Total Duration: " + controller.value.duration.toString()),
            ),
            Container(
                child: VideoProgressIndicator(controller,
                    padding: EdgeInsets.all(10),
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      backgroundColor: Colors.redAccent,
                      playedColor: Colors.green,
                      bufferedColor: Colors.purple,
                    ))),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }

                        setState(() {});
                      },
                      icon: Icon(
                        controller.value.isPlaying
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_outlined,
                        size: 50,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            downloading == false
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 120.0,
                      width: 200.0,
                      child: Card(
                        color: Colors.teal.shade900,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            downloading == false
                                ? CircularProgressIndicator()
                                : Container(),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              "$progressString",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
          ]),
        ),
      )),
    );
  }
}
