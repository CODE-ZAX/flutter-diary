import 'package:everyday_chronicles/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../controllers/diary_controller.dart';

class SettingsController extends GetxController {
  static SettingsController instance = Get.put(SettingsController());

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> changeFullName(String fullName) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await firestore
          .collection("users")
          .doc(uid)
          .update({'fullName': fullName});
      await AuthController.instance.loadUser(uid);
      Get.snackbar("Success", "Full name updated.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteAllDiaryPages() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      var diaryRef =
          firestore.collection("users").doc(uid).collection("diaryPages");
      var snapshot = await diaryRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      DiaryController.instance.userDiaryPages.clear();
      Get.snackbar("Deleted", "All diary pages removed.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateLocation(Location newLocation) async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'location': newLocation.toJson(),
    });

    AuthController.instance.currentUser.update((val) {
      if (val != null) val.location = newLocation;
    });
    AuthController.instance.loadUser(uid);
  }

  void openPrivacyPolicy() async {
    final url = Uri.parse("https://www.cygnetic.net/privacy-policy");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open Privacy Policy");
    }
  }

  void openTermsAndConditions() async {
    final url = Uri.parse("https://www.cygnetic.net/terms-and-conditions");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Could not open Terms & Conditions");
    }
  }

  void changeTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);
  }

  void logout() {
    AuthController.instance.signOut();
  }
}
