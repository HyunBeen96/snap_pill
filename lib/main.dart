import 'package:flutter/material.dart';
import 'camera_screen.dart';

void main() {
  runApp(SnapPillApp());
}

class SnapPillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Pill',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snap Pill')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
          },
          child: Text('📸 약 촬영하러 가기'),
        ),
      ),
    );
  }
}