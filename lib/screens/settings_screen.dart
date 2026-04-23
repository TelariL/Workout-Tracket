import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_tracker/screens/welcome_screen.dart';
import 'login_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkTheme = false;
  bool notifications = false;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Настройки",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "ПОЛЕЗНАЯ ИНФОРМАЦИЯ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _usefulInformation(context),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "МОИ ДАННЫЕ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _myData(context),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "НАСТРОЙКА ПРИЛОЖЕНИЯ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _settings(context),

              const SizedBox(height: 40),

              Center(
                child: SizedBox(
                  width: 317,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      );
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      side: MaterialStateProperty.all(
                        const BorderSide(color: Color(0xFF363636), width: 1),
                      ),
                    ),
                    child: Text(
                      'Выйти из аккаунта',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF363636),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _usefulInformation(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _menuItem(
            context: context,
            text: "Что нового в этом обновлении?",
            onTap: () {},
          ),
          _divider(),
          _menuItem(
            context: context,
            text: "Служба поддержки",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _myData(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _menuItem(
            context: context,
            text: "Имя",
            onTap: () {},
          ),
          _divider(),
          _menuItem(
            context: context,
            text: "Мои цели",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _settings(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _switchItem(
            context: context,
            text: "Тема",
            value: isDarkTheme,
            onChanged: (val) {
              setState(() => isDarkTheme = val);
            },
          ),

          _divider(),

          _switchItem(
            context: context,
            text: "Уведомления",
            value: notifications,
            onChanged: (val) {
              setState(() => notifications = val);
            },
          ),
        ],
      ),
    );
  }

  static Widget _menuItem({
    required BuildContext context,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF363636),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 24, color: Color(0xFF878787)),
          ],
        ),
      ),
    );
  }

  Widget _switchItem({
    required BuildContext context,
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF363636),
              ),
            ),
          ),

          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }



  static Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 20),
      child: Divider(
        thickness: 1,
        height: 0,
        color: Color(0xFF878787),
      ),
    );
  }
}

