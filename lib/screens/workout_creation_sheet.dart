import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../database/app_database.dart';
import '../repository/training_repository.dart';
import 'workout_detail_screen.dart';

class WorkoutCreationSheet extends StatefulWidget {
  const WorkoutCreationSheet({super.key});

  @override
  State<WorkoutCreationSheet> createState() =>
      _WorkoutCreationSheetState();
}

class _WorkoutCreationSheetState
    extends State<WorkoutCreationSheet> {

  final repo = TrainingRepository(
    AppDatabase.instance,
  );

  List<Template> templates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    templates = await repo.getTemplates();
    setState(() {});
  }

  Future<void> _createEmptyWorkout() async {
    final workoutId =
    await repo.createWorkout(
      name: "Новая тренировка",
      date: DateTime.now(),
    );

    final workout =
    await repo.getWorkoutById(
      workoutId,
    );

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.of(context).push(
      MaterialWithModalsPageRoute(
        builder: (_) =>
            WorkoutDetailScreen(
              workout: workout,
            ),
      ),
    );
  }

  Future<void> _createFromTemplate(
      Template template,
      ) async {

    final workout =
    await repo.createWorkoutFromTemplate(
      template,
    );

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.of(context).push(
      MaterialWithModalsPageRoute(
        builder: (_) =>
            WorkoutDetailScreen(
              workout: workout,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight =
        MediaQuery.of(context).size.height;

    // Высота одной карточки шаблона
    const itemHeight = 72.0;

    // Базовая высота (кнопка + заголовок + отступы)
    const baseHeight = 250.0;

    // Рассчитываем нужную высоту
    final calculatedHeight =
        baseHeight +
            (templates.length * itemHeight);

    // Максимум 80% экрана
    final sheetHeight =
    calculatedHeight.clamp(
      320.0,
      screenHeight * 0.8,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20,
        ),
        child: SizedBox(
          height: sheetHeight.toDouble(),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _createEmptyWorkout,
                  style:
                  ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    const Color(0xFF363636),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: Text(
                    "Новая тренировка",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                "Шаблоны",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: templates.isEmpty
                    ? Center(
                  child: Text(
                    "Нет шаблонов",
                    style:
                    GoogleFonts.inter(
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding:
                  EdgeInsets.zero,
                  itemCount:
                  templates.length,
                  itemBuilder:
                      (context, index) {

                    final template =
                    templates[index];

                    return GestureDetector(
                      onTap: () =>
                          _createFromTemplate(
                            template,
                          ),
                      child: Container(
                        height: 60,
                        margin:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFF0F0F0,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            15,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style:
                                GoogleFonts.inter(
                                  fontSize:
                                  16,
                                  fontWeight:
                                  FontWeight
                                      .w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons
                                  .chevron_right,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}