import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exercises_screen.dart';
import '../database/app_database.dart';
import '../repository/training_repository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'exercise_stats_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final db = AppDatabase.instance;
  late Workout workout;
  late TrainingRepository repo;

  List<Map<String, dynamic>> exercisesWithNames = [];

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository(db);
    workout = widget.workout;
    _load();
  }

  Future<void> _load() async {
    final workoutExercises = await repo.getWorkoutExercises(workout.id);

    final exList = await repo.getExercises();

    exercisesWithNames = workoutExercises.map((we) {
      final exercise = exList.firstWhere((e) => e.id == we.exerciseId);
      return {
        "workoutExercise": we,
        "exercise": exercise,
      };
    }).toList();

    setState(() {});
  }

  Future<void> _loadWorkout() async {
    final updated = await repo.getWorkoutById(workout.id);

    setState(() {
      workout = updated;
    });
  }

  Workout copyWorkout({
    int? id,
    String? name,
    DateTime? date,
  }) {
    return Workout(
      id: id ?? workout.id,
      name: name ?? workout.name,
      date: date ?? workout.date,
    );
  }

  Future<void> _editWorkoutDate() async {
    DateTime tempDate = workout.date;

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          height: 370,
          color: Colors.white,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  child: Text(
                    "Готово",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF363636),
                    ),
                  ),
                  onPressed: () async {
                    await repo.updateWorkoutDate(
                      workout.id,
                      tempDate,
                    );

                    if (!mounted) return;

                    Navigator.of(ctx).pop();

                    await _loadWorkout();
                  },
                ),
              ),

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: workout.date,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
              SizedBox(height: 50,)
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      "января", "февраля", "марта", "апреля", "мая", "июня",
      "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _showAddSetDialog(int workoutExerciseId) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final restController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
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

              Text("Новый подход", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500)),
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
                    final weight = double.tryParse(weightController.text);
                    final reps = int.tryParse(repsController.text);
                    final rest = int.tryParse(restController.text);

                    final existingSets = await repo.getSets(workoutExerciseId);
                    final sequence = existingSets.length + 1;

                    await repo.addSet(
                      workoutExerciseId: workoutExerciseId,
                      order: sequence,
                      weight: weight,
                      reps: reps,
                      rest: rest,
                    );
                    Navigator.pop(context);
                    _load();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF363636)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  child: Text("Добавить подход", style: GoogleFonts.inter(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 0),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editWorkoutName() async {
    final controller = TextEditingController(text: workout.name);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                "Название тренировки",
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
                    final newName = controller.text.trim();

                    if (newName.isEmpty) return;

                    await repo.updateWorkoutName(workout.id, newName);

                    if (!mounted) return;

                    Navigator.pop(context);

                    await _loadWorkout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF363636),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),

        title: GestureDetector(
          onTap: _editWorkoutName,
          child: Text(
            workout.name,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
            child: GestureDetector(
              onTap: _editWorkoutDate,
              child: Text(
                _formatDate(workout.date),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF878787),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: exercisesWithNames.isEmpty
                ? Center(child: Text("Нет упражнений", style: GoogleFonts.inter(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: exercisesWithNames.length,
              itemBuilder: (context, index) {
                final exMap = exercisesWithNames[index];
                return _exerciseCard(exMap["workoutExercise"], exMap["exercise"]);
              },
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 317,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  final exercise = await showCupertinoModalBottomSheet(
                    context: context,
                    expand: false,
                    backgroundColor: Colors.white,
                    topRadius: const Radius.circular(16),
                    builder: (_) => ExercisesScreen(),
                  );

                  if (exercise != null) {
                    await repo.addExerciseToWorkout(
                      workoutId: widget.workout.id,
                      exerciseId: exercise.id,
                      order: exercisesWithNames.length,
                    );
                    _load();
                  }
                },
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  side: MaterialStateProperty.all(const BorderSide(color: Color(0xFF363636), width: 1)),
                ),
                child: Text(
                  "Добавить упражнение",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF363636)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),

    );
  }

  Widget _exerciseCard(WorkoutExercise ex, Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Dismissible(
          key: ValueKey("exercise_${ex.id}"),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            await repo.deleteWorkoutExercise(ex.id);
            await _load();
            return true;
          },
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseStatsScreen(
                    exercise: exercise
                  ),
                ),
              );
            },
            child: FutureBuilder<List<WorkoutSet>>(
              future: repo.getSets(ex.id),
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
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xFF363636)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _tableHeader(),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ...sets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final set = entry.value;
                        return _setItem(set, isLast: index == sets.length - 1);
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
          SizedBox(width: 20,),
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

  Widget _setItem(WorkoutSet s, {bool isLast = false}) {
    return Dismissible(
      key: ValueKey("set_${s.id}"),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await repo.copySet(s);
          _load();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          await repo.deleteSet(s.id);
          _load();
          return true;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: Colors.blue,
        child: const Icon(Icons.copy, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        color: const Color(0xFFF0F0F0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
              child: GestureDetector(
                onTap: () => _editSet(s),
                child: Row(
                  children: [
                    SizedBox(width: 10,),
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
                    SizedBox(width: 20,),
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
              Padding(
                  padding: const EdgeInsets.only(bottom: 4)
              )
          ],
        ),
      ),
    );
  }

  Future<void> _editSet(WorkoutSet set) async {
    final weightController = TextEditingController(text: set.weight?.toString());
    final repsController = TextEditingController(text: set.reps?.toString());
    final restController = TextEditingController(text: set.restSeconds?.toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

              // Полоска сверху
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              // Заголовок
              Text(
                "Редактировать подход",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Поля ввода
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

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final weight = double.tryParse(weightController.text);
                    final reps = int.tryParse(repsController.text);
                    final rest = int.tryParse(restController.text);

                    await repo.updateSet(
                      id: set.id,
                      weight: weight,
                      reps: reps,
                      rest: rest,
                    );

                    Navigator.pop(context);
                    _load();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF363636)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Text(
                    "Сохранить подход",
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}