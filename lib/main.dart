import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/views/pages/auth_page.dart';
import 'package:visoattend/views/pages/classroom_page.dart';

import './firebase_options.dart';
import './views/pages/login_register_page.dart';
import './global_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // GlobalBinding().dependencies();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GlobalBinding(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const AuthPage(),
    ),
  );
}
