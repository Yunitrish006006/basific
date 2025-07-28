import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Basific with Supabase configuration
  await Basific.initialize(
    BasificConfig(
      supabaseUrl: 'https://qikzlcnsyiihftudbmkp.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpa3psY25zeWlpaGZ0dWRibWtwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM3MzI3NDcsImV4cCI6MjA2OTMwODc0N30.Sjy7wm7gqgXfOy48aW52w9lYD8UdeBoKe3AGY1NaUPk',
      theme: BasificTheme(
        primaryColor: Colors.deepPurple,
        borderRadius: 8.0,
      ),
    ),
  );
  
  runApp(const MyApp());
}
