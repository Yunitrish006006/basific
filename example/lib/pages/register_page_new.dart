import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasificRegisterPage(
      title: 'Basific 註冊',
      onRegisterSuccess: (user) {
        // 註冊成功後，返回登入頁面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
    );
  }
}
