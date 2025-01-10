import 'package:final_project/Pages/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://xrrixbojpkjxeqpiress.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhycml4Ym9qcGtqeGVxcGlyZXNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY1MzQyNzgsImV4cCI6MjA1MjExMDI3OH0.Fs7yBqYHQ-u1L4QPDfJ6VsZsVjKhXBUHkVJY45zYrz4',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}

