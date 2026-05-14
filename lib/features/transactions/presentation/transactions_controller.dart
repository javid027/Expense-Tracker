import 'package:expensetracker/features/transactions/data/transaction_repository.dart';
import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final transactionsControllerProvider = StateNotifierProvider<
    TransactionsController, AsyncValue<List<FinanceTransaction>>>((ref) {
  return TransactionsController(ref.watch(transactionRepositoryProvider))..load();
});

class TransactionsController
    extends StateNotifier<AsyncValue<List<FinanceTransaction>>> {
  TransactionsController(this._repository) : super(const AsyncLoading());

  final TransactionRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.readAll);
  }

  Future<void> save(FinanceTransaction transaction) async {
    await _repository.upsert(transaction);
    state = AsyncData(await _repository.readAll());
  }

  Future<void> add({
    required String title,
    required double amount,
    required TransactionType type,
    required FinanceCategory category,
    required DateTime date,
    String notes = '',
    String? receiptPath,
    Recurrence recurrence = Recurrence.none,
  }) {
    return save(
      FinanceTransaction(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
        notes: notes,
        receiptPath: receiptPath,
        recurrence: recurrence,
      ),
    );
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.readAll());
  }

  Future<void> toggleFavorite(FinanceTransaction transaction) {
    return save(transaction.copyWith(isFavorite: !transaction.isFavorite));
  }
}
