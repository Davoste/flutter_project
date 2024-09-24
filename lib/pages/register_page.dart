import 'package:flutter/material.dart';
import 'package:xoap/services/auth/auth_service.dart';
import 'package:xoap/components/my_button.dart';
import 'package:xoap/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  //register function
  void Register(BuildContext context) {
    //get auth services
    final auth = AuthService();
    //password match ..create user
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        auth.signUpWithEmailPassword(
            _emailController.text, _passwordController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(e.toString()),
                ));
      }
    } //password dont  match

    else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Passwords do not match"),
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
            "Welcome youre in the right place",
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

          MyTextfield(
            hintText: "Password",
            obscureText: true,
            controller: _passwordController,
            focusNode: FocusNode(),
          ),
          const SizedBox(
            height: 10,
          ),
          //confirm password
          MyTextfield(
            hintText: "Confirm Password",
            obscureText: true,
            controller: _confirmPasswordController,
            focusNode: FocusNode(),
          ),
          const SizedBox(
            height: 10,
          ),
          //login button
          MyButton(
            text: "Register",
            onTap: () => Register(context),
          ),
          const SizedBox(
            height: 10,
          ),
          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Alresdy have an account? ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text("Login here",
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
