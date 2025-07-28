import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:basific/basific.dart';

class ProfilesSetupPage extends StatefulWidget {
  const ProfilesSetupPage({super.key});

  @override
  State<ProfilesSetupPage> createState() => _ProfilesSetupPageState();
}

class _ProfilesSetupPageState extends State<ProfilesSetupPage> {
  bool _isChecking = false;
  bool? _isSetup;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkProfilesTable();
  }

  Future<void> _checkProfilesTable() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Checking profiles table setup...';
    });

    try {
      final isSetup = await BasificAuth.checkProfilesTableSetup();
      setState(() {
        _isSetup = isSetup;
        _statusMessage = isSetup 
          ? 'Profiles table is properly configured! Username login is available.'
          : 'Profiles table needs to be set up to enable username login.';
      });
    } catch (e) {
      setState(() {
        _isSetup = false;
        _statusMessage = 'Error checking profiles table: $e';
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SQL copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Basific.config.theme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles Table Setup'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isChecking 
                            ? Icons.refresh 
                            : _isSetup == true 
                              ? Icons.check_circle 
                              : Icons.warning,
                          color: _isChecking 
                            ? Colors.blue 
                            : _isSetup == true 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Setup Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        if (!_isChecking)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _checkProfilesTable,
                            tooltip: 'Recheck setup',
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuration Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Configuration',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildConfigRow('Table Name', Basific.config.profilesTableName),
                    _buildConfigRow('Username Column', Basific.config.usernameColumn),
                    _buildConfigRow('Email Column', Basific.config.emailColumn),
                    _buildConfigRow('Username Login Enabled', 
                      Basific.config.enableUsernameLogin ? 'Yes' : 'No'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Setup Instructions
            if (_isSetup != true) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Copy the SQL script below\n'
                        '2. Go to your Supabase SQL Editor\n'
                        '3. Paste and execute the script\n'
                        '4. Come back and check the status',
                      ),
                      const SizedBox(height: 16),
                      
                      // SQL Script
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SQL Setup Script',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () => _copyToClipboard(
                                    BasificProfilesHelper.generateCreateTableSQL(),
                                  ),
                                  tooltip: 'Copy SQL to clipboard',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: Text(
                                  BasificProfilesHelper.generateCreateTableSQL(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Test Login Section
            if (_isSetup == true) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Username Login',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Great! Your profiles table is set up. You can now:\n\n'
                        '• Login with email: user@example.com\n'
                        '• Login with username: username\n\n'
                        'Both will work in the login form.',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BasificLoginPage(
                                title: 'Test Username Login',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Test Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
