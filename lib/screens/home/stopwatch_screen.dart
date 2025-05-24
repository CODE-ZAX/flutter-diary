import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'stopwatch_controller.dart';

class StopwatchPage extends StatelessWidget {
  final StopwatchController controller = Get.put(StopwatchController());

  Color get primary => Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('⏱️ Stopwatch'),
        backgroundColor: primary,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    controller.formatTime(controller.elapsed.value),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: primary.shade800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Lottie.asset(
                    controller.isRunning.value
                        ? 'assets/animation_running.json'
                        : 'assets/animation_idle.json',
                    height: 80,
                  ),
                ],
              ),
            )),
            const SizedBox(height: 30),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  onTap: controller.isRunning.value ? controller.stop : controller.start,
                  text: controller.isRunning.value ? 'Stop' : 'Start',
                  color: controller.isRunning.value ? Colors.red : primary,
                ),
                _buildControlButton(
                  onTap: controller.reset,
                  text: 'Reset',
                  color: Colors.grey.shade600,
                ),
                _buildControlButton(
                  onTap: controller.isRunning.value ? controller.recordLap : null,
                  text: 'Lap',
                  color: Colors.teal,
                ),
              ],
            )),
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.flag, color: primary.shade400),
                const SizedBox(width: 10),
                Text('Laps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary.shade700)),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => Expanded(
              child: controller.laps.isEmpty
                  ? Center(child: Text('No laps yet.', style: TextStyle(color: primary.shade300)))
                  : ListView.separated(
                      itemCount: controller.laps.length,
                      separatorBuilder: (_, __) => Divider(color: primary.shade100),
                      itemBuilder: (context, index) {
                        final lapTime = controller.formatTime(controller.laps[index]);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primary.withOpacity(0.2),
                            child: Text('${index + 1}', style: TextStyle(color: primary)),
                          ),
                          title: Text('Lap ${index + 1}'),
                          trailing: Text(lapTime, style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onTap,
    required String text,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: onTap == null ? Colors.grey.shade300 : color,
        foregroundColor: Colors.white,
        elevation: 5,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
