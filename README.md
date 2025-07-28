# Basific

A comprehensive Flutter package for authentication and user management with Supabase integration. Provides ready-to-use login, registration, and user management components.

## Features

- 🔐 **Complete Authentication System** - Login and registration with validation
- 🆔 **Multiple Login Methods** - Support for both email and username login
- 👥 **User Management** - CRUD operations for user accounts
- 🎨 **Customizable UI** - Themeable components that match your app design
- 🗃️ **Supabase Integration** - Built-in support for Supabase backend
- 📱 **Ready-to-use Components** - Drop-in widgets for common auth flows
- ⚙️ **Configurable** - Flexible table and column name mapping

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  basific: ^1.0.0
```

## Quick Start

### 1. Initialize Basific

```dart
import 'package:basific/basific.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Basific with your Supabase credentials
  await Basific.initialize(
    BasificConfig(
      supabaseUrl: 'YOUR_SUPABASE_URL',
      supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
    ),
  );
  
  runApp(MyApp());
}
```

### 2. Database Setup

Create a table in your Supabase database:

```sql
CREATE TABLE account (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  level TEXT DEFAULT 'user'
);
```

### 3. Use Components

```dart
// Login Page - supports both email and username
BasificLoginPage(
  onLoginSuccess: (user) {
    // Navigate to home
  },
)

// Login programmatically with email
final result = await Basific.login('user@example.com', 'password');

// Login programmatically with username or email
final result = await Basific.loginWithUsernameOrEmail('username_or_email', 'password');

// User Management
BasificUserManager(
  title: 'Manage Users',
  showAddButton: true,
)
```

## Login Methods

Basific supports two login methods:

1. **Email Login**: Traditional email and password authentication
2. **Username Login**: Users can login with their username instead of email

The login page automatically detects whether the input is an email (contains @) or a username, and handles the authentication accordingly.

When using username login, Basific:
1. Checks if the input contains @ (email format)
2. If not, queries the `account` table to find the corresponding user ID
3. Retrieves the email from Supabase auth.users table
4. Performs authentication using the email

### Database Schema

For username login to work, you need both:

1. **Supabase Auth Users** (managed automatically)
2. **Custom Account Table**:

```sql
CREATE TABLE account (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  account TEXT UNIQUE NOT NULL,  -- This is the username
  email TEXT UNIQUE NOT NULL,    -- Email for login (synced with auth.users)
  password TEXT NOT NULL,        -- Not used in auth, kept for compatibility
  name TEXT NOT NULL,
  level TEXT DEFAULT 'user'
);
```

## Requirements

- Flutter 3.0.0+
- Dart 3.8.1+
- Supabase project
