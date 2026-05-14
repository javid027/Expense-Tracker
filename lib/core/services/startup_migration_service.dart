import 'package:expensetracker/core/services/encryption_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';

class StartupMigrationService {
  StartupMigrationService._();

  static const _cleanupKey = 'demo_cleanup_v1_done';
  static const _demoTitles = {
    'Design subscription',
    'Salary credited',
    'Cafe meeting',
    'Metro card',
    'Index fund SIP',
  };

  static Future<void> run(LocalDatabase database) async {
    final settings = database.settingsBox;
    if ((settings.get(_cleanupKey) as bool?) == true) return;

    final encryption = EncryptionService(database);
    final transactions = await encryption.readTransactions();
    final budgets = await encryption.readBudgets();

    final looksLikeDemoTransactions = transactions.isNotEmpty &&
        transactions.length <= _demoTitles.length &&
        transactions.every((item) => _demoTitles.contains(item.title));

    final looksLikeDemoBudgets = budgets.isNotEmpty &&
        budgets.length <= 4 &&
        budgets.every((item) =>
            (item.category.name == 'food' && item.monthlyLimit == 12000) ||
            (item.category.name == 'transport' && item.monthlyLimit == 7000) ||
            (item.category.name == 'shopping' && item.monthlyLimit == 18000) ||
            (item.category.name == 'bills' && item.monthlyLimit == 9000));

    if (looksLikeDemoTransactions) {
      await database.transactionsBox.clear();
    }
    if (looksLikeDemoBudgets) {
      await database.budgetsBox.clear();
    }

    await settings.put(_cleanupKey, true);
  }
}
