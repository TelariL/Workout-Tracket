import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {

  final weightController = TextEditingController();
  final benchController = TextEditingController();
  final squatController = TextEditingController();
  final deadliftController = TextEditingController();

  String selectedGoal = "bench";
  String selectedWeightGoalType = "gain";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {

      weightController.text =
          prefs.getDouble("targetWeight")?.toString() ?? "";

      benchController.text =
          prefs.getDouble("targetBench")?.toString() ?? "";

      squatController.text =
          prefs.getDouble("targetSquat")?.toString() ?? "";

      deadliftController.text =
          prefs.getDouble("targetDeadlift")?.toString() ?? "";

      selectedGoal =
          prefs.getString("profileGoal") ?? "bench";

      selectedWeightGoalType =
          prefs.getString("weightGoalType") ?? "gain";
    });
  }

  Future<void> _save() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(
      "targetWeight",
      double.tryParse(weightController.text) ?? 0,
    );

    await prefs.setDouble(
      "targetBench",
      double.tryParse(benchController.text) ?? 0,
    );

    await prefs.setDouble(
      "targetSquat",
      double.tryParse(squatController.text) ?? 0,
    );

    await prefs.setDouble(
      "targetDeadlift",
      double.tryParse(deadliftController.text) ?? 0,
    );

    await prefs.setString(
      "profileGoal",
      selectedGoal,
    );

    await prefs.setString(
      "weightGoalType",
      selectedWeightGoalType,
    );

    Navigator.pop(context, true);
  }

  Widget _field({
    required String title,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.only(left: 4),

            child: Text(
              title,

              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF878787),
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,

            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),

            decoration: InputDecoration(
              hintText: "Введите значение",

              filled: true,
              fillColor: const Color(0xFFF0F0F0),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selector({
    required String title,
    required String value,
    required String selected,
    required VoidCallback onTap,
  }) {

    final isSelected = value == selected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: isSelected
                ? const Color(0xFF363636)
                : Colors.transparent,
            width: 1.5,
          ),
        ),

        child: Row(
          children: [

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (isSelected)
              const Icon(Icons.check),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.white,

      child: SafeArea(
        top: false,

        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),

              child: Center(
                child: Container(
                  width: 40,
                  height: 5,

                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Мои цели",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  children: [

                    _field(
                      title: "Желаемый вес",
                      controller: weightController,
                    ),

                    _field(
                      title: "Жим лёжа",
                      controller: benchController,
                    ),

                    _field(
                      title: "Присед",
                      controller: squatController,
                    ),

                    _field(
                      title: "Становая тяга",
                      controller: deadliftController,
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Цель веса",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _selector(
                      title: "Набор массы",
                      value: "gain",
                      selected: selectedWeightGoalType,
                      onTap: () {
                        setState(() {
                          selectedWeightGoalType = "gain";
                        });
                      },
                    ),

                    _selector(
                      title: "Похудение",
                      value: "lose",
                      selected: selectedWeightGoalType,
                      onTap: () {
                        setState(() {
                          selectedWeightGoalType = "lose";
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Показывать в профиле",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _selector(
                      title: "Жим лёжа",
                      value: "bench",
                      selected: selectedGoal,
                      onTap: () {
                        setState(() {
                          selectedGoal = "bench";
                        });
                      },
                    ),

                    _selector(
                      title: "Присед",
                      value: "squat",
                      selected: selectedGoal,
                      onTap: () {
                        setState(() {
                          selectedGoal = "squat";
                        });
                      },
                    ),

                    _selector(
                      title: "Становая тяга",
                      value: "deadlift",
                      selected: selectedGoal,
                      onTap: () {
                        setState(() {
                          selectedGoal = "deadlift";
                        });
                      },
                    ),
                  ],
                ),

              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 317,
              height: 60,

              child: ElevatedButton(
                onPressed: _save,

                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF363636),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                child: Text(
                  "Сохранить",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}