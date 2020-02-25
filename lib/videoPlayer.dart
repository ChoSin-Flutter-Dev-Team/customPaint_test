import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

enum PointerType { down, move, up, cancel }

typedef MapOffset = void Function(Offset offset);

class PointerGesture {
  int id;
  List<Offset> _points;

  PointerGesture(this.id) {
    _points = new List<Offset>();
  }

  List<Offset> get points => _points;

  bool addPoint(Offset point) {
    if (_points.length == 0) {
      _points.add(point);
    } else if ((_points.last - point).distanceSquared > 1000.0) {
      _points.add(point);
    }
    return true;
  }

  void forEach(MapOffset mapper) {
    _points.forEach(mapper);
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  File videoFile;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    _gestures = {};
    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  Map<int, PointerGesture> _gestures;

  void _addPoint(PointerType type, PointerEvent event) {
    print('$type ${event.position.dx} ${event.position.dy} ${event.distance}');
    PointerGesture gesture = _gestures[event.pointer];

    switch (type) {
      case PointerType.down:
        gesture = new PointerGesture(event.pointer);
        gesture.addPoint(event.position);
        _gestures[event.pointer] = gesture;
        break;
      case PointerType.move:
        if (gesture != null) {
          gesture.addPoint(event.position);
        }
        break;
      case PointerType.up:
        if (gesture != null) {
          gesture.addPoint(event.position);
          // _gestures.remove( event.pointer );
        }
        break;
      case PointerType.cancel:
        if (gesture != null) {
          gesture.addPoint(event.position);
          // _gestures.remove( event.pointer );
        }
        break;
    }

    this.setState(() {});
  }

  void _clearGestures() {
    _gestures.clear();
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cutsom paint'),
        ),
        // Use a FutureBuilder to display a loading spinner while waiting for the
        // VideoPlayerController to finish initializing.
        body: Container(
            child: SizedBox(
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height >= 775.0
                    ? MediaQuery.of(context).size.height
                    : 775.0,
                child: Visibility(
                  visible: _controller != null,
                  child: FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the VideoPlayerController has finished initialization, use
                        // the data it provides to limit the aspect ratio of the video.
                        return AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          // Use the VideoPlayer widget to display the video.
                          child: VideoPlayer(_controller),
                        );
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.bottomCenter,
                child: _controller == null
                    ? null:Listener(
                    onPointerDown: (pointer) {
                      this._addPoint(PointerType.down, pointer);
                    },
                    onPointerMove: (pointer) {
                      this._addPoint(PointerType.move, pointer);
                    },
                    onPointerUp: (pointer) {
                      this._addPoint(PointerType.up, pointer);
                    },
                    onPointerCancel: (pointer) {
                      this._addPoint(PointerType.cancel, pointer);
                    },
                    child: CustomPaint(
                      painter: PointsPainter(_gestures),
                      child: new Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                      ),
                    )),
              ),
            ],
          ),
        )),
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: _controller == null
                  ? null
                  : FloatingActionButton(
                      onPressed: () {
                        // Wrap the play or pause in a call to `setState`. This ensures the
                        // correct icon is shown.
                        setState(() {
                          // If the video is playing, pause it.
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            // If the video is paused, play it.
                            _controller.play();
                          }
                        });
                      },
                      // Display the correct icon depending on the state of the player.
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _controller == null
                  ? null
                  : FloatingActionButton(
                      child: IconButton(
                          highlightColor: Colors.blue,
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _clearGestures();
                          }),
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                child: IconButton(
                    highlightColor: Colors.blue,
                    icon: Icon(Icons.video_call),
                    onPressed: () {
                      getVideo();
                    }),
              ),
            ),
          ],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Future getVideo() async {
    Future<File> _videoFile =
        ImagePicker.pickVideo(source: ImageSource.gallery);
    _videoFile.then((file) async {
      setState(() {
        videoFile = file;
        _controller = VideoPlayerController.file(videoFile);

        // Initialize the controller and store the Future for later use.
        _initializeVideoPlayerFuture = _controller.initialize();

        // Use the controller to loop the video.
        _controller.setLooping(true);
      });
    });
  }
}

class PointsPainter extends CustomPainter {
  Map<int, PointerGesture> gestures;

  PointsPainter(this.gestures) : super();

  @override
  void paint(Canvas canvas, Size size) {
    //create a paint - set it's properties
    Paint paint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5.0
      ..strokeJoin = StrokeJoin.miter;

    gestures.forEach((int key, PointerGesture gesture) {
      Offset pntLast;

      int i = 0;
      int numPoints = gesture.points.length;

      for (int i = 0; i < numPoints - 1; i++) {
        if (gesture.points[i] != null && gesture.points[i + 1] != null) {
          canvas.drawLine(gesture.points[i], gesture.points[i + 1], paint);
        }
      }
    });
  }

  @override
  bool shouldRepaint(PointsPainter oldDelegate) {
    return true;
  }
}
