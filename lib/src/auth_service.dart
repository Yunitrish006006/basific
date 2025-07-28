import 'package:supabase_flutter/supabase_flutter.dart';

/// Type alias for Supabase User with additional convenience methods
typedef BasificUser = User;

/// Extension to add convenience methods to User
extension BasificUserExtension on User {
  /// Get the best display name available
  String get bestDisplayName {
    // Try display_name from user_metadata first
    if (userMetadata?['display_name'] != null && 
        userMetadata!['display_name'].toString().isNotEmpty) {
      return userMetadata!['display_name'];
    }
    
    // Try full_name from user_metadata
    if (userMetadata?['full_name'] != null && 
        userMetadata!['full_name'].toString().isNotEmpty) {
      return userMetadata!['full_name'];
    }
    
    // Fall back to email
    return email ?? 'User';
  }

  /// Alias for bestDisplayName for backward compatibility
  String get name => bestDisplayName;
}

/// Result class for authentication operations
class BasificAuthResult {
  final bool success;
  final String? error;
  final BasificUser? user;

  const BasificAuthResult({
    required this.success,
    this.error,
    this.user,
  });

  /// Convenience getter for success status
  bool get isSuccess => success;

  factory BasificAuthResult.success(BasificUser user) {
    return BasificAuthResult(success: true, user: user);
  }

  factory BasificAuthResult.error(String error) {
    return BasificAuthResult(success: false, error: error);
  }
}

/// Authentication service class
class BasificAuth {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Get current authenticated user
  static BasificUser? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get auth state stream
  static Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  /// Alias for authStateStream for backward compatibility
  static Stream<AuthState> get authStateChanges => authStateStream;

  /// Login with email and password
  static Future<BasificAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return BasificAuthResult.success(response.user!);
      } else {
        return BasificAuthResult.error('Login failed');
      }
    } catch (e) {
      return BasificAuthResult.error(e.toString());
    }
  }

  /// Login with username or email
  static Future<BasificAuthResult> loginWithUsernameOrEmail({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      // If it contains @, treat as email
      if (usernameOrEmail.contains('@')) {
        return await login(email: usernameOrEmail, password: password);
      }

      // Otherwise, look up email by username
      final response = await _client
          .from('profiles')
          .select('email')
          .eq('display_name', usernameOrEmail)
          .single();

      final email = response['email'] as String?;
      if (email == null) {
        return BasificAuthResult.error('Username not found');
      }

      return await login(email: email, password: password);
    } catch (e) {
      return BasificAuthResult.error(e.toString());
    }
  }

  /// Register new user
  static Future<BasificAuthResult> register({
    required String email,
    required String password,
    String? displayName,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
          if (fullName != null) 'full_name': fullName,
        },
      );

      if (response.user != null) {
        return BasificAuthResult.success(response.user!);
      } else {
        return BasificAuthResult.error('Registration failed');
      }
    } catch (e) {
      return BasificAuthResult.error(e.toString());
    }
  }

  /// Logout user
  static Future<BasificAuthResult> logout() async {
    try {
      await _client.auth.signOut();
      return BasificAuthResult.success(currentUser!);
    } catch (e) {
      return BasificAuthResult.error(e.toString());
    }
  }

  /// Reset password
  static Future<BasificAuthResult> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return BasificAuthResult.success(currentUser!);
    } catch (e) {
      return BasificAuthResult.error(e.toString());
    }
  }

  /// Check if profiles table is properly set up
  static Future<bool> checkProfilesTableSetup() async {
    try {
      // Try to access the profiles table
      await _client.from('profiles').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
