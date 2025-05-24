// main.dart
import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/controllers/prayer_controller.dart';
import 'package:everyday_chronicles/controllers/setting_controller.dart';
import 'package:everyday_chronicles/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/translations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(DiaryController());
    Get.put(NamazController());
    Get.put(SettingsController());

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Everyday Chronicles',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
        ],
        initialRoute: '/login',
        getPages: appRoutes);
  }
}
