import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'config.dart';

/// Ready-to-use user management widget
class BasificUserManager extends StatefulWidget {
  /// Custom app bar title
  final String? title;
  
  /// Show add user button
  final bool showAddButton;
  
  /// Show edit functionality
  final bool showEditButton;
  
  /// Show delete functionality
  final bool showDeleteButton;
  
  /// Callback when user is selected
  final Function(BasificUser user)? onUserSelected;

  const BasificUserManager({
    super.key,
    this.title,
    this.showAddButton = true,
    this.showEditButton = true,
    this.showDeleteButton = true,
    this.onUserSelected,
  });

  @override
  State<BasificUserManager> createState() => _BasificUserManagerState();
}

class _BasificUserManagerState extends State<BasificUserManager> {
  List<BasificUser> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await BasificAuth.getAllUsers();
      setState(() {
        _users = users;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog(BasificUser user) async {
    final nameController = TextEditingController(text: user.name);
    String selectedLevel = user.level;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ['user', 'admin'].map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedLevel = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final updateResult = await BasificAuth.updateUser(
        userId: user.id,
        name: nameController.text.trim(),
        level: selectedLevel,
      );

      if (updateResult.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User updated successfully'),
            backgroundColor: Basific.config.theme.successColor,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updateResult.error ?? 'Update failed'),
            backgroundColor: Basific.config.theme.errorColor,
          ),
        );
      }
    }

    nameController.dispose();
  }

  Future<void> _confirmDelete(BasificUser user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete "${user.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Basific.config.theme.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      final deleteResult = await BasificAuth.deleteUser(user.id);

      if (deleteResult.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User deleted successfully'),
            backgroundColor: Basific.config.theme.successColor,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteResult.error ?? 'Delete failed'),
            backgroundColor: Basific.config.theme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Basific.config.theme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'User Management'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.level == 'admin' 
                                ? theme.errorColor 
                                : theme.primaryColor,
                            child: Icon(
                              user.level == 'admin' 
                                  ? Icons.admin_panel_settings 
                                  : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account: ${user.account}'),
                              Text('Level: ${user.level.toUpperCase()}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showEditButton)
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.primaryColor),
                                  onPressed: () => _showEditDialog(user),
                                ),
                              if (widget.showDeleteButton)
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.errorColor),
                                  onPressed: () => _confirmDelete(user),
                                ),
                            ],
                          ),
                          onTap: widget.onUserSelected != null
                              ? () => widget.onUserSelected!(user)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
