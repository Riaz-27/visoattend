import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import './firebase_options.dart';
import './global_bindings.dart';
import './views/pages/auth_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GlobalBinding(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home:  const AuthPage(),
    ),
  );
}
