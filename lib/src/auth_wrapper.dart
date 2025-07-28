import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'config.dart';
import 'login_page.dart';
import 'register_page.dart';

/// A wrapper widget that handles authentication state and navigation
class BasificAuthWrapper extends StatefulWidget {
  /// Widget to show when user is authenticated
  final Widget Function(BasificUser user) authenticatedBuilder;
  
  /// Widget to show when user is not authenticated (optional)
  /// If null, will show the default login page
  final Widget? unauthenticatedWidget;
  
  /// Title for the default login page
  final String? loginTitle;
  
  /// Loading widget to show while checking authentication state
  final Widget? loadingWidget;
  
  /// Whether to automatically listen to auth state changes
  final bool autoListen;

  const BasificAuthWrapper({
    super.key,
    required this.authenticatedBuilder,
    this.unauthenticatedWidget,
    this.loginTitle,
    this.loadingWidget,
    this.autoListen = true,
  });

  @override
  State<BasificAuthWrapper> createState() => _BasificAuthWrapperState();
}

class _BasificAuthWrapperState extends State<BasificAuthWrapper> {
  BasificUser? _currentUser;
  bool _isLoading = true;
  late Stream<AuthState>? _authStateStream;

  @override
  void initState() {
    super.initState();
    _checkInitialAuthState();
    if (widget.autoListen) {
      _setupAuthListener();
    }
  }

  void _checkInitialAuthState() {
    setState(() {
      _currentUser = BasificAuth.currentUser;
      _isLoading = false;
    });
  }

  void _setupAuthListener() {
    _authStateStream = BasificAuth.authStateChanges;
    _authStateStream!.listen((authState) {
      if (mounted) {
        setState(() {
          _currentUser = BasificAuth.currentUser;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ?? 
        const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }

    if (_currentUser != null) {
      return widget.authenticatedBuilder(_currentUser!);
    }

    return widget.unauthenticatedWidget ?? 
      BasificLoginPage(
        title: widget.loginTitle ?? 'Login',
        onLoginSuccess: (user) {
          if (mounted) {
            setState(() {
              _currentUser = user;
            });
          }
        },
      );
  }
}

/// A simple authentication guard that redirects to login if not authenticated
class BasificAuthGuard extends StatelessWidget {
  final Widget child;
  final Widget Function()? loginPageBuilder;
  final String? loginTitle;

  const BasificAuthGuard({
    super.key,
    required this.child,
    this.loginPageBuilder,
    this.loginTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (BasificAuth.isAuthenticated) {
      return child;
    }

    return loginPageBuilder?.call() ?? 
      BasificLoginPage(
        title: loginTitle ?? 'Login Required',
        onLoginSuccess: (user) {
          // The navigation will be handled automatically by auth state changes
        },
      );
  }
}

/// Convenience methods for common authentication flows
class BasificAuthHelper {
  /// Show a login dialog
  static Future<BasificUser?> showLoginDialog(
    BuildContext context, {
    String? title,
    bool barrierDismissible = true,
  }) async {
    BasificUser? result;
    
    await showDialog<BasificUser>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 600),
          child: BasificLoginPage(
            title: title ?? 'Login',
            onLoginSuccess: (user) {
              result = user;
              Navigator.of(context).pop(user);
            },
          ),
        ),
      ),
    );
    
    return result;
  }

  /// Show a register dialog
  static Future<BasificUser?> showRegisterDialog(
    BuildContext context, {
    String? title,
    bool barrierDismissible = true,
  }) async {
    BasificUser? result;
    
    await showDialog<BasificUser>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          constraints: const BoxConstraints(maxHeight: 700),
          child: BasificRegisterPage(
            title: title ?? 'Register',
            onRegisterSuccess: (user) {
              result = user;
              Navigator.of(context).pop(user);
            },
          ),
        ),
      ),
    );
    
    return result;
  }

  /// Navigate to login page
  static void navigateToLogin(
    BuildContext context, {
    String? title,
    Widget Function(BasificUser)? onSuccess,
    bool replacement = false,
  }) {
    final route = MaterialPageRoute(
      builder: (context) => BasificLoginPage(
        title: title ?? 'Login',
        onLoginSuccess: onSuccess != null 
          ? (user) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => onSuccess(user)),
              );
            }
          : null,
      ),
    );

    if (replacement) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Navigate to register page
  static void navigateToRegister(
    BuildContext context, {
    String? title,
    Widget Function(BasificUser)? onSuccess,
    bool replacement = false,
  }) {
    final route = MaterialPageRoute(
      builder: (context) => BasificRegisterPage(
        title: title ?? 'Register',
        onRegisterSuccess: onSuccess != null 
          ? (user) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => onSuccess(user)),
              );
            }
          : null,
      ),
    );

    if (replacement) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Logout and optionally navigate to login
  static Future<void> logoutAndNavigate(
    BuildContext context, {
    String? loginTitle,
    bool showConfirmDialog = true,
  }) async {
    bool shouldLogout = true;

    if (showConfirmDialog) {
      shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        ),
      ) ?? false;
    }

    if (shouldLogout) {
      await Basific.logout();
      
      if (context.mounted) {
        navigateToLogin(
          context,
          title: loginTitle,
          replacement: true,
        );
      }
    }
  }
}
