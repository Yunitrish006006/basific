import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final textController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    try {
      final response = await Supabase.instance.client
          .from('account')
          .select();
      
      setState(() {
        users = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Failed to fetch users: $error');
    }
  }

  void updateUser(String id, String currentName) {
    textController.text = currentName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter new user name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(id);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateUser(String id) async {
    try {
      await Supabase.instance.client
          .from('account')
          .update({'name': textController.text})
          .eq('id', id);
      
      textController.clear();
      
      // 重新載入資料
      fetchUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
      }
    } catch (error) {
      print('Update failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update error: $error')),
        );
      }
    }
  }

  void deleteUser(String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String id) async {
    try {
      await Supabase.instance.client
          .from('account')
          .delete()
          .eq('id', id);
      
      // 重新載入資料
      fetchUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
      }
    } catch (error) {
      print('Delete failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete error: $error')),
        );
      }
    }
  }

  void addNewUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Enter user name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text('Cancel'),
            ),
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
    try {
      await Supabase.instance.client
          .from('account')
          .insert({'name': textController.text});
      
      textController.clear();
      
      // 重新載入資料
      fetchUsers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );
      }
    } catch (error) {
      print('Insert failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: users.isEmpty 
        ? const Center(child: Text('No users found'))
        : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user['level'] == 'admin' ? Colors.red : Colors.blue,
                    child: Icon(
                      user['level'] == 'admin' ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user['name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('帳號: ${user['account'] ?? 'N/A'}'),
                      Text('權限: ${user['level'] ?? 'user'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          updateUser(user['id'], user['name'] ?? '');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteUser(user['id'], user['name'] ?? 'Unknown');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
