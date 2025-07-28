import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Configuration class for Basific authentication
class BasificConfig {
  /// Supabase URL
  final String supabaseUrl;
  
  /// Supabase Anonymous Key
  final String supabaseAnonKey;
  
  /// Table name for user accounts (default: 'account')
  final String accountTableName;
  
  /// Column names mapping for user table
  final Map<String, String> columnNames;
  
  /// Theme configuration
  final BasificTheme theme;

  const BasificConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.accountTableName = 'account',
    this.columnNames = const {
      'id': 'id',
      'account': 'account',
      'email': 'email',
      'password': 'password',
      'name': 'name',
      'level': 'level',
    },
    this.theme = const BasificTheme(),
  });
}

/// Theme configuration for Basific components
class BasificTheme {
  /// Primary color for buttons and accents
  final Color primaryColor;
  
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Error color
  final Color errorColor;
  
  /// Success color
  final Color successColor;
  
  /// Border radius for components
  final double borderRadius;

  const BasificTheme({
    this.primaryColor = const Color(0xFF673AB7), // Deep Purple
    this.backgroundColor = const Color(0xFFFFFFFF), // White
    this.textColor = const Color(0xFF000000), // Black
    this.errorColor = const Color(0xFFE53E3E), // Red
    this.successColor = const Color(0xFF38A169), // Green
    this.borderRadius = 8.0,
  });
}

/// Singleton class to manage Basific configuration
class Basific {
  static BasificConfig? _config;
  static bool _initialized = false;

  /// Initialize Basific with configuration
  static Future<void> initialize(BasificConfig config) async {
    _config = config;
    
    // Initialize Supabase
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
    
    _initialized = true;
  }

  /// Get current configuration
  static BasificConfig get config {
    if (!_initialized || _config == null) {
      throw Exception('Basific not initialized. Call Basific.initialize() first.');
    }
    return _config!;
  }

  /// Check if Basific is initialized
  static bool get isInitialized => _initialized;

  /// Get Supabase client
  static SupabaseClient get supabase {
    if (!_initialized) {
      throw Exception('Basific not initialized. Call Basific.initialize() first.');
    }
    return Supabase.instance.client;
  }

  /// Quick access to current authenticated user
  static BasificUser? get currentUser => BasificAuth.currentUser;

  /// Quick access to authentication status
  static bool get isAuthenticated => BasificAuth.isAuthenticated;

  /// Quick login method
  static Future<BasificAuthResult> login(String email, String password) {
    return BasificAuth.login(email: email, password: password);
  }

  /// Quick login method with username or email
  static Future<BasificAuthResult> loginWithUsernameOrEmail(String usernameOrEmail, String password) {
    return BasificAuth.loginWithUsernameOrEmail(usernameOrEmail: usernameOrEmail, password: password);
  }

  /// Quick register method
  static Future<BasificAuthResult> register({
    required String email,
    required String password,
    String? displayName,
    String? fullName,
  }) {
    return BasificAuth.register(
      email: email,
      password: password,
      displayName: displayName,
      fullName: fullName,
    );
  }

  /// Quick logout method
  static Future<BasificAuthResult> logout() {
    return BasificAuth.logout();
  }

  /// Quick password reset method
  static Future<BasificAuthResult> resetPassword(String email) {
    return BasificAuth.resetPassword(email: email);
  }
}
