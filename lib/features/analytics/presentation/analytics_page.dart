import 'package:expensetracker/core/theme/app_theme.dart';
import 'package:expensetracker/core/utils/currency_formatter.dart';
import 'package:expensetracker/features/analytics/presentation/finance_analytics.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:expensetracker/shared/widgets/section_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsControllerProvider);

    return transactions.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Analytics failed: $error')),
      data: (items) {
        final analytics = FinanceAnalytics(items);
        final categories = analytics.expenseByCategory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = analytics.expenses;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Simple charts with clearer proportions and labels',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 18),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly snapshot',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          analytics.insight,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 260,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 52,
                                    sectionsSpace: 2,
                                    startDegreeOffset: -90,
                                    sections: [
                                      for (final entry in categories)
                                        PieChartSectionData(
                                          color: entry.key.color,
                                          value: entry.value,
                                          title: total == 0
                                              ? ''
                                              : '${((entry.value / total) * 100).round()}%',
                                          radius: 58,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final entry in categories.take(4))
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: entry.key.color,
                                                borderRadius: BorderRadius.circular(99),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                entry.key.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              formatMoney(entry.value, compact: true),
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionHeader(title: 'Category comparison'),
                  PremiumCard(
                    child: Column(
                      children: [
                        for (final entry in categories)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: entry.key.color.withValues(alpha: .14),
                                  child: Icon(entry.key.icon, color: entry.key.color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        minHeight: 8,
                                        value: analytics.expenses == 0 ? 0 : entry.value / analytics.expenses,
                                        color: entry.key.color,
                                        backgroundColor: entry.key.color.withValues(alpha: .12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(formatMoney(entry.value, compact: true)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PremiumCard(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.mint,
                        AppTheme.emerald.withValues(alpha: .92),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.psychology_alt_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Heatmaps, yearly trends, and PDF reports are ready in the local architecture layer.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
