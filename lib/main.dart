import 'package:expensetracker/core/services/reminder_service.dart';
import 'package:expensetracker/core/services/startup_migration_service.dart';
import 'package:expensetracker/app/app.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.init();
  final database = await LocalDatabase.open();
  await StartupMigrationService.run(database);

  runApp(
    ProviderScope(
      overrides: [
        localDatabaseProvider.overrideWithValue(database),
      ],
      child: const FinoraApp(),
    ),
  );
}
