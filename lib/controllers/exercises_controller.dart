import 'package:get/get.dart';

class ExercisesController extends GetxController {
  static ExercisesController instance = Get.find();
  final RxList<String> videoUrls = [
    "https://youtu.be/DV2L-f7VTaQ?si=h8kW6cT7mi6HetBt",
    "https://youtu.be/pz6nN0lxgkw?si=x-cqEKQNgSf09Pv5",
    "https://youtu.be/_-qsKw4eQ2c?si=buOeQl559DFB0phh",
    "https://youtu.be/B7NUu5auvto?si=9I9w103uBPQs689i",
    "https://youtu.be/cn59Y2ZluEk?si=1JKyAQR_dqNYxNii",
  ].obs;

  String extractVideoId(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.split("?").first
        : "";
  }
}
