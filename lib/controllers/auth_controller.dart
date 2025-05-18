// controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyday_chronicles/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/home/dairy_homescreen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> firebaseUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAll(() => SignInScreen());
    } else {
      await AuthController.instance.loadUser(user.uid);
      Get.offAll(() => DairyHomeScreen());
    }
  }

  void signIn(String email, String password) async {
    try {
      UserCredential cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await AuthController.instance.loadUser(cred.user!.uid);
    } catch (e) {
      Get.snackbar("Sign In Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        prayerCount: {
          'fajr': 0,
          'zuhr': 0,
          'asr': 0,
          'maghrib': 0,
          'isha': 0,
        },
        diaryPageIds: [],
        mood: 'neutral',
      );

      await firestore
          .collection("users")
          .doc(cred.user!.uid)
          .set(newUser.toMap());

      await AuthController.instance.loadUser(cred.user!.uid);
    } catch (e) {
      Get.snackbar("Sign Up Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Email Sent", "Check your inbox",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void signOut() async {
    await auth.signOut();
    AuthController.instance.clearUser();
  }

  Future<void> loadUser(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await firestore.collection("users").doc(uid).get();
      if (snapshot.exists) {
        currentUser.value =
            UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        Get.snackbar("Error", "User data not found in Firestore");
      }
    } catch (e) {
      Get.snackbar("Error Loading User", e.toString());
    }
  }

  void clearUser() {
    currentUser.value = null;
  }
}
