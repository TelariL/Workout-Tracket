import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/app_database.dart';
import '../repository/training_repository.dart';
import 'exercise_stats_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {

  final db = AppDatabase.instance;
  late TrainingRepository repo;

  List<Exercise> exercises = [];

  Future<void> _load() async {
    exercises = await repo.getExercises();
    setState(() {});
    print("DB instance in screen: ${db.hashCode}");
  }

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository(db);
    _load();
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
                "Упражнения",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: exercises.isEmpty
                    ? Center(
                  child: Text(
                    "Нет упражнений",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Dismissible(
                          key: ValueKey(ex.id),
                          direction: DismissDirection.endToStart,
                          background: Container(),
                          secondaryBackground: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            await repo.deleteExercise(ex.id);
                            return true;
                          },
                          onDismissed: (_) {
                            setState(() {
                              exercises.removeAt(index);
                            });
                          },
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExerciseStatsScreen(exercise: ex),
                                ),
                              );
                            },
                            child: Container(
                              color: const Color(0xFFF0F0F0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  ex.name,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: ex.description != null &&
                                    ex.description!.isNotEmpty
                                    ? Text(
                                  ex.description!,
                                  style: GoogleFonts.inter(color: Colors.grey),
                                )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }