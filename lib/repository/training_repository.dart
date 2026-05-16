import '../database/app_database.dart';
import 'package:drift/drift.dart';

class TrainingRepository {
  final AppDatabase db;

  TrainingRepository(this.db);


  ///=========== Templates =============
  ///
  Future<int> createTemplate({
    required String name,
  }) async {
    return await db.into(db.templates).insert(
      TemplatesCompanion.insert(
        name: name,
      ),
    );
  }

  Future<List<Template>> getTemplates() async {
    return await db.select(db.templates).get();
  }

  Future<void> deleteTemplate(int id) async {
    await (db.delete(db.templates)
      ..where((t) => t.id.equals(id)))
        .go();
  }

// получить упражнения шаблона
  Future<List<TemplateExercise>> getTemplateExercises(
      int templateId,
      ) {
    return (db.select(db.templateExercises)
      ..where((t) => t.templateId.equals(templateId))
      ..orderBy([
            (t) => OrderingTerm(expression: t.order),
      ]))
        .get();
  }

// добавить упражнение в шаблон
  Future<int> addExerciseToTemplate({
    required int templateId,
    required int exerciseId,
    required int order,
  }) {
    return db.into(db.templateExercises).insert(
      TemplateExercisesCompanion.insert(
        templateId: templateId,
        exerciseId: exerciseId,
        order: order,
      ),
    );
  }

// удалить упражнение из шаблона
  Future<void> deleteTemplateExercise(int id) async {
    await (db.delete(db.templateExercises)
      ..where((t) => t.id.equals(id)))
        .go();
  }

// обновить название шаблона
  Future<void> updateTemplateName(
      int templateId,
      String name,
      ) async {
    await (db.update(db.templates)
      ..where((t) => t.id.equals(templateId)))
        .write(
      TemplatesCompanion(
        name: Value(name),
      ),
    );
  }

// получить подходы
  Future<List<TemplateSet>> getTemplateSets(
      int templateExerciseId,
      ) {
    return (db.select(db.templateSets)
      ..where((s) => s.templateExerciseId.equals(templateExerciseId))
      ..orderBy([
            (s) => OrderingTerm(expression: s.order),
      ]))
        .get();
  }

// добавить подход
  Future<int> addTemplateSet({
    required int templateExerciseId,
    required int order,
    double? weight,
    int? reps,
    int? rest,
  }) {
    return db.into(db.templateSets).insert(
      TemplateSetsCompanion.insert(
        templateExerciseId: templateExerciseId,
        order: order,
        weight: Value(weight),
        reps: Value(reps),
        restSeconds: Value(rest),
      ),
    );
  }

// удалить подход
  Future<void> deleteTemplateSet(int id) async {
    await (db.delete(db.templateSets)
      ..where((s) => s.id.equals(id)))
        .go();
  }

// обновить подход
  Future<void> updateTemplateSet({
    required int id,
    double? weight,
    int? reps,
    int? rest,
  }) async {
    await (db.update(db.templateSets)
      ..where((s) => s.id.equals(id)))
        .write(
      TemplateSetsCompanion(
        weight: Value(weight),
        reps: Value(reps),
        restSeconds: Value(rest),
      ),
    );
  }

  Future<void> copyTemplateSet(TemplateSet set) async {

    final sets = await getTemplateSets(
      set.templateExerciseId,
    );

    await addTemplateSet(
      templateExerciseId: set.templateExerciseId,
      order: sets.length + 1,
      weight: set.weight,
      reps: set.reps,
      rest: set.restSeconds,
    );
  }

  

  /// ================= WORKOUT =================


  Future<Workout> createWorkoutFromTemplate(
      Template template,
      ) async {

    final workoutId =
    await createWorkout(
      name: template.name,
      date: DateTime.now(),
    );

    final templateExercises =
    await getTemplateExercises(
      template.id,
    );

    for (final te
    in templateExercises) {

      await addExerciseToWorkout(
        workoutId: workoutId,
        exerciseId: te.exerciseId,
        order: te.order,
      );

      final workoutExercises =
      await getWorkoutExercises(
        workoutId,
      );

      final createdExercise =
          workoutExercises.last;

      final templateSets =
      await getTemplateSets(
        te.id,
      );

      for (final set
      in templateSets) {

        await addSet(
          workoutExerciseId:
          createdExercise.id,

          order: set.order,
          weight: set.weight,
          reps: set.reps,
          rest: set.restSeconds,
        );
      }
    }

    return getWorkoutById(
      workoutId,
    );
  }


  Future<void> updateWorkoutDate(
      int workoutId,
      DateTime date,
      ) async {
    await db.updateWorkoutDate(workoutId, date);
  }

  Stream<int> watchWorkoutsCountForMonth(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 1);

