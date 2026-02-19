import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Core taxonomy
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  IntColumn get passPercent => integer().withDefault(const Constant(60))();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
}

class Subcategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
}

// Exams & content
class Exams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get subcategoryId =>
      integer().nullable().references(Subcategories, #id)();
  IntColumn get questionCount => integer().withDefault(const Constant(0))();
  BoolColumn get published => boolean().withDefault(const Constant(false))();
  IntColumn get timeLimitMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get shuffleOptions =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get negativeMarking =>
      boolean().withDefault(const Constant(false))();
  IntColumn get passPercent => integer().withDefault(const Constant(60))();
  IntColumn get themeKey => integer().withDefault(const Constant(0))();
  // Optional URL to a reference PDF for the exam
  TextColumn get pdfUrl => text().withDefault(const Constant(''))();
}

class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text()();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  BoolColumn get multiple => boolean().withDefault(const Constant(false))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
}

class Choices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().references(Questions, #id)();
  TextColumn get label => text()();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  IntColumn get order => integer().withDefault(const Constant(0))();
}

class ExamQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get order => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(1))();
}

class ExamGradeBands extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  IntColumn get minPercent => integer()();
  TextColumn get label => text()();
  TextColumn get color => text().withDefault(const Constant('#4CAF50'))();
}

// Many-to-many: questions <-> categories (for reuse/taxonomy)
class QuestionCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
}

class QuestionSubcategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get subcategoryId => integer().references(Subcategories, #id)();
}

// Attempts & answers
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  TextColumn get mode => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  IntColumn get scorePercent => integer().withDefault(const Constant(0))();
  TextColumn get gradeLabel => text().withDefault(const Constant(''))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  // Associate attempts with a user; 'guest@local' for anonymous
  TextColumn get userEmail =>
      text().withDefault(const Constant('guest@local'))();
}

class AttemptAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(Attempts, #id)();
  IntColumn get questionId => integer().references(Questions, #id)();
  TextColumn get selected => text()(); // json array of choice IDs
  IntColumn get timeMs => integer().withDefault(const Constant(0))();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  IntColumn get points => integer().withDefault(const Constant(0))();
}

// Local auth
@DataClassName('DbUser')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get role => text().withDefault(const Constant('user'))();
  BoolColumn get isPro => boolean().withDefault(const Constant(false))();
}

class SavedQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().references(Questions, #id)();
  TextColumn get userEmail => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  TextColumn get userEmail => text()();
  TextColumn get comment => text()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get minutesTarget => integer().withDefault(const Constant(15))();
  BoolColumn get notify => boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(9))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();
  DateTimeColumn get examDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {key};
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userEmail => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text()();
  TextColumn get stripePaymentIntentId =>
      text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('paid'))();
  BoolColumn get refunded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Categories,
    Subcategories,
    Exams,
    Questions,
    Choices,
    ExamQuestions,
    ExamGradeBands,
    QuestionCategories,
    QuestionSubcategories,
    Attempts,
    AttemptAnswers,
    Users,
    SavedQuestions,
    Reports,
    DailyGoals,
    AppSettings,
    Payments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  @override
  int get schemaVersion => 16;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _ensureSupplementalTables();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Drop legacy tables from v1
        await m.deleteTable('attempt_answers');
        await m.deleteTable('attempts');
        await m.deleteTable('exams');
        await m.deleteTable('categories');
        await m.createAll();
      }
      if (from < 3) {
        // Add passPercent to categories (idempotent)
        if (!await _columnExists('categories', 'pass_percent')) {
          await m.addColumn(categories, categories.passPercent);
        }
      }
      if (from < 4) {
        // Add question_categories (idempotent)
        if (!await _tableExists('question_categories')) {
          await m.createTable(questionCategories);
        }
      }
      if (from < 5) {
        if (!await _columnExists('exams', 'theme_key')) {
          await m.addColumn(exams, exams.themeKey);
        }
      }
      if (from < 6) {
        if (!await _tableExists('saved_questions')) {
          await m.createTable(savedQuestions);
        }
        if (!await _tableExists('reports')) {
          await m.createTable(reports);
        }
      }
      if (from < 8) {
        if (!await _tableExists('daily_goals')) {
          await m.createTable(dailyGoals);
        }
      }
      if (from < 9) {
        if (!await _columnExists('categories', 'image_url')) {
          await m.addColumn(categories, categories.imageUrl);
        }
        if (!await _columnExists('subcategories', 'image_url')) {
          await m.addColumn(subcategories, subcategories.imageUrl);
        }
        if (!await _tableExists('question_subcategories')) {
          await m.createTable(questionSubcategories);
        }
      }
      if (from < 10) {
        if (!await _columnExists('categories', 'locked')) {
          await m.addColumn(categories, categories.locked);
        }
        if (!await _columnExists('subcategories', 'locked')) {
          await m.addColumn(subcategories, subcategories.locked);
        }
        if (!await _columnExists('questions', 'locked')) {
          await m.addColumn(questions, questions.locked);
        }
        if (!await _columnExists('users', 'is_pro')) {
          await m.addColumn(users, users.isPro);
        }
        if (!await _tableExists('app_settings')) {
          await m.createTable(appSettings);
        }
        if (!await _tableExists('payments')) {
          await m.createTable(payments);
        }
      }
      if (from < 11) {
        if (!await _columnExists('attempts', 'user_email')) {
          await customStatement(
            "ALTER TABLE attempts ADD COLUMN user_email TEXT NOT NULL DEFAULT 'guest@local'",
          );
        }
      }
      if (from < 12) {
        if (!await _tableExists('translations')) {
          await customStatement(
            'CREATE TABLE IF NOT EXISTS translations (id INTEGER PRIMARY KEY AUTOINCREMENT, entity TEXT NOT NULL, entity_id INTEGER NOT NULL, lang TEXT NOT NULL, k TEXT NOT NULL, v TEXT NOT NULL)',
          );
        }
      }
      if (from < 13) {
        // Add pdf_url column to exams if missing (idempotent)
        if (!await _columnExists('exams', 'pdf_url')) {
          await m.addColumn(exams, exams.pdfUrl);
        }
      }
      if (from < 14) {
        // Create pdf_progress table for per-user PDF reading progress
        if (!await _tableExists('pdf_progress')) {
          await customStatement(
            'CREATE TABLE IF NOT EXISTS pdf_progress ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'exam_id INTEGER NOT NULL, '
            'user_email TEXT NOT NULL, '
            'page INTEGER NOT NULL DEFAULT 0, '
            'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
            'UNIQUE(user_email, exam_id)'
            ')',
          );
        }
      }
      if (from < 15) {
        // Practice progress per user/category (for "Practice all")
        if (!await _tableExists('practice_progress')) {
          await customStatement(
            'CREATE TABLE IF NOT EXISTS practice_progress ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'category_id INTEGER NOT NULL, '
            'user_email TEXT NOT NULL, '
            '"index" INTEGER NOT NULL DEFAULT 0, '
            'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
            'UNIQUE(user_email, category_id)'
            ')',
          );
        }
      }
      if (from < 16) {
        // Practice answers per user/category/question (counts towards dashboard progress)
        if (!await _tableExists('practice_answers')) {
          await customStatement(
            'CREATE TABLE IF NOT EXISTS practice_answers ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'user_email TEXT NOT NULL, '
            'category_id INTEGER NOT NULL, '
            'question_id INTEGER NOT NULL, '
            'is_correct INTEGER NOT NULL DEFAULT 0, '
            'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
            'UNIQUE(user_email, question_id)'
            ')',
          );
        }
      }
    },
    beforeOpen: (details) async {
      // Safety net for databases that ended up with partial schema state.
      await _ensureSupplementalTables();
    },
  );

  Future<void> ensureClientSchema() async {
    await _ensureSupplementalTables();
  }

  Future<void> _ensureSupplementalTables() async {
    await customStatement(
      'CREATE TABLE IF NOT EXISTS translations ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'entity TEXT NOT NULL, '
      'entity_id INTEGER NOT NULL, '
      'lang TEXT NOT NULL, '
      'k TEXT NOT NULL, '
      'v TEXT NOT NULL'
      ')',
    );
    await customStatement(
      'CREATE TABLE IF NOT EXISTS pdf_progress ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'exam_id INTEGER NOT NULL, '
      'user_email TEXT NOT NULL, '
      'page INTEGER NOT NULL DEFAULT 0, '
      'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
      'UNIQUE(user_email, exam_id)'
      ')',
    );
    await customStatement(
      'CREATE TABLE IF NOT EXISTS practice_progress ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'category_id INTEGER NOT NULL, '
      'user_email TEXT NOT NULL, '
      '"index" INTEGER NOT NULL DEFAULT 0, '
      'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
      'UNIQUE(user_email, category_id)'
      ')',
    );
    await customStatement(
      'CREATE TABLE IF NOT EXISTS practice_answers ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_email TEXT NOT NULL, '
      'category_id INTEGER NOT NULL, '
      'question_id INTEGER NOT NULL, '
      'is_correct INTEGER NOT NULL DEFAULT 0, '
      'updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, '
      'UNIQUE(user_email, question_id)'
      ')',
    );
  }

  Future<bool> _columnExists(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info("$table")').get();
    for (final r in rows) {
      final name = r.data['name'] as String?;
      if (name == column) return true;
    }
    return false;
  }

  Future<bool> _tableExists(String table) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable<String>(table)],
    ).get();
    return rows.isNotEmpty;
  }
}

QueryExecutor openConnection() => driftDatabase(
  name: 'exampro.sqlite',
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
  ),
);
