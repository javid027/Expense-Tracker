import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:expensetracker/features/transactions/presentation/transaction_tile.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/empty_state.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionSearchProvider = StateProvider<String>((ref) => '');
final transactionCategoryFilterProvider =
    StateProvider<FinanceCategory?>((ref) => null);
final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);
final favoritesOnlyProvider = StateProvider<bool>((ref) => false);
final transactionSortProvider =
    StateProvider<TransactionSort>((ref) => TransactionSort.latest);

enum TransactionSort { latest, oldest, highest, lowest }

List<FinanceTransaction> applyTransactionPresentation(
  List<FinanceTransaction> items, {
  required String search,
  required FinanceCategory? category,
  required TransactionType? type,
  required bool favoritesOnly,
  required TransactionSort sort,
}) {
  final normalizedSearch = search.toLowerCase();
  final filtered = items.where((item) {
    final matchesSearch = item.title.toLowerCase().contains(normalizedSearch) ||
        item.notes.toLowerCase().contains(normalizedSearch);
    final matchesCategory = category == null || item.category == category;
    final matchesType = type == null || item.type == type;
    final matchesFavorite = !favoritesOnly || item.isFavorite;
    return matchesSearch && matchesCategory && matchesType && matchesFavorite;
  }).toList()
    ..sort((a, b) {
      switch (sort) {
        case TransactionSort.latest:
          return b.date.compareTo(a.date);
        case TransactionSort.oldest:
          return a.date.compareTo(b.date);
        case TransactionSort.highest:
          return b.amount.compareTo(a.amount);
        case TransactionSort.lowest:
          return a.amount.compareTo(b.amount);
      }
    });

  return filtered;
}

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(transactionSearchProvider).toLowerCase();
    final category = ref.watch(transactionCategoryFilterProvider);
    final type = ref.watch(transactionTypeFilterProvider);
    final favoritesOnly = ref.watch(favoritesOnlyProvider);
    final sort = ref.watch(transactionSortProvider);
    final state = ref.watch(transactionsControllerProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transactions',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Search, filter, and manage your local activity',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Filter and sort',
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _showFilterSheet(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search transactions',
                ),
                onChanged: (value) =>
                    ref.read(transactionSearchProvider.notifier).state = value,
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: FinanceCategory.values.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = index == 0 ? null : FinanceCategory.values[index - 1];
                    final selected = item == category;
                    return FilterChip(
                      selected: selected,
                      avatar: item == null ? null : Icon(item.icon, size: 18),
                      label: Text(item?.label ?? 'All'),
                      onSelected: (_) =>
                          ref.read(transactionCategoryFilterProvider.notifier).state = item,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              PremiumCard(
                child: state.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Text('Could not load transactions: $error'),
                  data: (items) {
                    final filtered = applyTransactionPresentation(
                      items,
                      search: search,
                      category: category,
                      type: type,
                      favoritesOnly: favoritesOnly,
                      sort: sort,
                    );

                    if (filtered.isEmpty) {
                      return const EmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No matching transactions',
                        subtitle: 'Try a different search or category filter.',
                      );
                    }

                    return Column(
                      children: [
                        for (final item in filtered) TransactionTile(transaction: item),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showFilterSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final selectedCategory = ref.watch(transactionCategoryFilterProvider);
          final selectedType = ref.watch(transactionTypeFilterProvider);
          final favoritesOnly = ref.watch(favoritesOnlyProvider);
          final sort = ref.watch(transactionSortProvider);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter and sort',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<TransactionSort>(
                  initialValue: sort,
                  decoration: const InputDecoration(labelText: 'Sort by'),
                  items: const [
                    DropdownMenuItem(value: TransactionSort.latest, child: Text('Latest first')),
                    DropdownMenuItem(value: TransactionSort.oldest, child: Text('Oldest first')),
                    DropdownMenuItem(value: TransactionSort.highest, child: Text('Highest amount')),
                    DropdownMenuItem(value: TransactionSort.lowest, child: Text('Lowest amount')),
                  ],
                  onChanged: (value) =>
                      ref.read(transactionSortProvider.notifier).state = value ?? TransactionSort.latest,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType?>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All types')),
                    DropdownMenuItem(value: TransactionType.expense, child: Text('Expense')),
                    DropdownMenuItem(value: TransactionType.income, child: Text('Income')),
                  ],
                  onChanged: (value) => ref.read(transactionTypeFilterProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FinanceCategory?>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All categories')),
                    for (final item in FinanceCategory.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  onChanged: (value) => ref.read(transactionCategoryFilterProvider.notifier).state = value,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: favoritesOnly,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Favorites only'),
                  onChanged: (value) => ref.read(favoritesOnlyProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(transactionCategoryFilterProvider.notifier).state = null;
                          ref.read(transactionTypeFilterProvider.notifier).state = null;
                          ref.read(favoritesOnlyProvider.notifier).state = false;
                          ref.read(transactionSortProvider.notifier).state = TransactionSort.latest;
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
