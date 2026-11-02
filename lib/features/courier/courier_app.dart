import 'package:flutter/material.dart';

class CourierApp extends StatelessWidget {
  const CourierApp({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Kurir')));
}
