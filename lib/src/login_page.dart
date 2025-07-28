import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'config.dart';
import 'register_page.dart';

/// Ready-to-use login page widget
class BasificLoginPage extends StatefulWidget {
  /// Callback when login is successful
  final Function(BasificUser user)? onLoginSuccess;
  
  /// Custom app bar title
  final String? title;
  
  /// Custom logo widget
  final Widget? logo;
  
  /// Show register link
  final bool showRegisterLink;

  const BasificLoginPage({
    super.key,
    this.onLoginSuccess,
    this.title,
    this.logo,
    this.showRegisterLink = true,
  });

  @override
  State<BasificLoginPage> createState() => _BasificLoginPageState();
}

class _BasificLoginPageState extends State<BasificLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BasificAuth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSuccess && result.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${result.user!.name}!'),
              backgroundColor: Basific.config.theme.successColor,
            ),
          );
          
          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!(result.user!);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Login failed'),
              backgroundColor: Basific.config.theme.errorColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Basific.config.theme;
    
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: widget.title != null 
        ? AppBar(
            title: Text(widget.title!),
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          )
        : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or icon
                widget.logo ?? Icon(
                  Icons.login,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 30),
                
                // Title
                Text(
                  widget.title ?? 'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Email input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    // Basic email validation
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password input
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(theme.borderRadius),
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.borderRadius),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                // Register link
                if (widget.showRegisterLink) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: theme.textColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BasificRegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
