import 'package:flutter/material.dart';
import 'package:flutter_application_1/DataBase.dart';
import 'package:flutter_application_1/StartPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart'; // Import your HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase credentials
  const String supabaseUrl = 'https://zapcdfucvonafgnffqpa.supabase.co';
  const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphcGNkZnVjdm9uYWZnbmZmcXBhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg1NTE0MzcsImV4cCI6MjA1NDEyNzQzN30.JvVIyj88YPLSyOSHw7HFYKavZKceB5r59m9hvEg1SJI';

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Startpage(),
    );
  }
}