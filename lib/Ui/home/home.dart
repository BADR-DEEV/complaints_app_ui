import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Text(
          'your token and email are ${SharedPrefs().token} and ${SharedPrefs().userEmail}',
        ),
      ),
    );
  }
}
