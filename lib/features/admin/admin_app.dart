import 'package:flutter/material.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key, required this.onExit});
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Admin')));
}
