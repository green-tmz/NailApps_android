import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nail_apps/screens/clients/clients_screen.dart';
import 'package:provider/provider.dart';
import 'api/api_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ApiCore(),
      child: MaterialApp(
        title: 'NailApps',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/clients': (context) => ClientsScreen(),
        },
      ),
    );
  }
}