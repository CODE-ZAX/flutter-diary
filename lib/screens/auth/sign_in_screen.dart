import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  final AuthController controller = Get.find<AuthController>();

  String? validateEmail(String value) {
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void signIn() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    isLoading.value = true;
    await controller.signIn(email.value, password.value); // Simulate API call
    isLoading.value = false;
    Get.snackbar('Success', 'Signed in successfully');
  }
}

class SignInScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade600, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 36),
                  child: Form(
                      key: _formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sign in to continue',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.deepPurple.shade200),
                        ),
                        SizedBox(height: 32),

                        // Email
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => controller.email.value = value,
                          validator: (value) =>
                              controller.validateEmail(value ?? ''),
                        ),
                        SizedBox(height: 20),

                        // Password
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.deepPurple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.deepPurple, width: 2),
                            ),
                          ),
                          obscureText: true,
                          onChanged: (value) =>
                              controller.password.value = value,
                          validator: (value) =>
                              controller.validatePassword(value ?? ''),
                        ),
                        SizedBox(height: 12),

                        // Forgot Password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to forgot password screen
                              Get.snackbar('Info', 'Forgot Password clicked');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // Sign In button
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          controller.signIn();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 6,
                                ),
                                child: controller.isLoading.value
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Sign In',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            )),
                        SizedBox(height: 20),

                        // Don't have account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            TextButton(
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  // TODO: Navigate to sign
                                  Get.to(SignUpScreen());
                                }),
                          ],
                        ),
                      ])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
