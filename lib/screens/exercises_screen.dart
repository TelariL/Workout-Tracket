import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/app_database.dart';
import '../repository/training_repository.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final db = AppDatabase.instance;
  late TrainingRepository repo;

  List<Exercise> exercises = [];

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository(db);
    _load();
  }

  Future<void> _load() async {
    final data = await repo.getExercises();
    setState(() => exercises = data);
  }

  // ================= CREATE =================

  Future<void> _showCreateExerciseSheet() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
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
                "Новое упражнение",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Название упражнения",
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
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Описание упражнения",
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
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final description = descriptionController.text.trim();

                    if (name.isEmpty) return;

                    await repo.createExercise(
                      name: name,
                      description: description,
                    );

                    Navigator.pop(sheetContext);

                    _load(); // 🔥 обновление списка
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF363636),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Создать',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
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

  // ================= UI =================

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
              "Выберите упражнение",
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
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Dismissible(
                        key: ValueKey("exercise_${ex.id}"),
                        direction: DismissDirection.endToStart,

                        background: Container(),

                        secondaryBackground: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),

                        // 🔥 ВАЖНО
                        confirmDismiss: (_) async {
                          await repo.deleteExercise(ex.id);
                          _load();
                          return true;
                        },

                        child: InkWell(
                          onTap: () => Navigator.pop(context, ex),

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
                                style: GoogleFonts.inter(
                                    color: Colors.grey),
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showCreateExerciseSheet,
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor:
                    MaterialStateProperty.all(Colors.white),
                    side: MaterialStateProperty.all(
                      const BorderSide(color: Color(0xFF363636)),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Text(
                    "Создать упражнение",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF363636),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}