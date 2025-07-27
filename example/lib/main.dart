import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nnudswiisoxpvjrcncvo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5udWRzd2lpc294cHZqcmNuY3ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2NDMzMzUsImV4cCI6MjA2OTIxOTMzNX0.fimaJBblmgJTtHcAn9kRbffS_LYHYhC_pWq_Ti5TSWQ',
  );
  runApp(const MyApp());
}
