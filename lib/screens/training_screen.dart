import '../database/app_database.dart';
import '../repository/training_repository.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:collection';
import 'create_workout_sheet.dart';
import 'workout_detail_screen.dart';


class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {

  final db = AppDatabase.instance;
  late final TrainingRepository repo;
  List<Workout> _trainings = [];

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository(db);
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    final data = await repo.getWorkouts();
    setState(() => _trainings = data);
  }

  String _formatDate(DateTime date) {
    final months = [
      "января","февраля","марта","апреля","мая","июня",
      "июля","августа","сентября","октября","ноября","декабря"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  LinkedHashMap<String, List<Workout>> _groupTrainings() {
    _trainings.sort((a, b) => b.date.compareTo(a.date));

    final grouped = LinkedHashMap<String, List<Workout>>();

    for (var t in _trainings) {
      final key =
          "${_getMonthName(t.date.month).toUpperCase()} ${t.date.year}";

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }

    return grouped;
  }

  String _getMonthName(int month) {
    const names = [
      "январь","февраль","март","апрель","май","июнь",
      "июль","август","сентябрь","октябрь","ноябрь","декабрь"
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupTrainings();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Тренировки",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final entry in grouped.entries) ...[
                    _monthTitle(entry.key),
                    _trainingCard(entry.value),
                    const SizedBox(height: 20),
                  ]
                ],
              ),
            ),

            Center(
              child: SizedBox(
                width: 317,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await showModalBottomSheet<Map>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CreateWorkoutSheet(),
                    );

                    if (result != null && result.isNotEmpty) {
                      await repo.createWorkout(
                        name: result["name"],
                        date: result["date"],
                      );

                      _loadTrainings();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Color(0xFF363636)),
                    ),
                  ),
                  child: Text(
                    "Добавить тренировку",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF363636),
                    ),
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

  Widget _monthTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF878787),
        ),
      ),
    );
  }

  Widget _trainingCard(List<Workout> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _trainingItem(items[i], i, items.length),
            if (i != items.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Divider(
                  thickness: 1,
                  height: 0,
                  color: Color(0xFF878787),
                ),
              ),
          ]
        ],
      ),
    );
  }

  Widget _trainingItem(Workout t, int index, int total) {
    final isFirst = index == 0;
    final isLast = index == total - 1;

    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(15) : Radius.zero,
      bottom: isLast ? const Radius.circular(15) : Radius.zero,
    );

    return ClipRRect(
      borderRadius: radius,
      child: Dismissible(
        key: ValueKey(t.id),
        direction: DismissDirection.endToStart,
        background: Container(),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) async {
          await repo.deleteWorkout(t.id);
          _loadTrainings();
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutDetailScreen(workout: t),
              ),
            );
          },
          child: Container(
            color: const Color(0xFFF0F0F0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    t.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF363636),
                    ),
                  ),
                ),
                Text(
                  _formatDate(t.date),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF878787),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right,
                    size: 24, color: Color(0xFF878787)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
