import 'package:collection/collection.dart';
import 'package:expensetracker/core/utils/date_utils.dart';
import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';

class FinanceAnalytics {
  const FinanceAnalytics(this.transactions);

  final List<FinanceTransaction> transactions;

  List<FinanceTransaction> get monthTransactions =>
      transactions.where((item) => isInCurrentMonth(item.date)).toList();

  double get income => monthTransactions
      .where((item) => item.type == TransactionType.income)
      .fold(0, (sum, item) => sum + item.amount);

  double get expenses => monthTransactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0, (sum, item) => sum + item.amount);

  double get balance => income - expenses;

  Map<FinanceCategory, double> get expenseByCategory {
    final grouped = groupBy(
      monthTransactions.where((item) => item.type == TransactionType.expense),
      (FinanceTransaction item) => item.category,
    );
    return grouped.map(
      (category, rows) => MapEntry(
        category,
        rows.fold(0, (sum, item) => sum + item.amount),
      ),
    );
  }

  List<double> get weekExpenseBars {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - index));
      return transactions
          .where((item) =>
              item.type == TransactionType.expense &&
              item.date.year == day.year &&
              item.date.month == day.month &&
              item.date.day == day.day)
          .fold(0, (sum, item) => sum + item.amount);
    });
  }

  String get insight {
    if (expenses == 0) return 'No spending recorded this month. Your dashboard is ready.';
    final top = expenseByCategory.entries.sorted((a, b) => b.value.compareTo(a.value)).firstOrNull;
    if (top == null) return 'Track a few transactions to unlock smarter insights.';
    final share = top.value / expenses;
    return '${top.key.label} leads this month at ${(share * 100).round()}% of spending.';
  }
}
