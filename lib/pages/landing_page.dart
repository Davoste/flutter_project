import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xoap/components/my_drawer.dart';
import 'package:xoap/pages/nyumbani.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            "lib/images/Xoap.png",
            height: 80,
            width: 80,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      // Pass the user to HomeScreen
      body: user != null
          ? HomeScreen(user: user)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
