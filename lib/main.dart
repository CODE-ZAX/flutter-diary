// main.dart
import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/translations.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(DiaryController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MD Diary',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
      ],
      home: SignInScreen(),
    );
  }
}
