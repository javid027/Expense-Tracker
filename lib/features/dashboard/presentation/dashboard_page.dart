import 'package:expensetracker/core/theme/app_theme.dart';
import 'package:expensetracker/core/utils/currency_formatter.dart';
import 'package:expensetracker/core/utils/date_utils.dart';
import 'package:expensetracker/features/analytics/presentation/finance_analytics.dart';
import 'package:expensetracker/features/budgets/presentation/budget_strip.dart';
import 'package:expensetracker/features/transactions/presentation/transaction_tile.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:expensetracker/shared/widgets/section_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsControllerProvider);
    return transactions.when(
      loading: () => const _DashboardSkeleton(),
      error: (error, stack) => Center(child: Text('Could not load wallet: $error')),
      data: (items) {
        final analytics = FinanceAnalytics(items);
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              sliver: SliverList.list(
                children: [
                  const _PageHeading(
                    title: 'Overview',
                    subtitle: 'A calm view of your money this month',
                  ),
                  const SizedBox(height: 18),
                  _Header(analytics: analytics),
                  const SizedBox(height: 18),
                  _CashflowCards(analytics: analytics),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'Spending pulse',
                    action: TextButton(
                      onPressed: () => context.go('/analytics'),
                      child: const Text('Reports'),
                    ),
                  ),
                  _TrendCard(analytics: analytics),
                  const SizedBox(height: 22),
                  const BudgetStrip(),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'Recent activity',
                    action: TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text('View all'),
                    ),
                  ),
                  for (final item in items.take(5))
                    TransactionTile(transaction: item).animate().fadeIn().slideY(begin: .08),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.analytics});

  final FinanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF20473F), Color(0xFF2F7D6B), Color(0xFF8EB8A7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.auto_graph_rounded, color: Colors.white),
              ),
              const Spacer(),
              Text(
                monthLabel(DateTime.now()),
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text('Available balance', style: TextStyle(color: Colors.white70)),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: analytics.balance),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                formatMoney(value),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            analytics.insight,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: .08);
  }
}

class _CashflowCards extends StatelessWidget {
  const _CashflowCards({required this.analytics});

  final FinanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Income',
            value: analytics.income,
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Expense',
            value: analytics.expenses,
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.coral,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(value, compact: true),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.analytics});

  final FinanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final bars = analytics.weekExpenseBars;
    final maxValue = bars.fold<double>(1, (max, item) => item > max ? item : max);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last 7 days',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                formatMoney(analytics.expenses, compact: true),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxValue * 1.25,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 3,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(days[value.toInt()], style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < bars.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: bars[i],
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          color: i == bars.length - 1 ? AppTheme.coral : AppTheme.emerald,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue * 1.15,
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
