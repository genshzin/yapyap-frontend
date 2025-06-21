import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 100), 
            SizedBox(height: 20),
            Text('Welcome to YapYap!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Chat feature coming soon...'),
          ],
        ),
      ),
    );
  }
}