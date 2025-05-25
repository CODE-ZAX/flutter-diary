import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/prayer_api_service.dart';
import '../models/prayer_model.dart';
import 'auth_controller.dart';

class NamazController extends GetxController {
  static NamazController instance = Get.find();
  var prayerTimes = <PrayerTime>[].obs;
  var checkedPrayers = <String, bool>{}.obs;
  var minutesLeft = <String, int>{}.obs;

  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchAndProcessPrayerTimes();
    ever(AuthController.instance.currentUser, (user) {
      if (user?.location != null) {
        fetchAndProcessPrayerTimes();
      }
    });
  }

  PrayerTime? get currentPrayer {
    final now = DateTime.now();

    for (int i = 0; i < prayerTimes.length; i++) {
      final start = prayerTimes[i].time;
      final end = (i + 1 < prayerTimes.length)
          ? prayerTimes[i + 1].time
          : DateTime(now.year, now.month, now.day, 23, 59, 59); // till midnight

      if (now.isAfter(start) && now.isBefore(end)) {
        return prayerTimes[i];
      }
    }
    return null;
  }

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    return prayerTimes.firstWhereOrNull((p) => p.time.isAfter(now));
  }

  Future<void> fetchAndProcessPrayerTimes() async {
    final auth = AuthController.instance;
    final user = auth.currentUser.value;
    if (user == null) {
      return;
    }
    try {
      final location = auth.currentUser.value?.location;
      if (location == null) {
        return;
      }

      final times = await PrayerApiService.fetchPrayerTimes(
          location.lat, location.lng); // Karachi

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

    final current = currentPrayer?.name;

    // Only allow toggling the current active prayer
    if (prayer != current) return;

    final isChecked = checkedPrayers[prayer] ?? false;
    checkedPrayers[prayer] = !isChecked;

    await firestore
        .collection('namaz_tracking')
        .doc(uid)
        .collection('dates')
        .doc(date)
        .set(checkedPrayers);
  }
}
