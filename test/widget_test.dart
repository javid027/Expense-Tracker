import 'dart:io';

import 'package:expensetracker/core/storage/local_database.dart';
import 'package:expensetracker/features/analytics/presentation/finance_analytics.dart';
import 'package:expensetracker/features/settings/presentation/settings_controller.dart';
import 'package:expensetracker/features/transactions/domain/finance_category.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';
import 'package:expensetracker/features/transactions/presentation/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('FinanceTransaction', () {
    test('json round trip keeps offline data stable', () {
      final transaction = FinanceTransaction(
        id: 'tx_1',
        title: 'Coffee',
        amount: 280,
        type: TransactionType.expense,
        category: FinanceCategory.food,
        date: DateTime(2026, 5, 13),
        notes: 'Client catch-up',
        isFavorite: true,
        recurrence: Recurrence.none,
      );

      final restored = FinanceTransaction.fromJson(transaction.toJson());

      expect(restored.id, transaction.id);
      expect(restored.title, transaction.title);
      expect(restored.amount, transaction.amount);
      expect(restored.category, transaction.category);
      expect(restored.isFavorite, isTrue);
    });
  });

  group('FinanceAnalytics', () {
    test('calculates income, expense, and insight correctly', () {
      final now = DateTime.now();
      final analytics = FinanceAnalytics([
        FinanceTransaction(
          id: '1',
          title: 'Salary',
          amount: 50000,
          type: TransactionType.income,
          category: FinanceCategory.salary,
          date: now,
        ),
        FinanceTransaction(
          id: '2',
          title: 'Groceries',
          amount: 3000,
          type: TransactionType.expense,
          category: FinanceCategory.food,
          date: now,
        ),
        FinanceTransaction(
          id: '3',
          title: 'Taxi',
          amount: 1200,
          type: TransactionType.expense,
          category: FinanceCategory.transport,
          date: now,
        ),
      ]);

      expect(analytics.income, 50000);
      expect(analytics.expenses, 4200);
      expect(analytics.balance, 45800);
      expect(analytics.expenseByCategory[FinanceCategory.food], 3000);
      expect(analytics.insight, contains('Food leads this month'));
    });
  });

  group('applyTransactionPresentation', () {
    final items = [
      FinanceTransaction(
        id: '1',
        title: 'Salary credited',
        amount: 90000,
        type: TransactionType.income,
        category: FinanceCategory.salary,
        date: DateTime(2026, 5, 10),
      ),
      FinanceTransaction(
        id: '2',
        title: 'Lunch',
        amount: 450,
        type: TransactionType.expense,
        category: FinanceCategory.food,
        date: DateTime(2026, 5, 11),
        isFavorite: true,
      ),
      FinanceTransaction(
        id: '3',
        title: 'Metro',
        amount: 120,
        type: TransactionType.expense,
        category: FinanceCategory.transport,
        date: DateTime(2026, 5, 12),
      ),
    ];

    test('filters by category and favorites', () {
      final result = applyTransactionPresentation(
        items,
        search: '',
        category: FinanceCategory.food,
        type: TransactionType.expense,
        favoritesOnly: true,
        sort: TransactionSort.latest,
      );

      expect(result, hasLength(1));
      expect(result.first.title, 'Lunch');
    });

    test('sorts by highest amount', () {
      final result = applyTransactionPresentation(
        items,
        search: '',
        category: null,
        type: null,
        favoritesOnly: false,
        sort: TransactionSort.highest,
      );

      expect(result.first.title, 'Salary credited');
      expect(result.last.title, 'Metro');
    });

    test('search matches title and notes', () {
      final withNote = items[2].copyWith(notes: 'Morning commute');
      final result = applyTransactionPresentation(
        [items[0], items[1], withNote],
        search: 'commute',
        category: null,
        type: null,
        favoritesOnly: false,
        sort: TransactionSort.latest,
      );

      expect(result, hasLength(1));
      expect(result.first.title, 'Metro');
    });
  });

  group('SettingsController', () {
    test('loads and updates local settings state', () async {
      final tempDir = await Directory.systemTemp.createTemp('finora_settings_test_');
      Hive.init(tempDir.path);
      final database = LocalDatabase(
        await Hive.openBox<dynamic>('transactions_test'),
        await Hive.openBox<dynamic>('budgets_test'),
        await Hive.openBox<dynamic>('settings_test'),
      );

      final controller = SettingsController(database)..load();

      expect(controller.state.themeMode, ThemeMode.system);
      expect(controller.state.encryptionEnabled, isFalse);

      await controller.updateThemeMode(ThemeMode.dark);
      await controller.setEncryptionEnabled(true);
      await controller.setAppLockEnabled(true);
      await controller.setRemindersEnabled(true);

      expect(controller.state.themeMode, ThemeMode.dark);
      expect(controller.state.encryptionEnabled, isTrue);
      expect(controller.state.appLockEnabled, isTrue);
      expect(controller.state.remindersEnabled, isTrue);

      final reloaded = SettingsController(database)..load();
      expect(reloaded.state.themeMode, ThemeMode.dark);
      expect(reloaded.state.encryptionEnabled, isTrue);
      expect(reloaded.state.appLockEnabled, isTrue);
      expect(reloaded.state.remindersEnabled, isTrue);

      await Hive.close();
      await tempDir.delete(recursive: true);
    });
  });
}
