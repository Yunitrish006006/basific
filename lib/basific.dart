library;

// Core configuration and initialization
export 'src/config.dart';

// Authentication service and models
export 'src/auth_service.dart';

// Ready-to-use UI components
export 'src/login_page.dart';
export 'src/register_page.dart';
export 'src/auth_wrapper.dart';
// export 'src/user_manager.dart'; // Temporarily disabled - needs redesign for Supabase Auth

/// A Calculator (legacy - kept for backward compatibility).
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
