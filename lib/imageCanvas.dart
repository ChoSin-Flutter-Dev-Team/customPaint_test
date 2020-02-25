import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:core';

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
      home: ImageCanvasPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ImageCanvasPage extends StatefulWidget {
  ImageCanvasPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ImageCanvasPageState createState() => _ImageCanvasPageState();
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

class _ImageCanvasPageState extends State<ImageCanvasPage> {
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
    return Scaffold(
      body: Container(
          child: SizedBox(
        child: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= 775.0
                  ? MediaQuery.of(context).size.height
                  : 775.0,
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage('assets/Home_clean.png'),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
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
                    ),
                  )),
            ),
          ],
        ),
      )),
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

/*      gesture.points.forEach((pnt) {
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
      });*/
    });
  }

  @override
  bool shouldRepaint(PointsPainter oldDelegate) {
    return true;
  }
}
