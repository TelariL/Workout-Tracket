import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../database/app_database.dart';
import '../repository/training_repository.dart';

import 'exercises_screen.dart';
import 'exercise_stats_screen.dart';

class TemplateDetailScreen extends StatefulWidget {
  final int templateId;
  final String templateName;

  const TemplateDetailScreen({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  @override
  State<TemplateDetailScreen> createState() =>
      _TemplateDetailScreenState();
}

class _TemplateDetailScreenState
    extends State<TemplateDetailScreen> {
  final db = AppDatabase.instance;

  late TrainingRepository repo;

  late String templateName;

  List<Map<String, dynamic>> exercisesWithNames = [];

  @override
  void initState() {
    super.initState();

    repo = TrainingRepository(db);

    templateName = widget.templateName;

    _load();
  }

  Future<void> _load() async {
    final templateExercises =
    await repo.getTemplateExercises(widget.templateId);

    final exList = await repo.getExercises();

    exercisesWithNames = templateExercises.map((te) {
      final exercise =
      exList.firstWhere((e) => e.id == te.exerciseId);

      return {
        "templateExercise": te,
        "exercise": exercise,
      };
    }).toList();

    setState(() {});
  }

  Future<void> _editTemplateName() async {
    final controller =
    TextEditingController(text: templateName);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Название шаблона",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Введите название",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName =
                    controller.text.trim();

                    if (newName.isEmpty) return;

                    await repo.updateTemplateName(
                      widget.templateId,
                      newName,
                    );

                    setState(() {
                      templateName = newName;
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF363636),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Сохранить",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editSet(TemplateSet set) async {

    final weightController =
    TextEditingController(text: set.weight?.toString());

    final repsController =
    TextEditingController(text: set.reps?.toString());

    final restController =
    TextEditingController(text: set.restSeconds?.toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Container(
                width: 40,
                height: 5,

                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Редактировать подход",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(
                  hintText: "Вес (кг)",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(
                  hintText: "Повторения",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: restController,
                keyboardType: TextInputType.number,

                decoration: InputDecoration(
                  hintText: "Отдых (сек)",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: () async {

                    final weight =
                    double.tryParse(weightController.text);

                    final reps =
                    int.tryParse(repsController.text);

                    final rest =
                    int.tryParse(restController.text);

                    await repo.updateTemplateSet(
                      id: set.id,
                      weight: weight,
                      reps: reps,
                      rest: rest,
                    );

                    Navigator.pop(context);

                    _load();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF363636),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: Text(
                    "Сохранить подход",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _setItem(
      TemplateSet s, {
        bool isLast = false,
      }) {
    return Dismissible(
      key: ValueKey("template_set_${s.id}"),

      direction: DismissDirection.horizontal,

      confirmDismiss: (direction) async {

        // КОПИРОВАНИЕ
        if (direction == DismissDirection.startToEnd) {

          final sets = await repo.getTemplateSets(
            s.templateExerciseId,
          );

          await repo.addTemplateSet(
            templateExerciseId: s.templateExerciseId,
            order: sets.length + 1,
            weight: s.weight,
            reps: s.reps,
            rest: s.restSeconds,
          );

          _load();

          return false;
        }

        // УДАЛЕНИЕ
        if (direction == DismissDirection.endToStart) {

          await repo.deleteTemplateSet(s.id);

          _load();

          return true;
        }

        return false;
      },

      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: Colors.blue,

        child: const Icon(
          Icons.copy,
          color: Colors.white,
        ),
      ),

      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,

        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      child: Container(
        color: const Color(0xFFF0F0F0),

        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 16,
                right: 16,
              ),

              child: GestureDetector(
                onTap: () => _editSet(s),

                child: Row(
                  children: [

                    const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: Text(
                        s.reps?.toString() ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF363636),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      flex: 2,
                      child: Text(
                        s.weight?.toString() ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF363636),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Text(
                        s.restSeconds?.toString() ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF363636),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Divider(
                  height: 0,
                  thickness: 1,
                  color: const Color(0xFFC8C8C8),
                ),
              ),

            if (isLast)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSetDialog(
      int templateExerciseId) async {
    final weightController = TextEditingController();

    final repsController = TextEditingController();

    final restController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Новый подход",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Вес (кг)",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Повторения",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: restController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Отдых (сек)",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final weight = double.tryParse(
                        weightController.text);

                    final reps = int.tryParse(
                        repsController.text);

                    final rest = int.tryParse(
                        restController.text);

                    final existingSets =
                    await repo.getTemplateSets(
                      templateExerciseId,
                    );

                    final sequence =
                        existingSets.length + 1;

                    await repo.addTemplateSet(
                      templateExerciseId:
                      templateExerciseId,
                      order: sequence,
                      weight: weight,
                      reps: reps,
                      rest: rest,
                    );

                    Navigator.pop(context);

                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF363636),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Добавить подход",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme:
        const IconThemeData(color: Colors.black),

        title: GestureDetector(
          onTap: _editTemplateName,
          child: Text(
            templateName,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: exercisesWithNames.isEmpty
                ? Center(
              child: Text(
                "Нет упражнений",
                style: GoogleFonts.inter(
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              itemCount: exercisesWithNames.length,
              itemBuilder: (context, index) {
                final exMap =
                exercisesWithNames[index];

                return _exerciseCard(
                  exMap["templateExercise"],
                  exMap["exercise"],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: 317,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final exercise =
                  await showCupertinoModalBottomSheet(
                    context: context,
                    expand: false,
                    backgroundColor: Colors.white,
                    topRadius:
                    const Radius.circular(16),
                    builder: (_) =>
                    const ExercisesScreen(),
                  );

                  if (exercise != null) {
                    await repo.addExerciseToTemplate(
                      templateId: widget.templateId,
                      exerciseId: exercise.id,
                      order:
                      exercisesWithNames.length,
                    );

                    _load();
                  }
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor:
                  MaterialStateProperty.all(Colors.white),

                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: Color(0xFF363636),
                      width: 1,
                    ),
                  ),
                ),
                child: Text(
                  "Добавить упражнение",
                  style: GoogleFonts.inter(
                    color:
                    const Color(0xFF363636),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _exerciseCard(
      TemplateExercise ex,
      Exercise exercise,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Dismissible(
          key: ValueKey("template_exercise_${ex.id}"),
          direction: DismissDirection.endToStart,

          confirmDismiss: (direction) async {
            await repo.deleteTemplateExercise(ex.id);

            await _load();

            return true;
          },

          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),

          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          child: GestureDetector(

            child: FutureBuilder<List<TemplateSet>>(
              future: repo.getTemplateSets(ex.id),

              builder: (context, snapshot) {
                final sets = snapshot.data ?? [];

                return Container(
                  color: const Color(0xFFF0F0F0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Padding(
                        padding: const EdgeInsets.all(16),

                        child: Row(
                          children: [

                            Expanded(
                              child: Text(
                                exercise.name,

                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () => _showAddSetDialog(ex.id),

                              child: Container(
                                width: 32,
                                height: 32,

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius:
                                  BorderRadius.circular(10),

                                  border: Border.all(
                                    color: const Color(0xFF363636),
                                  ),
                                ),

                                child: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Color(0xFF363636),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (sets.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: _tableHeader(),
                        ),

                        const SizedBox(height: 8),
                      ],

                      ...sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;

                        return _setItem(
                          set,
                          isLast: index == sets.length - 1,
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),

      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              "Повторения",

              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF878787),
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            flex: 2,
            child: Text(
              "Вес (кг)",

              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF878787),
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              "Отдых (сек)",

              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF878787),
              ),
            ),
          ),
        ],
      ),
    );
  }
}