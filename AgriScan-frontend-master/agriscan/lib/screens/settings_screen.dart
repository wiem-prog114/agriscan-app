import 'package:flutter/material.dart';
import 'sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';

  final List<String> languages = ['English', 'Français', 'العربية'];

  // Color Palette
  static const Color lightBackground = Color(0xFFE5E0D8);
  static const Color darkBackground = Color(0xFF4C6444);
  static const Color sageGreen = Color(0xFFACB087);
  static const Color darkGreen = Color(0xFF4C6444);
  static const Color midGreen = Color(0xFF809671);
  static const Color accentBrown = Color(0xFF95714F);
  static const Color fieldBackground = Color(0xFFEADED0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : lightBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? midGreen : sageGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? midGreen : sageGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: isDarkMode ? darkGreen : sageGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AgriScan User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user@agriscan.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Preferences Section
                  _buildSectionTitle('Preferences', isDarkMode),
                  const SizedBox(height: 12),
                  
                  // Dark Mode Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      subtitle: Text(
                        'Toggle dark theme',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                        ),
                      ),
                      value: isDarkMode,
                      activeColor: accentBrown,
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Notifications Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: SwitchListTile(
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      subtitle: Text(
                        'Receive push notifications',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                        ),
                      ),
                      value: notificationsEnabled,
                      activeColor: accentBrown,
                      secondary: Icon(
                        notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Language Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: ListTile(
                      leading: Icon(
                        Icons.language,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      title: Text(
                        'Language',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      subtitle: Text(
                        'Select app language',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDarkMode ? midGreen : fieldBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedLanguage,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDarkMode ? Colors.white : darkGreen,
                          ),
                          dropdownColor: isDarkMode ? midGreen : fieldBackground,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                          items: languages.map((lang) {
                            return DropdownMenuItem(
                              value: lang,
                              child: Text(lang),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedLanguage = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account Section
                  _buildSectionTitle('Account', isDarkMode),
                  const SizedBox(height: 12),
                  
                  // Account Settings Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      title: Text(
                        'Profile Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                      ),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Privacy Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: ListTile(
                      leading: Icon(
                        Icons.lock_outline,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      title: Text(
                        'Privacy & Security',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                      ),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Help & Support Card
                  _buildSettingCard(
                    isDarkMode: isDarkMode,
                    child: ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: isDarkMode ? Colors.white : sageGreen,
                      ),
                      title: Text(
                        'Help & Support',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : darkGreen,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.6),
                      ),
                      onTap: () {},
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBrown,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: accentBrown.withOpacity(0.5),
                        ),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
                      ),
                  
                  const SizedBox(height: 24),
                  
                  // Version Info
                  Text(
                    'AgriScan v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white60 : darkGreen.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : darkGreen,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required bool isDarkMode, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? midGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? midGreen : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : darkGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : darkGreen.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Close the dialog first
                Navigator.pop(context);

                // TODO: insert auth sign-out logic here if needed

                // Navigate to SignInScreen and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}