import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart' as db;

final dbProvider = Provider<db.AppDatabase>((ref) => db.AppDatabase());
