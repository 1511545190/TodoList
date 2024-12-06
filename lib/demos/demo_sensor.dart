// // Copyright 2017 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.
//
// // ignore_for_file: public_member_api_docs
// /*
// [log] 屏幕的宽度：213.33333333333334
// [log] 屏幕的高度：240.0
//  */
// import 'dart:async';
// import 'dart:developer';
//
// // import 'dart:math';
// import 'dart:math' show pi;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sensors_plus/sensors_plus.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations(
//     [
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ],
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sensors Demo',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: const Color(0x9f4376f8),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, this.title});
//
//   final String? title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   static const Duration _ignoreDuration = Duration(milliseconds: 20); // 忽略时间
//
//   UserAccelerometerEvent? _userAccelerometerEvent;
//   AccelerometerEvent? _accelerometerEvent;
//   GyroscopeEvent? _gyroscopeEvent;
//   MagnetometerEvent? _magnetometerEvent;
//   BarometerEvent? _barometerEvent;
//
//   DateTime? _userAccelerometerUpdateTime;
//   DateTime? _accelerometerUpdateTime;
//   DateTime? _gyroscopeUpdateTime;
//   DateTime? _magnetometerUpdateTime;
//   DateTime? _barometerUpdateTime;
//
//   int? _userAccelerometerLastInterval;
//   int? _accelerometerLastInterval;
//   int? _gyroscopeLastInterval;
//   int? _magnetometerLastInterval;
//   int? _barometerLastInterval;
//   final _streamSubscriptions = <StreamSubscription<dynamic>>[];
//
//   Duration sensorInterval = SensorInterval.normalInterval;
//
//   // box
//   double x = 100; // Initial x position
//   double y = 100; // Initial y position
//
//   @override
//   Widget build(BuildContext context) {
//     //获得屏幕的大小
//     // final screenSize = MediaQuery.of(context).size;
//     // screenSize.height;
//     // screenSize.width;
//     //
//     // log('屏幕的高度：${screenSize.height}');
//     // log('屏幕的宽度：${screenSize.width}');
//
//     //math 和 develop都有这个log,so,这里的log是哪个呢？需要使用dart:developer
//     // log('俯仰角：${_gyroscopeEvent?.x.toStringAsFixed(3) ?? '?'} rad/s');
//     // log('偏航角：${_gyroscopeEvent?.y.toStringAsFixed(1) ?? '?'} rad/s');
//     // log('滚动角：${_gyroscopeEvent?.z.toStringAsFixed(1) ?? '?'} rad/s');
//     log(x.toString() + "," + y.toString());
//     //------------->x
//     //|
//     //|
//     //|
//     //\/y
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title!),
//       ),
//       body: GestureDetector(
//         //实现拖动Box
//         onPanUpdate: (details) {
//           setState(() {
//             x += details.delta.dx;
//             y += details.delta.dy;
//           });
//         },
//         child: Stack(
//           children: [
//             Positioned(
//               left: x,
//               top: y,
//               child: Container(
//                 width: 50, // Increased size for visibility
//                 height: 50,
//                 color: Colors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     for (final subscription in _streamSubscriptions) {
//       subscription.cancel();
//     }
//   }
//
//   void moveBox(double Sensorx, double Sensory) {
//     // Scale the sensor values to control the speed of the box movement.
//     const sensitivity = 0.8;
//
//     x += Sensorx * sensitivity;
//     y += Sensory * sensitivity;
//
//     // Ensure the box stays within the bounds of the container. 确保 box 保持在容器的边界内。
//     x = x.clamp(
//         0.0, MediaQuery.of(context).size.width - 50); // Adjust for box size
//     y = y.clamp(
//         0.0, MediaQuery.of(context).size.height - 50); // Adjust for box size
//
//     // setState(() {}); // Trigger a rebuild to update the UI with the new position
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _streamSubscriptions.add(
//       gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
//         (GyroscopeEvent event) {
//           final now = event.timestamp;
//           setState(() {
//             // Calculate the difference from the last event to get the change in angle
//             final dx = (event.x - (_gyroscopeEvent?.x ?? event.x)) *
//                 180 /
//                 pi; // Convert radians to degrees
//             final dy = (event.y - (_gyroscopeEvent?.y ?? event.y)) *
//                 180 /
//                 pi; // Convert radians to degrees
//
//             // moveBox(dx, dy);
//
//             _gyroscopeEvent = event;
//             if (_gyroscopeUpdateTime != null) {
//               final interval = now.difference(_gyroscopeUpdateTime!);
//               if (interval > _ignoreDuration) {
//                 _gyroscopeLastInterval = interval.inMilliseconds;
//               }
//             }
//           });
//           _gyroscopeUpdateTime = now;
//         },
//         onError: (e) {
//           showDialog(
//             context: context,
//             builder: (context) {
//               return const AlertDialog(
//                 title: Text("Sensor Not Found"),
//                 content: Text(
//                     "It seems that your device doesn't support Gyroscope Sensor"),
//               );
//             },
//           );
//         },
//         cancelOnError: true,
//       ),
//     );
//   }
// }
