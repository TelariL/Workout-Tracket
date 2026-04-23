import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';



/// ================= WORKOUTS =================

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get date => dateTime()();
}

/// ================= EXERCISES =================

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();
}

/// ============ WORKOUT EXERCISES ==============

class WorkoutExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutId => integer()();

  IntColumn get exerciseId => integer()();

  IntColumn get order => integer()();
}

/// ================== SETS ====================

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutExerciseId => integer()();

  IntColumn get sequence => integer()();

  RealColumn get weight => real().nullable()();

  IntColumn get reps => integer().nullable()();

  IntColumn get restSeconds => integer().nullable()();
}

@DriftDatabase(
  tables: [
    Workouts,
    Exercises,
    WorkoutExercises,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;

  /// ================= WORKOUTS =================

  Future<List<Workout>> getWorkouts() =>
      select(workouts).get();

  Future<int> insertWorkout(WorkoutsCompanion entry) =>
      into(workouts).insert(entry);

  Future deleteWorkout(int id) =>
      (delete(workouts)..where((w) => w.id.equals(id))).go();

  /// ================= EXERCISES =================

  Future<List<Exercise>> getExercises() =>
      select(exercises).get();

  Future<int> insertExercise(ExercisesCompanion entry) =>
      into(exercises).insert(entry);

  Future deleteExercise(int id) =>
      (delete(exercises)..where((e) => e.id.equals(id))).go();

  /// ============ WORKOUT EXERCISES ==============

  Future insertWorkoutExercise(WorkoutExercisesCompanion entry) =>
      into(workoutExercises).insert(entry);

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) =>
      (select(workoutExercises)
        ..where((w) => w.workoutId.equals(workoutId)))
          .get();

  /// ================= SETS ====================

  Future insertSet(WorkoutSetsCompanion entry) =>
      into(workoutSets).insert(entry);

  Future<List<WorkoutSet>> getSets(int workoutExerciseId) =>
      (select(workoutSets)
        ..where((s) => s.workoutExerciseId.equals(workoutExerciseId)))
          .get();

  Future deleteWorkoutExercise(int id) =>
      (delete(workoutExercises)..where((e) => e.id.equals(id))).go();

  Future deleteSet(int id) =>
      (delete(workoutSets)..where((s) => s.id.equals(id))).go();

  Future updateSet({
    required int id,
    double? weight,
    int? reps,
    int? rest,
  }) =>
      (update(workoutSets)..where((s) => s.id.equals(id))).write(
        WorkoutSetsCompanion(
          weight: Value(weight),
          reps: Value(reps),
          restSeconds: Value(rest),
        ),
      );

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'workout.sqlite'));
    return NativeDatabase(file);
  });
}