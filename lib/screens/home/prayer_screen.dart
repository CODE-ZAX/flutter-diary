import 'package:everyday_chronicles/controllers/prayer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NamazPage extends StatelessWidget {
  final NamazController controller = Get.put(NamazController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Namaz Tracker")),
      body: Obx(() {
        return ListView(
          padding: EdgeInsets.all(16),
          children: controller.prayerTimes.map((prayer) {
            final isPast = DateTime.now().isAfter(prayer.time);
            final remaining = controller.minutesLeft[prayer.name] ?? 0;

            return Card(
              child: ListTile(
                title: Text(prayer.name),
                subtitle: Text(
                  isPast
                      ? "Time passed"
                      : "$remaining minutes left (${prayer.time.hour}:${prayer.time.minute.toString().padLeft(2, '0')})",
                ),
                trailing: Checkbox(
                  value: controller.checkedPrayers[prayer.name] ?? false,
                  onChanged: isPast
                      ? null
                      : (_) => controller.togglePrayer(prayer.name),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
