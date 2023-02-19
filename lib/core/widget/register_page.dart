import 'package:flutter/material.dart';
import 'package:my_api/core/api.dart';
import 'package:my_api/core/screen_planner.dart';
import 'package:my_api/core/model/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  /// Currently edited [User]
  User editing = User({});

  /// Value that now trying to login or not
  bool progressing = false;

  /// [TextEditingController] for Email field
  final email = TextEditingController();

  /// [TextEditingController] for Password field
  final password = TextEditingController();

  /// [TextEditingController] for Password check field
  final passwordCheck = TextEditingController();

  /// [TextEditingController] for first name
  final firstName = TextEditingController();

  /// [TextEditingController] for last name
  final lastName = TextEditingController();

  /// [TextEditingController] for gender
  final gender = TextEditingController();

  /// Close this page
  void close() {
    Navigator.pop(context);
  }

  /// Apply text field text to [editing]
  void apply() {
    editing.email = email.text;
    editing.firstName = firstName.text;
    editing.lastName = lastName.text;
    if (editing.gender.code == UserGender.codeOther) {
      editing.gender = UserGender(UserGender.codeOther, gender.text);
    }
  }

  /// Triggers on birthday button pressed
  void onBirthdayButtonPressed(BuildContext context) async {
  }

  /// Triggers on gender radio button changed
  void onGenderChanged(int? code) {
    editing.gender = UserGender.fromCode(code ?? -1, code == UserGender.codeOther ? gender.text : "");
    setState(() {});
  }

  /// Triggers on register button pressed
  void onRegisterButtonPressed() async {
    final password = this.password.text;
    // Get data from UI
    apply();
    // Make progressing true
    progressing = true;
    // Check password correction
    if (!User.checkPassword(password) || password != passwordCheck.text) {
      return;
    }
    // Request
    final User user = await ApiClient().register(editing, password);
    // Received
    setState(() {
      progressing = false;
    });
    // Check
    if (!user.isValid) {
      return;
    }
    close();
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenPlanner(context).panelWidth;
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
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "E-mail",
                      ),
                    ),
                    const SizedBox(height: 8,),
                    // Password
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                    const SizedBox(height: 8,),
                    // Password check
                    TextFormField(
                      controller: passwordCheck,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password Check",
                      ),
                    ),
                    const SizedBox(height: 8,),
                    // Name
                    // First name
                    TextFormField(
                      controller: firstName,
                      decoration: const InputDecoration(
                        labelText: "First name",
                      ),
                    ),
                    const SizedBox(height: 4,),
                    // Last name
                    TextFormField(
                      controller: lastName,
                      decoration: const InputDecoration(
                        labelText: "Last name",
                      ),
                    ),
                    const SizedBox(height: 8,),
                    // Gender
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              value: UserGender.codeMale,
                              groupValue: editing.gender.code,
                              onChanged: onGenderChanged,
                              title: Text(UserGender.male.name),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              value: UserGender.codeFemale,
                              groupValue: editing.gender.code,
                              onChanged: onGenderChanged,
                              title: Text(UserGender.female.name),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              value: UserGender.codeOther,
                              groupValue: editing.gender.code,
                              onChanged: onGenderChanged,
                              title: const Text("Other"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: editing.gender.code == UserGender.codeOther,
                      child: TextField(
                        controller: gender,
                        decoration: const InputDecoration(
                          labelText: "Gender",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8,),
              ElevatedButton(
                onPressed: onRegisterButtonPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: progressing,
                      child: const CircularProgressIndicator(),
                    ),
                    const Text('Register'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}