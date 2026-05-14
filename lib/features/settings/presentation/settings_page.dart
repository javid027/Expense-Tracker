import 'package:expensetracker/core/services/reminder_service.dart';
import 'package:expensetracker/core/services/export_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:expensetracker/features/budgets/presentation/budgets_controller.dart';
import 'package:expensetracker/features/settings/presentation/settings_controller.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_controller.dart';
import 'package:expensetracker/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final exportService = ref.read(exportServiceProvider);
    final database = ref.watch(localDatabaseProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
          sliver: SliverList.list(
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Theme, privacy, exports, backups, reminders, and app lock',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<ThemeMode>(
                      selected: {settings.themeMode},
                      onSelectionChanged: (value) => controller.updateThemeMode(value.first),
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_iphone_rounded)),
                        ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: settings.encryptionEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Offline database encryption'),
                      subtitle: const Text('Encrypts transaction and budget records stored locally'),
                      onChanged: (value) async {
                        await controller.setEncryptionEnabled(value);
                        if (!context.mounted) return;
                        _snack(context, value ? 'Local data encryption enabled.' : 'Local data encryption disabled.');
                      },
                    ),
                    SwitchListTile(
                      value: settings.appLockEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('PIN and biometric app lock'),
                      subtitle: const Text('Requires a PIN and supports biometrics when available'),
                      onChanged: (value) async {
                        if (value) {
                          final pin = await _showPinSetupDialog(context);
                          if (!context.mounted) return;
                          if (pin == null) return;
                          await controller.setAppLockEnabled(true, pin: pin);
                          if (!context.mounted) return;
                          _snack(context, 'App lock enabled.');
                        } else {
                          await controller.setAppLockEnabled(false);
                          if (!context.mounted) return;
                          _snack(context, 'App lock disabled.');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exports and backups',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.table_chart_rounded,
                      title: 'Export CSV',
                      subtitle: 'Share transaction data as a CSV file',
                      onTap: () async {
                        final file = await exportService.exportCsv();
                        if (!context.mounted) return;
                        await exportService.shareFile(file);
                      },
                    ),
                    _ActionTile(
                      icon: Icons.picture_as_pdf_rounded,
                      title: 'Export PDF',
                      subtitle: 'Share a printable transaction summary',
                      onTap: () async {
                        final file = await exportService.exportPdf();
                        if (!context.mounted) return;
                        await exportService.shareFile(file);
                      },
                    ),
                    _ActionTile(
                      icon: Icons.backup_rounded,
                      title: 'Create backup',
                      subtitle:
                          '${database.transactionsBox.length} transactions and ${database.budgetsBox.length} budgets currently stored',
                      onTap: () async {
                        final file = await exportService.createBackup();
                        if (!context.mounted) return;
                        await exportService.shareFile(file);
                      },
                    ),
                    _ActionTile(
                      icon: Icons.restore_rounded,
                      title: 'Restore backup',
                      subtitle: 'Import a previously exported Finora backup JSON file',
                      onTap: () async {
                        final restored = await exportService.restoreBackupFromPicker();
                        if (!restored || !context.mounted) return;
                        await ref.read(transactionsControllerProvider.notifier).load();
                        await ref.read(budgetsControllerProvider.notifier).load();
                        ref.read(settingsControllerProvider.notifier).load();
                        if (!context.mounted) return;
                        _snack(context, 'Backup restored.');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: settings.remindersEnabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daily spending reminder'),
                      subtitle: const Text('Schedules a daily reminder at 8:00 PM'),
                      onChanged: (value) async {
                        try {
                          await controller.setRemindersEnabled(value, hour: 20, minute: 0);
                        } on ReminderPermissionException catch (error) {
                          if (!context.mounted) return;
                          _snack(context, error.message);
                          return;
                        }
                        if (!context.mounted) return;
                        _snack(context, value ? 'Daily reminder scheduled for 8:00 PM.' : 'Daily reminder canceled.');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> _showPinSetupDialog(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set app PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: '4-digit PIN'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pin = controller.text.trim();
                if (pin.length != 4 || pin != confirmController.text.trim()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter matching 4-digit PIN values.')),
                  );
                  return;
                }
                Navigator.of(context).pop(pin);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => onTap(),
    );
  }
}
