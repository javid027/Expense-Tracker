import 'package:expensetracker/core/services/encryption_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:expensetracker/features/budgets/domain/budget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return HiveBudgetRepository(ref.watch(localDatabaseProvider));
});

abstract class BudgetRepository {
  Future<List<Budget>> readAll();
  Future<void> upsert(Budget budget);
  Future<void> delete(String id);
}

class HiveBudgetRepository implements BudgetRepository {
  HiveBudgetRepository(this._database) : _encryption = EncryptionService(_database);

  final LocalDatabase _database;
  final EncryptionService _encryption;

  @override
  Future<List<Budget>> readAll() async {
    return _encryption.readBudgets();
  }

  @override
  Future<void> upsert(Budget budget) async {
    final encryptionEnabled =
        (_database.settingsBox.get('encryption_enabled') as bool?) ?? false;
    final payload = budget.toJson();
    if (encryptionEnabled) {
      await _database.budgetsBox.put(
        budget.id,
        await _encryption.encryptJson(payload),
      );
      return;
    }
    await _database.budgetsBox.put(budget.id, payload);
  }

  @override
  Future<void> delete(String id) => _database.budgetsBox.delete(id);
}
