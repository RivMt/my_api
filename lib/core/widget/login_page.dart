import 'package:flutter/material.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/screen_planner.dart';
import 'package:my_api/core/widget/register_page.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';

class LoginPage extends StatefulWidget {

  static const String route = "/login";

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
      if (user.isValid) {
        Log.i(_tag, "Login successful: ${user.email}");
        close();
        return;
      }
    } on Exception catch(e) {
      Log.e(_tag, "Exception: $e");
    } on Error catch(e) {
      Log.e(_tag, "Error: $e");
    }
    setState(() {
      progressing = false;
    });
  }

  void close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
          ),
          onPressed: () => close(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: SizedBox(
          width: ScreenPlanner(context).panelWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                      ),
                    ),
                    const SizedBox(height: 8,),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8,),
              ElevatedButton(
                onPressed: () {
                  if (!progressing) {
                    setState(() {
                      progressing = true;
                    });
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
              const SizedBox(height: 8,),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, RegisterPage.route),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}