// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const pointsNum = 100;
var velocity;
var radius;

var colors;
var image;

enum Element { blendmode, colorA, colorB }

final lightTheme = {
  Element.blendmode: BlendMode.darken,
  Element.colorA: Colors.black,
  Element.colorB: Colors.white
};

final darkTheme = {
  Element.blendmode: BlendMode.lighten,
  Element.colorA: Colors.white,
  Element.colorB: Colors.black
};

final Map<String, String> weathers = {
  'cloudy': 'H',
  'foggy': 'J',
  'rainy': 'R',
  'snowy': 'W',
  'sunny': 'B',
  'thunderstorm': 'O',
  'windy': 'F'
};

class MeltClock extends StatefulWidget {
  const MeltClock(this.model);

  final ClockModel model;

  @override
  _MeltClockState createState() => _MeltClockState();
}

class _MeltClockState extends State<MeltClock>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(MeltClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double h = size.height;
    double w = size.width;

    final fontSize = w / 1.80;
    final infoSize = w / 25.0;

    colors = Theme.of(context).brightness == Brightness.light
        ? lightTheme
        : darkTheme;

    final _formatedTemp =
        widget.model.temperature.round().toString() + widget.model.unitString;

    final _condition = widget.model.weatherString;

    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

    String deciH = hour.toString().substring(0, 1);
    String unitH = hour.toString().substring(1, 2);

    final minute = DateFormat('mm').format(_dateTime);

    String deciM = minute.toString().substring(0, 1);
    String unitM = minute.toString().substring(1, 2);

    // animation properties

    radius = w * 0.120;
    velocity = w * 0.00075;

    renderImage();

    Rect bounds = Rect.fromLTWH(-radius, -radius, w + radius, h + radius);

    List<Point> points = [];
    for (int i = 0; i < pointsNum; i++) {
      points.add(Point(
          px: -radius + Random().nextDouble() * w,
          py: -radius + Random().nextDouble() * h,
          vx: -(velocity / 2) + Random().nextDouble() * velocity,
          vy: -(velocity / 2) + Random().nextDouble() * velocity));
    }

    // animation tint

    Color colorWeather;

    if (_condition == "sunny") {
      colorWeather = Color(0x60FFBE00);
    } else if (_condition == "cloudy") {
      colorWeather = Color(0x600080FF);
    } else if (_condition == "windy") {
      colorWeather = Color(0x600040FF);
    } else if (_condition == "rainy" || _condition == "thunderstorm") {
      colorWeather = Color(0x60000000);
    } else // foggy or snowy
    {
      Color(0);
    }

    // letters clipPath polygons

    List<double> shapeDeciH = [0, 0, w * 0.275, 0, w * 0.225, h, 0, h];

    List<double> shapeUnitH = [w * 0.275, 0, w * 0.475, 0, w * 0.525, h, w * 0.225, h];

    List<double> shapeDeciM = [w * 0.475, 0, w * 0.775, 0, w * 0.725, h, w * 0.525, h];

    List<double> shapeUnitM = [w * 0.775, 0, w, 0, w, h, w * 0.725, h];

    //

    return Stack(children: <Widget>[
      Positioned(
          left: 0,
          top: 0,
          child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget widget) {
                return CustomPaint(
                    size: size, painter: MeltPainter(bounds, points));
              })),
      AnimatedContainer(
          color: colorWeather,
          duration: Duration(seconds: 1),
          curve: Curves.easeIn),
      ClipPath(
          clipper: CustomShape(shapeDeciH),
          child: Container(
              color: Color(0x10FFFFFF),
              child: Opacity(
                  opacity: 0.50,
                  child: Text(deciH,
                      style: TextStyle(
                          color: colors[Element.colorB],
                          letterSpacing: fontSize * 0.025,
                          fontFamily: 'RobotoCondensed',
                          fontSize: fontSize))))),
      ClipPath(
          clipper: CustomShape(shapeUnitH),
          child: Container(
              color: Color(0x30FFFFFF),
              child: Opacity(
                  opacity: 0.50,
                  child: Text(unitH,
                      style: TextStyle(
                          color: colors[Element.colorB],
                          letterSpacing: fontSize * 0.725,
                          fontFamily: 'RobotoCondensed',
                          fontSize: fontSize))))),
      ClipPath(
          clipper: CustomShape(shapeDeciM),
          child: Container(
              color: Color(0x20FFFFFF),
              child: Opacity(
                  opacity: 0.50,
                  child: Text(deciM,
                      style: TextStyle(
                          color: colors[Element.colorB],
                          letterSpacing: fontSize * 1.75,
                          fontFamily: 'RobotoCondensed',
                          fontSize: fontSize))))),
      ClipPath(
        clipper: CustomShape(shapeUnitM),
        child: Container(
            color: Color(0x10FFFFFF),
            child: Opacity(
                opacity: 0.50,
                child: Text(unitM,
                    style: TextStyle(
                        color: colors[Element.colorB],
                        letterSpacing: fontSize * 2.50,
                        fontFamily: 'RobotoCondensed',
                        fontSize: fontSize)))),
      ),
      Positioned(
          top: 10,
          right: 10,
          child: Opacity(
              opacity: 0.50,
              child: Row(children: <Widget>[
                Text(weathers[_condition],
                    style: TextStyle(
                        color: colors[Element.colorB],
                        fontFamily: 'Meteocons',
                        fontSize: infoSize)),
                Text(_formatedTemp,
                    style: TextStyle(
                        color: colors[Element.colorB],
                        fontFamily: 'RobotoCondensed',
                        fontSize: infoSize))
              ])))
    ]);
  }

  void renderImage() async {
    PictureRecorder pictureRecorder = PictureRecorder();

    Rect shapeRect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    Canvas shape = new Canvas(pictureRecorder, shapeRect);

    final RadialGradient gradient = RadialGradient(
        radius: 0.5,
        tileMode: TileMode.clamp,
        colors: [colors[Element.colorA], colors[Element.colorB]]);

    final Paint paint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = gradient.createShader(shapeRect);

    shape.drawCircle(Offset(radius, radius), radius, paint);

    image = await pictureRecorder
        .endRecording()
        .toImage(radius.round() * 2, radius.round() * 2);
  }
}

