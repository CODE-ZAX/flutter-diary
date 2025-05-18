import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

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
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    isLoading.value = false;
    Get.snackbar('Success', 'Signed in successfully');
  }
}

class SignInScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => controller.email.value = value,
                validator: (value) => controller.validateEmail(value ?? ''),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) => controller.password.value = value,
                validator: (value) => controller.validatePassword(value ?? ''),
              ),
              SizedBox(height: 16),
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.signIn();
                            }
                          },
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text('Sign In'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
