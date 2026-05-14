import 'package:expensetracker/core/services/encryption_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return HiveTransactionRepository(ref.watch(localDatabaseProvider));
});

abstract class TransactionRepository {
  Future<List<FinanceTransaction>> readAll();
  Future<void> upsert(FinanceTransaction transaction);
  Future<void> delete(String id);
  Future<void> clear();
}

class HiveTransactionRepository implements TransactionRepository {
  HiveTransactionRepository(this._database) : _encryption = EncryptionService(_database);

  final LocalDatabase _database;
  final EncryptionService _encryption;

  @override
  Future<List<FinanceTransaction>> readAll() async {
    final transactions = await _encryption.readTransactions()
      ..sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<void> upsert(FinanceTransaction transaction) async {
    final encryptionEnabled =
        (_database.settingsBox.get('encryption_enabled') as bool?) ?? false;
    final payload = transaction.toJson();
    if (encryptionEnabled) {
      await _database.transactionsBox.put(
        transaction.id,
        await _encryption.encryptJson(payload),
      );
      return;
    }
    await _database.transactionsBox.put(transaction.id, payload);
  }

  @override
  Future<void> delete(String id) => _database.transactionsBox.delete(id);

  @override
  Future<void> clear() => _database.transactionsBox.clear();
}
