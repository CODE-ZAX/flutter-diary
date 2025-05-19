import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/prayer_api_service.dart';
import '../models/prayer_model.dart';
import 'auth_controller.dart';

class NamazController extends GetxController {
  var prayerTimes = <PrayerTime>[].obs;
  var checkedPrayers = <String, bool>{}.obs;
  var minutesLeft = <String, int>{}.obs;

  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchAndProcessPrayerTimes();
  }

  Future<void> fetchAndProcessPrayerTimes() async {
    try {
      final times =
          await PrayerApiService.fetchPrayerTimes(24.8607, 67.0011); // Karachi

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      prayerTimes.clear();
      checkedPrayers.clear();

      times.forEach((name, timeStr) {
        if (_isRelevantPrayer(name)) {
          final time = DateFormat("HH:mm").parse(timeStr);
          final todayTime =
              DateTime(now.year, now.month, now.day, time.hour, time.minute);
          prayerTimes.add(PrayerTime(name: name, time: todayTime));

          final diff = todayTime.difference(now).inMinutes;
          minutesLeft[name] = diff > 0 ? diff : 0;
        }
      });

      await loadUserPrayerStatus(today);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  bool _isRelevantPrayer(String name) {
    return ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].contains(name);
  }

  Future<void> loadUserPrayerStatus(String date) async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    final doc = await firestore
        .collection('namaz_tracking')
        .doc(uid)
        .collection('dates')
        .doc(date)
        .get();

    if (doc.exists) {
      checkedPrayers.assignAll(Map<String, bool>.from(doc.data()!));
    } else {
      checkedPrayers.assignAll({for (var p in prayerTimes) p.name: false});
    }
  }

  Future<void> togglePrayer(String prayer) async {
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    final current = checkedPrayers[prayer] ?? false;
    checkedPrayers[prayer] = !current;

    await firestore
        .collection('namaz_tracking')
        .doc(uid)
        .collection('dates')
        .doc(date)
        .set(checkedPrayers);
  }
}
