import 'package:flutter/foundation.dart';
import 'config.dart';

/// User model for Basific authentication
class BasificUser {
  final String id;
  final String account;
  final String name;
  final String level;

  const BasificUser({
    required this.id,
    required this.account,
    required this.name,
    required this.level,
  });

  factory BasificUser.fromMap(Map<String, dynamic> map) {
    final config = Basific.config;
    return BasificUser(
      id: map[config.columnNames['id']!] ?? '',
      account: map[config.columnNames['account']!] ?? '',
      name: map[config.columnNames['name']!] ?? '',
      level: map[config.columnNames['level']!] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    final config = Basific.config;
    return {
      config.columnNames['id']!: id,
      config.columnNames['account']!: account,
      config.columnNames['name']!: name,
      config.columnNames['level']!: level,
    };
  }

  @override
  String toString() {
    return 'BasificUser(id: $id, account: $account, name: $name, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BasificUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Authentication service for Basific
class BasificAuth {
  static BasificUser? _currentUser;

  /// Get current authenticated user
  static BasificUser? get currentUser => _currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;

  /// Login with account and password
  static Future<BasificAuthResult> login({
    required String account,
    required String password,
  }) async {
    try {
      final config = Basific.config;
      final response = await Basific.supabase
          .from(config.accountTableName)
          .select()
          .eq(config.columnNames['account']!, account)
          .eq(config.columnNames['password']!, password)
          .maybeSingle();

      if (response != null) {
        _currentUser = BasificUser.fromMap(response);
        return BasificAuthResult.success(_currentUser!);
      } else {
        return BasificAuthResult.failure('Invalid account or password');
      }
    } catch (error) {
      return BasificAuthResult.failure('Login failed: $error');
    }
  }

  /// Register new user
  static Future<BasificAuthResult> register({
    required String account,
    required String password,
    required String name,
    String level = 'user',
  }) async {
    try {
      final config = Basific.config;

      // Check if account already exists
      final existingUser = await Basific.supabase
          .from(config.accountTableName)
          .select()
          .eq(config.columnNames['account']!, account)
          .maybeSingle();

      if (existingUser != null) {
        return BasificAuthResult.failure('Account already exists');
      }

      // Create new user
      final newUserData = {
        config.columnNames['account']!: account,
        config.columnNames['password']!: password,
        config.columnNames['name']!: name,
        config.columnNames['level']!: level,
      };

      final response = await Basific.supabase
          .from(config.accountTableName)
          .insert(newUserData)
          .select()
          .single();

      final user = BasificUser.fromMap(response);
      return BasificAuthResult.success(user);
    } catch (error) {
      return BasificAuthResult.failure('Registration failed: $error');
    }
  }

  /// Logout current user
  static void logout() {
    _currentUser = null;
  }

  /// Update user information
  static Future<BasificAuthResult> updateUser({
    required String userId,
    String? name,
    String? level,
  }) async {
    try {
      final config = Basific.config;
      final updateData = <String, dynamic>{};

      if (name != null) updateData[config.columnNames['name']!] = name;
      if (level != null) updateData[config.columnNames['level']!] = level;

      if (updateData.isEmpty) {
        return BasificAuthResult.failure('No data to update');
      }

      final response = await Basific.supabase
          .from(config.accountTableName)
          .update(updateData)
          .eq(config.columnNames['id']!, userId)
          .select()
          .single();

      final updatedUser = BasificUser.fromMap(response);
      
      // Update current user if it's the same
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
      }

      return BasificAuthResult.success(updatedUser);
    } catch (error) {
      return BasificAuthResult.failure('Update failed: $error');
    }
  }

  /// Delete user
  static Future<BasificAuthResult> deleteUser(String userId) async {
    try {
      final config = Basific.config;
      await Basific.supabase
          .from(config.accountTableName)
          .delete()
          .eq(config.columnNames['id']!, userId);

      // Logout if deleting current user
      if (_currentUser?.id == userId) {
        logout();
      }

      return BasificAuthResult.success(null);
    } catch (error) {
      return BasificAuthResult.failure('Delete failed: $error');
    }
  }

  /// Get all users (admin function)
  static Future<List<BasificUser>> getAllUsers() async {
    try {
      final config = Basific.config;
      final response = await Basific.supabase
          .from(config.accountTableName)
          .select();

      return response.map<BasificUser>((user) => BasificUser.fromMap(user)).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Failed to fetch users: $error');
      }
      return [];
    }
  }
}

/// Result class for authentication operations
class BasificAuthResult {
  final bool isSuccess;
  final BasificUser? user;
  final String? error;

  const BasificAuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });

  factory BasificAuthResult.success(BasificUser? user) {
    return BasificAuthResult._(isSuccess: true, user: user);
  }

  factory BasificAuthResult.failure(String error) {
    return BasificAuthResult._(isSuccess: false, error: error);
  }
}