class MeltPainter extends CustomPainter {

  Rect bounds;
  List<Point> points;

  MeltPainter(this.bounds, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = colors[Element.colorB]
          ..style = PaintingStyle.fill);

    final Paint blendmodePaint = new Paint()
      ..blendMode = colors[Element.blendmode];

    for (int i = 0; i < pointsNum; i++) {
      canvas.drawImage(
          image, Offset(points[i].px, points[i].py), blendmodePaint);
    }

    pointsUpdate(bounds);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void pointsUpdate(Rect bounds) {
    double x = bounds.left;
    double y = bounds.top;
    double h = bounds.height;
    double w = bounds.width;

    for (int i = 0; i < pointsNum; i++) {
      Point p = points[i];

      p.px += p.vx;
      p.py += p.vy;

      if (p.px < x) {
        p.px = x;
        p.vx = -p.vx;
      }
      if (p.py < y) {
        p.py = y;
        p.vy = -p.vy;
      }
      if (p.px > x + w) {
        p.px = w + x;
        p.vx = -p.vx;
      }
      if (p.py > y + h) {
        p.py = h + y;
        p.vy = -p.vy;
      }
    }
  }
}

class Point {
  // offset
  double px;
  double py;
  // velocity
  double vx;
  double vy;

  Point({this.px = 0.0, this.py = 0.0, this.vx = 0.0, this.vy = 0.0});
}

class CustomShape extends CustomClipper<Path> {
  List<Offset> points;

  CustomShape(List<double> values) {
    points = List<Offset>();

    for (int i = 0; i < values.length; i += 2) {
      points.add(Offset(values[i], values[i + 1]));
    }
  }

  @override
  Path getClip(Size size) {
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
