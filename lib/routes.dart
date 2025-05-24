// routes.dart
import 'package:everyday_chronicles/screens/auth/sign_in_screen.dart';
import 'package:everyday_chronicles/screens/home/diary_screen.dart';
import 'package:everyday_chronicles/screens/home/exercises_screen.dart';
import 'package:everyday_chronicles/screens/home/homescreen.dart';
import 'package:everyday_chronicles/screens/home/mood_check.dart';
import 'package:everyday_chronicles/screens/home/prayer_screen.dart';
import 'package:everyday_chronicles/screens/home/setting_page.dart';
import 'package:everyday_chronicles/screens/home/stopwatch_screen.dart';
import 'package:everyday_chronicles/screens/home/weather_steps_screen.dart';
import 'package:get/get.dart';

final appRoutes = [
  GetPage(name: '/login', page: () => SignInScreen()),
  GetPage(name: '/dashboard', page: () => DashboardScreen()),
  GetPage(name: '/settings', page: () => SettingsPage()),
  GetPage(name: '/mood', page: () => MoodCheckerPage()),
  GetPage(name: '/exercises', page: () => ExerciseScreen()),
  GetPage(name: '/weathersteps', page: () => WeatherStepsPage()),
  GetPage(name: '/namaz', page: () => NamazPage()),
  GetPage(name: '/stopwatch', page: () => StopwatchPage()),
  GetPage(name: '/diary', page: () => DiaryHomeScreen()),
];
