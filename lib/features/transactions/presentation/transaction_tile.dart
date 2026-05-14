import 'package:expensetracker/core/utils/currency_formatter.dart';
import 'package:expensetracker/core/utils/date_utils.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:expensetracker/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction});

  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: ValueKey(transaction.id),
      background: _SwipeAction(
        alignment: Alignment.centerLeft,
        color: colors.primary,
        icon: Icons.star_rounded,
        label: 'Favorite',
      ),
      secondaryBackground: _SwipeAction(
        alignment: Alignment.centerRight,
        color: colors.error,
        icon: Icons.delete_rounded,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await ref.read(transactionsControllerProvider.notifier).remove(transaction.id);
          return true;
        }
        await ref.read(transactionsControllerProvider.notifier).toggleFavorite(transaction);
        return false;
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        onTap: () => showTransactionFormSheet(context, transaction: transaction),
        leading: Hero(
          tag: 'category-${transaction.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundColor: transaction.category.color.withValues(alpha: .16),
            child: Icon(transaction.category.icon, color: transaction.category.color),
          ),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${transaction.category.label} • ${shortDate(transaction.date)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isExpense ? '-' : '+'}${formatMoney(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isExpense ? colors.onSurface : colors.primary,
              ),
            ),
            if (transaction.isFavorite)
              Icon(Icons.star_rounded, size: 16, color: colors.secondary),
          ],
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
