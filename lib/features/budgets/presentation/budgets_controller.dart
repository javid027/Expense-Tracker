import 'package:expensetracker/features/budgets/data/budget_repository.dart';
import 'package:expensetracker/features/budgets/domain/budget.dart';
import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final budgetsControllerProvider =
    StateNotifierProvider<BudgetsController, AsyncValue<List<Budget>>>((ref) {
  return BudgetsController(ref.watch(budgetRepositoryProvider))..load();
});

class BudgetsController extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetsController(this._repository) : super(const AsyncLoading());

  final BudgetRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.readAll);
  }

  Future<void> save(Budget budget) async {
    await _repository.upsert(budget);
    state = AsyncData(await _repository.readAll());
  }

  Future<void> create(FinanceCategory category, double limit) {
    return save(Budget(id: const Uuid().v4(), category: category, monthlyLimit: limit));
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.readAll());
  }
}
