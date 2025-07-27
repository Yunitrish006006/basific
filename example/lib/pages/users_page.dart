import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final textController = TextEditingController();

  void addNewUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter user name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                registerUser();
                Navigator.pop(context);
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  void registerUser() async {
      await Supabase.instance.client.from('account').insert({'name': textController.text});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addNewUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
