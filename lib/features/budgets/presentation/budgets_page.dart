import 'package:expensetracker/core/utils/currency_formatter.dart';
import 'package:expensetracker/features/budgets/domain/budget.dart';
import 'package:expensetracker/features/budgets/presentation/budgets_controller.dart';
import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/animated_progress_bar.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsControllerProvider);
    final transactions = ref.watch(transactionsControllerProvider).valueOrNull ?? [];

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          sliver: budgets.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Text('Budgets failed: $error'),
            ),
            data: (items) => SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budgets',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Set practical limits and watch category burn rate',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Add budget',
                      onPressed: () => _showBudgetSheet(context, ref),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                for (final budget in items) ...[
                  _BudgetCard(
                    budget: budget,
                    spent: _spent(transactions, budget),
                    onDelete: () =>
                        ref.read(budgetsControllerProvider.notifier).remove(budget.id),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static double _spent(List<FinanceTransaction> transactions, Budget budget) {
    final now = DateTime.now();
    return transactions
        .where((item) =>
            item.type == TransactionType.expense &&
            item.category == budget.category &&
            item.date.month == now.month &&
            item.date.year == now.year)
        .fold(0, (sum, item) => sum + item.amount);
  }

  void _showBudgetSheet(BuildContext context, WidgetRef ref) {
    var category = FinanceCategory.food;
    final amountController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New budget',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<FinanceCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final item in FinanceCategory.values)
                        DropdownMenuItem(value: item, child: Text(item.label)),
                    ],
                    onChanged: (value) => setState(() => category = value ?? category),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: 'Rs ',
                      labelText: 'Monthly limit',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) return;
                        await ref
                            .read(budgetsControllerProvider.notifier)
                            .create(category, amount);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save budget'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.onDelete,
  });

  final Budget budget;
  final double spent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = spent / budget.monthlyLimit;
    final warning = progress >= .85;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: budget.category.color.withValues(alpha: .16),
                child: Icon(budget.category.icon, color: budget.category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatMoney(spent, compact: true)} of ${formatMoney(budget.monthlyLimit, compact: true)}',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete budget',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedProgressBar(
            value: progress,
            color: warning ? colors.error : budget.category.color,
            height: 10,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${formatPercent(progress)} used',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: warning ? colors.error : colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
