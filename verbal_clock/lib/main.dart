import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_clock_helper/customizer.dart';
import 'flutter_clock_helper/model.dart';
import 'widgets/clock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClockCustomizer(
        (ClockModel model) => Clock(
          model: model,
        ),
      ),
    );
  }
}
