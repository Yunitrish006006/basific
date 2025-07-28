import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

/// User model for Basific authentication
class BasificUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final Map<String, dynamic>? metadata;

  const BasificUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.metadata,
  });

  factory BasificUser.fromSupabaseUser(User user) {
    return BasificUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
      metadata: user.userMetadata,
    );
  }

  @override
  String toString() {
    return 'BasificUser(id: $id, email: $email, name: $name)';
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
  static BasificUser? get currentUser {
    if (_currentUser == null) {
      final supabaseUser = Basific.supabase.auth.currentUser;
      if (supabaseUser != null) {
        _currentUser = BasificUser.fromSupabaseUser(supabaseUser);
      }
    }
    return _currentUser;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Login with email and password using Supabase Auth
  static Future<BasificAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Basific.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(response.user!);
        return BasificAuthResult.success(_currentUser!);
      } else {
        return BasificAuthResult.failure('Login failed');
      }
    } catch (error) {
      return BasificAuthResult.failure('Login failed: $error');
    }
  }

  /// Register new user with email and password using Supabase Auth
  static Future<BasificAuthResult> register({
    required String email,
    required String password,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final authMetadata = <String, dynamic>{};
      if (name != null) authMetadata['name'] = name;
      if (metadata != null) authMetadata.addAll(metadata);

      final response = await Basific.supabase.auth.signUp(
        email: email,
        password: password,
        data: authMetadata.isNotEmpty ? authMetadata : null,
      );

      if (response.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(response.user!);
        return BasificAuthResult.success(_currentUser!);
      } else {
        return BasificAuthResult.failure('Registration failed');
      }
    } catch (error) {
      return BasificAuthResult.failure('Registration failed: $error');
    }
  }

  /// Logout current user using Supabase Auth
  static Future<BasificAuthResult> logout() async {
    try {
      await Basific.supabase.auth.signOut();
      _currentUser = null;
      return BasificAuthResult.success(null);
    } catch (error) {
      return BasificAuthResult.failure('Logout failed: $error');
    }
  }

  /// Update user information
  static Future<BasificAuthResult> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updateAttributes = UserAttributes();
      
      if (email != null) updateAttributes.email = email;
      if (password != null) updateAttributes.password = password;
      if (metadata != null) updateAttributes.data = metadata;

      final response = await Basific.supabase.auth.updateUser(updateAttributes);

      if (response.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(response.user!);
        return BasificAuthResult.success(_currentUser!);
      } else {
        return BasificAuthResult.failure('Update failed');
      }
    } catch (error) {
      return BasificAuthResult.failure('Update failed: $error');
    }
  }

  /// Reset password
  static Future<BasificAuthResult> resetPassword({
    required String email,
  }) async {
    try {
      await Basific.supabase.auth.resetPasswordForEmail(email);
      return BasificAuthResult.success(null);
    } catch (error) {
      return BasificAuthResult.failure('Reset password failed: $error');
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return Basific.supabase.auth.onAuthStateChange.map((data) {
      if (data.session?.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(data.session!.user);
      } else {
        _currentUser = null;
      }
      return data;
    });
  }

  /// Check if the current session is valid
  static bool get hasValidSession {
    final session = Basific.supabase.auth.currentSession;
    return session != null && !session.isExpired;
  }

  /// Refresh the current session
  static Future<BasificAuthResult> refreshSession() async {
    try {
      final response = await Basific.supabase.auth.refreshSession();
      if (response.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(response.user!);
        return BasificAuthResult.success(_currentUser!);
      } else {
        return BasificAuthResult.failure('Session refresh failed');
      }
    } catch (error) {
      return BasificAuthResult.failure('Session refresh failed: $error');
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
