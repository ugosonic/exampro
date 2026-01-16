<<<<<<< HEAD
import 'package:exampro/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

=======
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart' as db;

final dbProvider = Provider<db.AppDatabase>((ref) => db.AppDatabase());
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
