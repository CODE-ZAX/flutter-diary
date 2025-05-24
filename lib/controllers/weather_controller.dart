import 'package:get/get.dart';
import 'package:everyday_chronicles/controllers/auth_controller.dart';

class WeatherStepsController extends GetxController {
  final authController = Get.find<AuthController>();

  final weatherData = Rxn<Map<String, dynamic>>();
  final stepCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
    initStepTracking();
  }

  Future<void> fetchWeather() async {
    final location = authController.currentUser.value?.location;
    if (location == null) return;

    // Mock API or use OpenWeatherMap API here
    final lat = location.lat;
    final lon = location.lng;

    // Simulate weather fetch
    await Future.delayed(const Duration(seconds: 1));
    weatherData.value = {
      "temperature": 26,
      "description": "Partly Cloudy",
      "location": "$lat, $lon"
    };
  }

  void initStepTracking() {
    // You can use `pedometer` or `health` package here
    // For mock purposes
    stepCount.value = 3210;
  }
}
