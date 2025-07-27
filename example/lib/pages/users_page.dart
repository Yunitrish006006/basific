import 'package:flutter/material.dart';
import 'package:basific/basific.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasificUserManager(
      title: '用戶管理',
    );
  }
}
