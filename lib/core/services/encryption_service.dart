import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:expensetracker/core/services/secure_storage_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:expensetracker/features/budgets/domain/budget.dart';
import 'package:expensetracker/features/transactions/domain/finance_transaction.dart';

class EncryptionService {
  EncryptionService(this._database);

  final LocalDatabase _database;

  static const keyStorageKey = 'finora_encryption_key';
  static const payloadPrefix = 'enc:';

  Future<String> encryptJson(Map<String, dynamic> json) async {
    final encrypter = await _encrypter();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = encrypter.encrypt(jsonEncode(json), iv: iv);
    return '$payloadPrefix${iv.base64}:${encrypted.base64}';
  }

  Future<Map<String, dynamic>> decryptJson(String payload) async {
    if (!payload.startsWith(payloadPrefix)) {
      return Map<String, dynamic>.from(jsonDecode(payload) as Map<String, dynamic>);
    }
    final encrypter = await _encrypter();
    final trimmed = payload.substring(payloadPrefix.length);
    final parts = trimmed.split(':');
    final iv = encrypt.IV.fromBase64(parts.first);
    final encryptedValue = encrypt.Encrypted.fromBase64(parts.last);
    final decrypted = encrypter.decrypt(encryptedValue, iv: iv);
    return Map<String, dynamic>.from(jsonDecode(decrypted) as Map<String, dynamic>);
  }

  Future<void> migrateAll(bool encryptValues) async {
    final transactionEntries = _database.transactionsBox.toMap().entries.toList();
    for (final entry in transactionEntries) {
      final current = entry.value;
      if (encryptValues) {
        if (current is String && current.startsWith(payloadPrefix)) continue;
        final json = Map<dynamic, dynamic>.from(current as Map);
        await _database.transactionsBox.put(
          entry.key,
          await encryptJson(Map<String, dynamic>.from(json)),
        );
      } else if (current is String && current.startsWith(payloadPrefix)) {
        await _database.transactionsBox.put(entry.key, await decryptJson(current));
      }
    }

    final budgetEntries = _database.budgetsBox.toMap().entries.toList();
    for (final entry in budgetEntries) {
      final current = entry.value;
      if (encryptValues) {
        if (current is String && current.startsWith(payloadPrefix)) continue;
        final json = Map<dynamic, dynamic>.from(current as Map);
        await _database.budgetsBox.put(
          entry.key,
          await encryptJson(Map<String, dynamic>.from(json)),
        );
      } else if (current is String && current.startsWith(payloadPrefix)) {
        await _database.budgetsBox.put(entry.key, await decryptJson(current));
      }
    }
  }

  Future<List<FinanceTransaction>> readTransactions() async {
    final items = <FinanceTransaction>[];
    for (final value in _database.transactionsBox.values) {
      if (value is String) {
        items.add(FinanceTransaction.fromJson(await decryptJson(value)));
      } else {
        items.add(FinanceTransaction.fromJson(Map<dynamic, dynamic>.from(value as Map)));
      }
    }
    return items;
  }

  Future<List<Budget>> readBudgets() async {
    final items = <Budget>[];
    for (final value in _database.budgetsBox.values) {
      if (value is String) {
        items.add(Budget.fromJson(await decryptJson(value)));
      } else {
        items.add(Budget.fromJson(Map<dynamic, dynamic>.from(value as Map)));
      }
    }
    return items;
  }

  Future<encrypt.Encrypter> _encrypter() async {
    var base64Key = await SecureStorageService.read(keyStorageKey);
    if (base64Key == null) {
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      base64Key = base64Encode(bytes);
      await SecureStorageService.write(keyStorageKey, base64Key);
    }
    final key = encrypt.Key.fromBase64(base64Key);
    return encrypt.Encrypter(encrypt.AES(key));
  }
}
