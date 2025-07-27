# Basific

A comprehensive Flutter package for authentication and user management with Supabase integration. Provides ready-to-use login, registration, and user management components.

## Features

- 🔐 **Complete Authentication System** - Login and registration with validation
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
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  level TEXT DEFAULT 'user'
);
```

### 3. Use Components

```dart
// Login Page
BasificLoginPage(
  onLoginSuccess: (user) {
    // Navigate to home
  },
)

// User Management
BasificUserManager(
  title: 'Manage Users',
  showAddButton: true,
)
```

## Requirements

- Flutter 3.0.0+
- Dart 3.8.1+
- Supabase project
