import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_tracker/screens/exercises_profile_screen.dart';
import '../repository/training_repository.dart';
import '../database/app_database.dart';
import 'body_metrics_screen.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'goals_screen.dart';
import 'templates_screen.dart';

class ProfileScreen extends StatefulWidget {

  final VoidCallback? onRefreshNeeded;

  const ProfileScreen({
    super.key,
    this.onRefreshNeeded,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final repo = TrainingRepository(AppDatabase.instance);

  double? currentWeight;
  double? previousWeight;

  String weightGoalType = "gain";

  double? targetWeight;
  double? targetBench;
  double? targetSquat;
  double? targetDeadlift;

  String profileGoal = "bench";

  late StreamSubscription<int> _sub;
  int workoutsThisMonth = 0;
  late final Stream<int> workoutsStream;

  Future<void> refreshProfile() async {

    await _loadGoals();
    await _loadCurrentWeight();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();


    workoutsStream =
        repo.watchWorkoutsCountForMonth(DateTime.now());

    _sub = workoutsStream.listen((count) {
      setState(() {
        workoutsThisMonth = count;
      });
    });

    _loadCurrentWeight();
    _loadGoals();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {

    if (state == AppLifecycleState.resumed) {

      _loadGoals();
      _loadCurrentWeight();
    }
  }

  @override
  void dispose() {

    _sub.cancel();

    super.dispose();
  }

  Future<void> _loadGoals() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      targetWeight =
          prefs.getDouble("targetWeight");

      targetBench =
          prefs.getDouble("targetBench");

      targetSquat =
          prefs.getDouble("targetSquat");

      targetDeadlift =
          prefs.getDouble("targetDeadlift");

      profileGoal =
          prefs.getString("profileGoal") ?? "bench";

      weightGoalType =
          prefs.getString("weightGoalType") ?? "gain";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadGoals();
    _loadCurrentWeight();
  }

  Future<void> _loadCurrentWeight() async {

    final db = AppDatabase.instance;

    final metric = await (db.select(db.bodyMetrics)
      ..where((t) => t.name.equals("Масса тела")))
        .getSingleOrNull();

    if (metric == null) return;

    final entries = await (db.select(db.bodyMetricEntries)
      ..where((t) => t.metricId.equals(metric.id))
      ..orderBy([
            (t) => OrderingTerm(
          expression: t.date,
          mode: OrderingMode.desc,
        )
      ])
      ..limit(2))
        .get();

    if (entries.isEmpty) return;

    setState(() {

      currentWeight = entries.first.value;

      if (entries.length > 1) {
        previousWeight = entries[1].value;
      }
    });
  }

  bool get _isWeightProgressGood {

    if (currentWeight == null ||
        previousWeight == null) {
      return true;
    }

    if (weightGoalType == "gain") {
      return currentWeight! >= previousWeight!;
    }

    return currentWeight! <= previousWeight!;
  }

  Color get _weightTrendColor {

    return _isWeightProgressGood
        ? const Color(0xFF34C759)
        : Colors.red;
  }

  IconData get _weightTrendIcon {

    return _isWeightProgressGood
        ? Icons.arrow_drop_up
        : Icons.arrow_drop_down;
  }

  String _profileGoalTitle() {

    switch (profileGoal) {

      case "bench":
        return "Жим лёжа";

      case "squat":
        return "Присед";

      case "deadlift":
        return "Становая тяга";

      default:
        return "Цель";
    }
  }

  String _profileGoalValue() {

    switch (profileGoal) {

      case "bench":
        return targetBench == null
            ? "—"
            : "${targetBench!.toStringAsFixed(1)} кг";

      case "squat":
        return targetSquat == null
            ? "—"
            : "${targetSquat!.toStringAsFixed(1)} кг";

      case "deadlift":
        return targetDeadlift == null
            ? "—"
            : "${targetDeadlift!.toStringAsFixed(1)} кг";

      default:
        return "—";
    }
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

                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  Icon(
                                    _weightTrendIcon,
                                    color: _weightTrendColor,
                                    size: 28,
                                  ),

                                  const SizedBox(width: 0),

                                  Expanded(
                                    child: Text(
                                      "Масса тела",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF878787),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  SizedBox(width: 10,),
                                  Center(
                                    child: Text(
                                      currentWeight == null
                                          ? "—"
                                          : "${currentWeight!.toStringAsFixed(1)} кг",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                "Тренировок\nза месяц",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF878787),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                workoutsThisMonth.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
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

                  Expanded(
                    child: _goalCardWeight(
                      "Масса тела",
                      targetWeight == null
                          ? "—"
                          : "${targetWeight!.toStringAsFixed(1)} кг",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _goalCard(
                      _profileGoalTitle(),
                      _profileGoalValue(),
                    ),
                  ),
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

    return Container(
      height: 110,

      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Center(
        child: SizedBox(
          width: 120,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF878787),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _goalCardWeight(String title, String value) {

    return Container(
      height: 110,

      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Center(
        child: SizedBox(
          width: 100,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF878787),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsBlock(BuildContext context) {
    return Container(
      height: 196,
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

                // ВАЖНО
                useRootNavigator: false,

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

                // ВАЖНО
                useRootNavigator: false,

                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),

                builder: (_) => const TemplatesScreen(),
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

                // ВАЖНО
                useRootNavigator: false,

                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),

                builder: (context) => const BodyMetricsScreen(),
              );

              _loadCurrentWeight();
            },
          ),
          _divider(),
          _menuItem(
            context: context,
            icon: Image.asset('assets/icons/target.png', width: 26),
            text: "Цели",
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,

                // ВАЖНО
                useRootNavigator: false,

                expand: false,
                backgroundColor: Colors.white,
                topRadius: const Radius.circular(16),

                builder: (context) => const GoalsScreen(),
              );

              _loadGoals();
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
