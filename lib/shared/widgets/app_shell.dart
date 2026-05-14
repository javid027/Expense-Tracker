import 'package:expensetracker/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _Destination('/', 'Home', Icons.dashboard_rounded),
    _Destination('/transactions', 'Wallet', Icons.account_balance_wallet_rounded),
    _Destination('/analytics', 'Reports', Icons.query_stats_rounded),
    _Destination('/budgets', 'Budgets', Icons.savings_rounded),
    _Destination('/settings', 'Settings', Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final location = GoRouterState.of(context).uri.path;
    final index = _destinations.indexWhere((item) => item.path == location).clamp(0, _destinations.length - 1);
    final useRail = width >= 720;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (useRail)
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: (value) => context.go(_destinations[value].path),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final item in _destinations)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
              ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => context.go(_destinations[value].path),
              destinations: [
                for (final item in _destinations)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'quick-add',
        onPressed: () => showTransactionFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}
