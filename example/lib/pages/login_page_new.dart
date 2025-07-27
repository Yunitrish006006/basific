import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasificLoginPage(
      title: 'Basific Calculator Demo',
      onLoginSuccess: (user) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(
              title: 'Basific Calculator Demo',
              currentUser: user,
            ),
          ),
        );
      },
    );
  }
}
