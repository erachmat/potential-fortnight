import 'package:flutter/material.dart';

class NitipApp extends StatelessWidget {
  const NitipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nitip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'PlusJakartaSans'),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Nitip',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
