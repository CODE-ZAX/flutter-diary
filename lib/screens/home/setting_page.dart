import 'package:everyday_chronicles/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text("Change Full Name"),
          trailing: Icon(Icons.edit),
          onTap: () {
            Get.defaultDialog(
              title: "Enter new name",
              content: TextField(
                onSubmitted: controller.changeFullName,
              ),
            );
          },
        ),
        ListTile(
          title: Text("Delete All Diary Pages"),
          trailing: Icon(Icons.delete_forever),
          onTap: controller.deleteAllDiaryPages,
        ),
        ListTile(
          title: Text("Change Location"),
          trailing: Icon(Icons.location_on),
          onTap: () {
            Get.defaultDialog(
              title: "Enter new location",
              content: TextField(
                onSubmitted: controller.updateLocation,
              ),
            );
          },
        ),
        ListTile(
          title: Text("Privacy Policy"),
          trailing: Icon(Icons.privacy_tip),
          onTap: controller.openPrivacyPolicy,
        ),
        ListTile(
          title: Text("Terms and Conditions"),
          trailing: Icon(Icons.description),
          onTap: controller.openTermsAndConditions,
        ),
        ListTile(
          title: Text("Change Theme"),
          trailing: Icon(Icons.color_lens),
          onTap: () {
            Get.bottomSheet(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Light Theme"),
                    onTap: () => controller.changeTheme(ThemeMode.light),
                  ),
                  ListTile(
                    title: Text("Dark Theme"),
                    onTap: () => controller.changeTheme(ThemeMode.dark),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            );
          },
        ),
        ListTile(
          title: Text("Logout"),
          trailing: Icon(Icons.logout),
          onTap: controller.logout,
        ),
      ],
    );
  }
}
