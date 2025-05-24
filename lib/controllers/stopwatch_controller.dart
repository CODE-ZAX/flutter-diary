import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StopwatchController extends GetxController {
  final box = GetStorage();

  var elapsed = 0.obs; // milliseconds
  var isRunning = false.obs;
  var laps = <int>[].obs;

  Timer? _timer;

  void start() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      elapsed.value += 100;
    });
    isRunning.value = true;
  }

  void stop() {
    _timer?.cancel();
    isRunning.value = false;
  }

  void reset() {
    stop();
    elapsed.value = 0;
    laps.clear();
    box.remove('laps');
  }

  void recordLap() {
    laps.add(elapsed.value);
    saveLapsToStorage();
  }

  void saveLapsToStorage() {
    box.write('laps', laps.toList());
  }

  void loadLapsFromStorage() {
    final storedLaps = box.read<List>('laps');
    if (storedLaps != null) {
      laps.assignAll(storedLaps.map((e) => e as int));
    }
  }

  String formatTime(int ms) {
    final seconds = (ms ~/ 1000) % 60;
    final minutes = (ms ~/ 60000) % 60;
    final hours = ms ~/ 3600000;
    final centiseconds = (ms ~/ 100) % 10;

    return '${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}.$centiseconds';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  void onInit() {
    super.onInit();
    loadLapsFromStorage();
  }
}
