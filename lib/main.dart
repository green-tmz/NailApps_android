import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api/api_client.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Добавьте для веб-версии
  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback = (cert, host, port) => true;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ApiClient(),
      child: MaterialApp(
        title: 'NailApps',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}