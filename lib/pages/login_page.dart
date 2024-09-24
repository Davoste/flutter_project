import 'package:flutter/material.dart';
import 'package:xoap/services/auth/auth_service.dart';
import 'package:xoap/components/my_button.dart';
import 'package:xoap/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  // email and password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // go to register
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  //login
  void login(BuildContext context) async {
    //auh service
    final authService = AuthService();
    //try login
    try {
      await authService.signInWithEmailPassword(
          _emailController.text, _passwordController.text);
    }
    //catch errors
    catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(e.toString()),
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo

          Image.asset(
            "lib/images/Xoap.png",
            height: 180,
            width: 180,
          ),

          const SizedBox(
            height: 50,
          ),
          //welcome message
          Text(
            "Welcome to your safe space",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          //email textfield
          MyTextfield(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
            focusNode: FocusNode(),
          ),
          const SizedBox(
            height: 10,
          ),
          //password
          //email textfield
          MyTextfield(
            hintText: "Password",
            obscureText: true,
            controller: _passwordController,
            focusNode: FocusNode(),
          ),
          const SizedBox(
            height: 10,
          ),
          //login button
          MyButton(
            text: "Sign In",
            onTap: () => login(context),
          ),
          const SizedBox(
            height: 10,
          ),
          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text("Register here",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