    return (db.select(db.workouts)
      ..where((w) =>
      w.date.isBiggerOrEqualValue(start) &
      w.date.isSmallerThanValue(end)))
        .watch()
        .map((rows) => rows.length);
  }

  Future<int> createWorkout({
    required String name,
    String? notes,
    required DateTime date,
  }) async {
    return await db.insertWorkout(
      WorkoutsCompanion(
        name: Value(name),
        notes: Value(notes),
        date: Value(date),
      ),
    );
  }

  Future<List<Workout>> getWorkouts() {
    return db.getWorkouts();
  }

  Future deleteWorkout(int id) {
    return db.deleteWorkout(id);
  }

  Future<void> updateWorkoutName(int id, String name) async {
    await (db.update(db.workouts)
      ..where((tbl) => tbl.id.equals(id)))
        .write(
      WorkoutsCompanion(
        name: Value(name),
      ),
    );
  }

  Future<Workout> getWorkoutById(int id) async {
    return await (db.select(db.workouts)
      ..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// ================= EXERCISE =================

  Future<int> createExercise({
    required String name,
    String? description,
  }) async {
    return db.insertExercise(
      ExercisesCompanion(
        name: Value(name),
        description: Value(description),
      ),
    );
  }

  Future deleteExercise(int id) {
    return db.deleteExercise(id);
  }

  Future<List<Exercise>> getExercises() {
    return db.getExercises();
  }

  Future<List<WorkoutSet>> getAllSetsForExercise(int exerciseId) async {
    final result = await (db.select(db.workoutSets).join([
      innerJoin(
        db.workoutExercises,
        db.workoutExercises.id.equalsExp(db.workoutSets.workoutExerciseId),
      )
    ])
      ..where(db.workoutExercises.exerciseId.equals(exerciseId)))
        .get();

    return result.map((row) => row.readTable(db.workoutSets)).toList();
  }

  Future<List<Map<String, dynamic>>> getExerciseStats(int exerciseId) async {
    final rows = await (db.select(db.workoutSets).join([
      innerJoin(
        db.workoutExercises,
        db.workoutExercises.id.equalsExp(db.workoutSets.workoutExerciseId),
      ),
      innerJoin(
        db.workouts,
        db.workouts.id.equalsExp(db.workoutExercises.workoutId),
      ),
    ])
      ..where(db.workoutExercises.exerciseId.equals(exerciseId)))
        .get();

    final Map<DateTime, List<WorkoutSet>> grouped = {};

    for (final row in rows) {
      final set = row.readTable(db.workoutSets);
      final workout = row.readTable(db.workouts);

      final date = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      grouped.putIfAbsent(date, () => []).add(set);
    }

    final result = grouped.entries.map((entry) {
      final sets = entry.value;

      double totalVolume = 0;
      double totalReps = 0;

      for (final s in sets) {
        final w = s.weight ?? 0;
        final r = s.reps ?? 0;

        totalVolume += w * r;
        totalReps += r;
      }

      final avgWeight = totalReps == 0 ? 0 : totalVolume / totalReps;

      return {
        "date": entry.key,
        "volume": totalVolume,
        "avgWeight": avgWeight,
      };
    }).toList();

    result.sort((a, b) =>
        (a["date"] as DateTime).compareTo(b["date"] as DateTime));

    return result;
  }

  /// ============ ADD EXERCISE TO WORKOUT ============

  Future addExerciseToWorkout({
    required int workoutId,
    required int exerciseId,
    required int order,
  }) async {
    await db.insertWorkoutExercise(
      WorkoutExercisesCompanion(
        workoutId: Value(workoutId),
        exerciseId: Value(exerciseId),
        order: Value(order),
      ),
    );
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) {
    return db.getWorkoutExercises(workoutId);
  }

  /// ================= SET =================

  Future addSet({
    required int workoutExerciseId,
    required int order,
    double? weight,
    int? reps,
    int? rest,
  }) async {
    await db.insertSet(
      WorkoutSetsCompanion(
        workoutExerciseId: Value(workoutExerciseId),
        sequence: Value(order),
        weight: Value(weight),
        reps: Value(reps),
        restSeconds: Value(rest),
      ),
    );
  }

  /// ==================== UDC SET ===========
  Future deleteWorkoutExercise(int id) async {
    await db.deleteWorkoutExercise(id);
  }

  Future deleteSet(int id) async {
    await db.deleteSet(id);
  }

  Future copySet(WorkoutSet set) async {
    await db.insertSet(
      WorkoutSetsCompanion(
        workoutExerciseId: Value(set.workoutExerciseId),
        sequence: Value(set.sequence + 1),
        weight: Value(set.weight),
        reps: Value(set.reps),
        restSeconds: Value(set.restSeconds),
      ),
    );
  }

  Future updateSet({
    required int id,
    double? weight,
    int? reps,
    int? rest,
  }) async {
    await db.updateSet(
      id: id,
      weight: weight,
      reps: reps,
      rest: rest,
    );
  }

  Future<List<WorkoutSet>> getSets(int workoutExerciseId) {
    return db.getSets(workoutExerciseId);
  }
}