import 'package:exampro/core/db/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

