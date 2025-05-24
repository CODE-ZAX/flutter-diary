import 'package:dropdown_search/dropdown_search.dart';
import 'package:everyday_chronicles/controllers/auth_controller.dart';
import 'package:everyday_chronicles/controllers/setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:everyday_chronicles/models/user_model.dart';

class SettingsPage extends StatelessWidget {
  final AuthController authController = AuthController.instance;
  final SettingsController settingsController = SettingsController.instance;

  final TextEditingController fullNameController = TextEditingController();
  final Rx<Location?> selectedCity = Rx<Location?>(null);

  SettingsPage({Key? key}) : super(key: key);

  final Map<String, Location> _cityLocations = {
    "Lahore": Location(31.5204, 74.3587, "Lahore"),
    "Karachi": Location(24.8607, 67.0011, "Karachi"),
    "Islamabad": Location(33.6844, 73.0479, "Islamabad"),
    "Rawalpindi": Location(33.6007, 73.0679, "Rawalpindi"),
    "Peshawar": Location(34.0150, 71.5805, "Peshawar"),
    "Quetta": Location(30.1798, 66.9750, "Quetta"),
    "Multan": Location(30.1575, 71.5249, "Multan"),
    "Faisalabad": Location(31.4504, 73.1350, "Faisalabad"),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final user = authController.currentUser.value;

    fullNameController.text = user!.fullName;
    selectedCity.value = user.location as Location?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              title: "Profile",
              children: [
                _buildTextInput(
                  label: "Full Name",
                  controller: fullNameController,
                  onSave: () {
                    final name = fullNameController.text.trim();
                    if (name.isNotEmpty) {
                      settingsController.changeFullName(name);
                    }
                  },
                ),
                _buildCityDropdown(),
              ],
            ),
            // const SizedBox(height: 20),
            // _buildSectionCard(
            //   title: "App Settings",
            //   children: [
            //     SwitchListTile(
            //       title: const Text("Dark Mode"),
            //       value: isDark,
            //       onChanged: (val) => settingsController
            //           .changeTheme(val ? ThemeMode.dark : ThemeMode.light),
            //       secondary: Icon(
            //         isDark ? Icons.nightlight_round : Icons.wb_sunny,
            //         color: theme.colorScheme.primary,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Legal",
              children: [
                _buildTileButton(
                  icon: Icons.privacy_tip,
                  text: "Privacy Policy",
                  onTap: settingsController.openPrivacyPolicy,
                ),
                _buildTileButton(
                  icon: Icons.description,
                  text: "Terms & Conditions",
                  onTap: settingsController.openTermsAndConditions,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Danger Zone",
              children: [
                _buildTileButton(
                  icon: Icons.delete_forever,
                  text: "Delete All Diary Pages",
                  color: Colors.redAccent,
                  onTap: () async {
                    final confirmed = await Get.defaultDialog<bool>(
                          title: 'Confirm Delete',
                          middleText:
                              'Are you sure you want to delete all diary pages? This action cannot be undone.',
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          onConfirm: () => Get.back(result: true),
                          onCancel: () => Get.back(result: false),
                        ) ??
                        false;

                    if (confirmed) {
                      await settingsController.deleteAllDiaryPages();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: Colors.redAccent,
              ),
              onPressed: settingsController.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    final theme = Get.theme;

    final List<String> _cityList = _cityLocations.keys.toList();
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: DropdownSearch<String>(
          items: _cityList,
          selectedItem: selectedCity.value?.location,
          popupProps: const PopupProps.menu(showSearchBox: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: "Location",
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          onChanged: (value) async {
            if (value != null &&
                value.isNotEmpty &&
                _cityLocations.containsKey(value)) {
              final locationObj = _cityLocations[value]!;
              selectedCity.value = locationObj;
              await settingsController.updateLocation(locationObj);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Get.theme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required TextEditingController controller,
    required VoidCallback onSave,
  }) {
    final theme = Get.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
          suffixIcon: IconButton(
            icon: const Icon(Icons.check),
            onPressed: onSave,
            tooltip: 'Save',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTileButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Get.theme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(
        text,
        style: TextStyle(
            color: color ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
