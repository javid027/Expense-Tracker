import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  throw UnimplementedError('LocalDatabase must be overridden at bootstrap.');
});

class LocalDatabase {
  LocalDatabase(this.transactionsBox, this.budgetsBox, this.settingsBox);

  static const transactionsBoxName = 'transactions_v2';
  static const budgetsBoxName = 'budgets_v2';
  static const settingsBoxName = 'settings_v2';

  final Box<dynamic> transactionsBox;
  final Box<dynamic> budgetsBox;
  final Box<dynamic> settingsBox;

  static Future<LocalDatabase> open() async {
    await Hive.initFlutter();
    return LocalDatabase(
      await Hive.openBox<dynamic>(transactionsBoxName),
      await Hive.openBox<dynamic>(budgetsBoxName),
      await Hive.openBox<dynamic>(settingsBoxName),
    );
  }
}
