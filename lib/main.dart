import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './views/pages/login_page.dart';
import 'global_bindings.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // GlobalBinding().dependencies();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GlobalBinding(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const LoginPage(),
    ),
  );
}
