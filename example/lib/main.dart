import 'package:flutter/material.dart';
import 'package:basific/basific.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Basific with Supabase configuration
  await Basific.initialize(
    BasificConfig(
      supabaseUrl: 'https://nnudswiisoxpvjrcncvo.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5udWRzd2lpc294cHZqcmNuY3ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2NDMzMzUsImV4cCI6MjA2OTIxOTMzNX0.fimaJBblmgJTtHcAn9kRbffS_LYHYhC_pWq_Ti5TSWQ',
      theme: BasificTheme(
        primaryColor: Colors.deepPurple,
        borderRadius: 8.0,
      ),
    ),
  );
  
  runApp(const MyApp());
}
