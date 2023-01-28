import 'package:flutter/material.dart';
import 'package:my_api/my_api.dart';
import 'package:my_api/src/model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  static const String _tag = "LoginPage";

  /// Value that now trying to login or not
  bool progressing = false;

  /// [TextEditingController] for Email field
  final email = TextEditingController();

  /// [TextEditingController] for Password field
  final password = TextEditingController();

  /// Try login
  void login() async {
    final client = ApiClient();
    try {
      final User user = await client.login(email.text, password.text);
      if (user.valid) {
        Log.i(_tag, "Login successful: ${user.email}");
        close();
        return;
      }
    } on Exception catch(e) {
      Log.e(_tag, "Exception: $e");
    } on Error catch(e) {
      Log.e(_tag, "Error: $e");
    }
    progressing = false;
  }

  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "E-mail"
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Password"
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ElevatedButton(
              onPressed: () {
                if (!progressing) {
                  progressing = true;
                  login();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: progressing,
                    child: const CircularProgressIndicator(),
                  ),
                  const Text('OK'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}