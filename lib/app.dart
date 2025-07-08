import 'package:flutter/material.dart';

class WaddiApp extends StatelessWidget {
  const WaddiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WADDI Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // TODO: Replace with actual route generator or go_router
      home: const Scaffold(
        body: Center(child: Text('WADDI Platform Home')),
      ),
    );
  }
} 