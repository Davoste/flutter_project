import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xoap/pages/landing_page.dart';
import 'package:xoap/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        //user loged in
        if (snapshot.hasData) {
          return const LandingPage();
        }

        //user not logged in
        else {
          return const LoginorRegister();
        }
      },
    ));
  }
}
