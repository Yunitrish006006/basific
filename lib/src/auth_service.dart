import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

/// User model for Basific authentication
class BasificUser {
  final String id;
  final String email;
  final String? displayName;
  final String? name;
  final String? avatarUrl;
  final String? phone;
  final DateTime? emailConfirmedAt;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const BasificUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
    this.name,
    this.avatarUrl,
    this.phone,
    this.emailConfirmedAt,
    this.lastSignInAt,
    this.metadata,
  });

  factory BasificUser.fromSupabaseUser(User user) {
    return BasificUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.parse(user.createdAt),
      displayName: user.userMetadata?['display_name'] ?? user.userMetadata?['name'],
      name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
      avatarUrl: user.userMetadata?['avatar_url'],
      phone: user.phone,
      emailConfirmedAt: user.emailConfirmedAt != null ? DateTime.parse(user.emailConfirmedAt!) : null,
      lastSignInAt: user.lastSignInAt != null ? DateTime.parse(user.lastSignInAt!) : null,
      metadata: user.userMetadata,
    );
  }

  /// Get the best available display name for the user
  String get bestDisplayName {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (name != null && name!.isNotEmpty) return name!;
    return email.split('@').first; // Fallback to email prefix
  }

  @override
  String toString() {
    return 'BasificUser(id: $id, email: $email, displayName: $displayName, name: $name)';
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

  /// Helper method to check if input is an email
  static bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(input.trim());
  }

  /// Login with username or email and password
  static Future<BasificAuthResult> loginWithUsernameOrEmail({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final input = usernameOrEmail.trim();
      print('Login attempt with input: "$input"');
      
      // If input looks like an email, use it directly
      if (_isEmail(input)) {
        print('Input detected as email, logging in directly');
        return await login(email: input, password: password);
      }
      
      print('Input detected as username, looking up email');
      // Otherwise, treat it as username and look up the email
      final emailFromUsername = await _getEmailFromUsername(input);
      if (emailFromUsername == null) {
        print('Failed to find email for username: $input');
        return BasificAuthResult.failure('Display name login not available. Please create a profiles table or use email to login. See PROFILES_SETUP.md for instructions.');
      }
      
      print('Found email "$emailFromUsername" for username "$input", proceeding with login');
      return await login(email: emailFromUsername, password: password);
    } catch (error) {
      print('Login with username/email failed: $error');
      return BasificAuthResult.failure('Login failed: $error');
    }
  }

  /// Helper method to get email from display name
  /// Since we can't directly query auth.users due to RLS, we'll try a different approach
  static Future<String?> _getEmailFromUsername(String displayName) async {
    try {
      print('Searching for display_name: $displayName');
      
      // For now, we'll try to use a profiles table if it exists
      // This is a common pattern in Supabase apps
      try {
        final response = await Basific.supabase
            .from('profiles')
            .select('email, display_name')
            .eq('display_name', displayName)
            .maybeSingle();

        print('Query response: $response');

        if (response != null) {
          final email = response['email'] as String?;
          print('Found email for display_name "$displayName": $email');
          return email;
        } else {
          print('No user found with display_name: $displayName');
          return null;
        }
      } catch (e) {
        print('Profiles table query error: $e');
      }

      // If profiles table doesn't exist, we can't easily lookup by display_name
      // due to Supabase Auth security restrictions
      print('Cannot lookup user by display_name. Consider creating a profiles table.');
      return null;
    } catch (error) {
      print('Error getting email from display name: $error');
      return null;
    }
  }

  /// Login with email and password using Supabase Auth
  static Future<BasificAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login with email: $email');
      
      final response = await Basific.supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('Login response received');
      print('User: ${response.user?.email}');
      print('Session: ${response.session?.accessToken != null ? "Valid" : "Invalid"}');

      if (response.user != null) {
        _currentUser = BasificUser.fromSupabaseUser(response.user!);
        print('Login successful for: ${_currentUser!.email}');
        return BasificAuthResult.success(_currentUser!);
      } else {
        print('Login failed: No user in response');
        return BasificAuthResult.failure('Login failed');
      }
    } catch (error) {
      print('Login error: $error');
      return BasificAuthResult.failure('Login failed: $error');
    }
  }

  /// Register new user with email and password using Supabase Auth
  static Future<BasificAuthResult> register({
    required String email,
    required String password,
    String? displayName,
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    try {
      final authMetadata = <String, dynamic>{};
      if (displayName != null) authMetadata['display_name'] = displayName;
      if (fullName != null) authMetadata['full_name'] = fullName;
      if (displayName != null) authMetadata['name'] = displayName; // Fallback compatibility
      if (avatarUrl != null) authMetadata['avatar_url'] = avatarUrl;
      if (additionalMetadata != null) authMetadata.addAll(additionalMetadata);

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
