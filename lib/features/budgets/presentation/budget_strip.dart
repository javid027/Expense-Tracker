import 'package:expensetracker/core/utils/currency_formatter.dart';
import 'package:expensetracker/features/budgets/presentation/budgets_controller.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/animated_progress_bar.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:expensetracker/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetStrip extends ConsumerWidget {
  const BudgetStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsControllerProvider).valueOrNull ?? [];
    final transactions = ref.watch(transactionsControllerProvider).valueOrNull ?? [];

    if (budgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Budget guardrails'),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: budgets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final spent = transactions
                  .where((item) =>
                      item.type == TransactionType.expense &&
                      item.category == budget.category &&
                      item.date.month == DateTime.now().month &&
                      item.date.year == DateTime.now().year)
                  .fold<double>(0, (sum, item) => sum + item.amount);
              final progress = spent / budget.monthlyLimit;
              return SizedBox(
                width: 220,
                child: PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: budget.category.color.withValues(alpha: .14),
                        child: Icon(budget.category.icon, color: budget.category.color),
                      ),
                      const Spacer(),
                      Text(budget.category.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      AnimatedProgressBar(value: progress, color: budget.category.color),
                      const SizedBox(height: 8),
                      Text(
                        '${formatMoney(spent, compact: true)} of ${formatMoney(budget.monthlyLimit, compact: true)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
