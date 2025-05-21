import 'dart:async';
import 'package:everyday_chronicles/controllers/prayer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NamazPage extends StatefulWidget {
  @override
  State<NamazPage> createState() => _NamazPageState();
}

class _NamazPageState extends State<NamazPage> {
  final NamazController controller = Get.put(NamazController());
  late Timer countdownTimer;
  String countdown = "";

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final nextPrayer = controller.nextPrayer;
      if (nextPrayer == null) return;

      final now = DateTime.now();
      final diff = nextPrayer.time.difference(now);

      if (diff.isNegative) {
        countdown = "00:00:00";
      } else {
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        countdown = "$hours:$minutes:$seconds";
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
  }

  final Map<String, IconData> prayerIcons = {
    'Fajr': Icons.wb_twighlight,
    'Dhuhr': Icons.wb_sunny,
    'Asr': Icons.wb_cloudy,
    'Maghrib': Icons.nights_stay,
    'Isha': Icons.nightlight_round,
  };

  Color getCardColor(
      {required bool isCurrent, required bool isNext, required bool isPast}) {
    if (isCurrent) return Colors.deepPurple.shade400;
    if (isPast) return Colors.grey.shade200;
    return Colors.white;
  }

  // Returns text color based on prayer status
  Color getTextColor(
      {required bool isCurrent, required bool isNext, required bool isPast}) {
    if (isCurrent) return Colors.white;
    if (isPast) return Colors.grey;
    return Colors.deepPurple.shade900;
  }

  // Returns subtitle text color based on prayer status
  Color getSubtitleColor(
      {required bool isCurrent, required bool isNext, required bool isPast}) {
    if (isCurrent) return Colors.white60;
    if (isNext) return Colors.deepPurple.shade600;
    return Colors.deepPurple.shade600;
  }

  FontWeight getTitleFontWeight(
      {required bool isCurrent, required bool isNext}) {
    if (isCurrent || isNext) return FontWeight.w800;
    return FontWeight.w600;
  }

  FontWeight getSubtitleFontWeight({required bool isCurrent}) {
    return isCurrent ? FontWeight.w600 : FontWeight.normal;
  }

  String formatRemainingTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return "$hours hr ${minutes} min left";
    } else if (hours > 0) {
      return "$hours hr left";
    } else {
      return "$minutes min left";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Obx(() {
        final total = controller.prayerTimes.length;
        final checked = controller.checkedPrayers.values.where((v) => v).length;
        final progress = total > 0 ? checked / total : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              color: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMMEEEEd().format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Next: ${controller.nextPrayer?.name ?? '-'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "In $countdown",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.deepPurple.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.prayerTimes.length,
                itemBuilder: (context, index) {
                  final prayer = controller.prayerTimes[index];
                  final now = DateTime.now();
                  final isPast = now.isAfter(prayer.time);
                  final remaining = controller.minutesLeft[prayer.name] ?? 0;
                  final isNext = controller.nextPrayer?.name == prayer.name;
                  final isCurrent =
                      controller.currentPrayer?.name == prayer.name;
                  final isChecked =
                      controller.checkedPrayers[prayer.name] ?? false;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: getCardColor(
                          isCurrent: isCurrent, isNext: isNext, isPast: isPast),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? Colors.deepPurple.shade200
                            : Colors.deepPurple.shade100,
                        child: Icon(
                          prayerIcons[prayer.name] ?? Icons.access_time,
                          color: isCurrent
                              ? Colors.deepPurple.shade900
                              : Colors.deepPurple.shade700,
                        ),
                      ),
                      title: Text(
                        prayer.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: getTitleFontWeight(
                              isCurrent: isCurrent, isNext: isNext),
                          color: getTextColor(
                              isCurrent: isCurrent,
                              isNext: isNext,
                              isPast: isPast),
                        ),
                      ),
                      subtitle: Text(
                        isCurrent
                            ? "Current prayer"
                            : isPast
                                ? "Time passed at ${DateFormat.jm().format(prayer.time)}"
                                : "Starts at ${DateFormat.jm().format(prayer.time)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              getSubtitleFontWeight(isCurrent: isCurrent),
                          color: getSubtitleColor(
                              isCurrent: isCurrent,
                              isNext: isNext,
                              isPast: isPast),
                        ),
                      ),
                      trailing: Checkbox(
                        activeColor: Colors.deepPurple,
                        value: isChecked,
                        onChanged: isCurrent
                            ? (_) => controller.togglePrayer(prayer.name)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
