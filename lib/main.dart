import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:core';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePageOverlap(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
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

    /* if( _points.length > 20 ){
      _points.removeAt( 0 );
    }*/
    //only add the point if the list is empty or we've moved far enough for it to be relevant
    return true;
  }

  void forEach(MapOffset mapper) {
    _points.forEach(mapper);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Map<int, PointerGesture> _gestures;

  void _addPoint(PointerType type, PointerEvent event) {
    //print('$type ${event.position.dx} ${event.position.dy} ${event.distance}');
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
          //_gestures.remove( event.pointer );
        }
        break;
      case PointerType.cancel:
        if (gesture != null) {
          gesture.addPoint(event.position);
          //_gestures.remove( event.pointer );
        }
        break;
    }

    this.setState(() {});
  }

  @override
  void initState() {
    _gestures = {};
    super.initState();
  }

  void _clearGestures() {
    _gestures.clear();
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      //backgroundColor: Colors.redAccent,
      body: Container(
        child: Listener(
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
                child: Text("Sample Paint"),
              ),
            )),
      ),
      floatingActionButton: IconButton(
          highlightColor: Colors.blue,
          icon: Icon(Icons.clear),
          onPressed: () {
            _clearGestures();
          }), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PointsPainter extends CustomPainter {
  Map<int, PointerGesture> gestures;

  PointsPainter(this.gestures) : super();

  @override
  void paint(Canvas canvas, Size size) {
    //create a paint - set it's properties
    Paint paint = new Paint();
    //  ..strokeJoin = StrokeJoin.round
    //   ..strokeCap = StrokeCap.square
//      ..strokeWidth = 10.0
//      ..color = Colors.red;

    gestures.forEach((int key, PointerGesture gesture) {
      Offset pntLast;

      int i = 0;
      int numPoints = gesture.points.length;

      gesture.points.forEach((pnt) {
        if (pntLast != null && pnt != null) {
          //starts thin, goes fat, back to thin
          double r = i / numPoints;
          paint.strokeWidth = 5;
          paint.color = Colors.black;
          //paint.strokeWidth = 100 * (1-r);//math.pow(1 - 2 * (0.5 - r).abs(), 0.5);
          canvas.drawLine(pntLast, pnt, paint);
        }

        i++;
        pntLast = pnt;
      });
    });
  }

  @override
  bool shouldRepaint(PointsPainter oldDelegate) {
    return true;
  }
}

//overlap

class MyHomePageOverlap extends StatefulWidget {
  MyHomePageOverlap({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageOverlapState createState() => _MyHomePageOverlapState();
}

class _MyHomePageOverlapState extends State<MyHomePageOverlap> {
  ui.Image image;
  bool isImageloaded = true;
  GlobalKey _myCanvasKey = new GlobalKey();

  void initState() {
    super.initState();
    init();
  }

  Future<Null> init() async {
    final ByteData data = await rootBundle.load('assets/google.png');
    image = await loadImage(Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    ImageEditor editor = ImageEditor(image: image);
    if (this.isImageloaded) {
      return GestureDetector(
        onPanDown: (detailData) {
          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext.findRenderObject().markNeedsPaint();
        },
        onPanUpdate: (detailData) {
          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext.findRenderObject().markNeedsPaint();
        },
        onPanEnd: (detailData){
          editor.update(null);
          _myCanvasKey.currentContext.findRenderObject().markNeedsPaint();
        },
        child: CustomPaint(
          key: _myCanvasKey,
          painter: editor,
        ),
      );
    } else {
      return Center(child: Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }
}

class ImageEditor extends CustomPainter {
  ImageEditor({
    this.image,
  });

  ui.Image image;

  List<Offset> points = List();

  final Paint painter = new Paint()
    ..color = Colors.blue[400]
    ..style = PaintingStyle.fill;

  void update(Offset offset) {
    points.add(offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());

/*
    for (Offset offset in points) {
      canvas.drawCircle(offset, 10, painter);
    }*/

    var paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
