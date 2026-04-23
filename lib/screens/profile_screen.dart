import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_tracker/screens/exercises_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                "Профиль",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "моя статистика",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  SizedBox(
                    width: 180,
                    height: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_drop_up, color: Color(0xFF34C759), size: 30),
                                Text(
                                  "Масса тела",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF878787),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 52),
                            child:Text(
                              "79.00 кг",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 180,
                    height: 110,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              "Тренировок за месяц",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF878787),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child:Text(
                              "10",
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "мои цели",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _goalCard("Масса тела", "85.00 кг"),
                  const SizedBox(width: 10),
                  _goalCard("Жим лежа", "100кг"),
                ],
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "мои достижения",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF878787),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _buildAchievementsBlock(context),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _goalCard(String title, String value) {
    return SizedBox(
      width: 180,
      height: 110,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF878787),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsBlock(BuildContext context) {
    return Container(
      height: 147,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _menuItem(
            context: context,
            icon: Image.asset('assets/icons/exercises_icon.png', width: 26),
            text: "Упражнения",
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),
                builder: (context) => const ExercisesScreen(),
              );
            },
          ),
          _divider(),
          _menuItem(
            context: context,
            icon: Image.asset('assets/icons/pattern_icon.png', width: 26),
            text: "Шаблоны",
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),
                builder: (context) => const ExercisesScreen(),
              );
            },
          ),
          _divider(),
          _menuItem(
            context: context,
            icon: Image.asset('assets/icons/metering_icon.png', width: 26),
            text: "Измерения тела",
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),
                builder: (context) => const ExercisesScreen(),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _menuItem({
    required BuildContext context,
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
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

  static Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 55),
      child: Divider(
        thickness: 1,
        height: 0,
        color: Color(0xFF878787),
      ),
    );
  }
}
