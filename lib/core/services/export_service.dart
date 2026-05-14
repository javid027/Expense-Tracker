import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:expensetracker/core/services/encryption_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(localDatabaseProvider));
});

class ExportService {
  ExportService(this._database) : _encryption = EncryptionService(_database);

  final LocalDatabase _database;
  final EncryptionService _encryption;

  Future<File> exportCsv() async {
    final transactions = await _encryption.readTransactions();
    final rows = <List<dynamic>>[
      ['Title', 'Amount', 'Type', 'Category', 'Date', 'Notes', 'Favorite', 'Recurrence'],
      for (final item in transactions)
        [
          item.title,
          item.amount,
          item.type.name,
          item.category.label,
          item.date.toIso8601String(),
          item.notes,
          item.isFavorite,
          item.recurrence.name,
        ],
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final file = await _localFile('finora_transactions.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<File> exportPdf() async {
    final transactions = await _encryption.readTransactions();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'Finora Transactions'),
          pw.TableHelper.fromTextArray(
            headers: ['Title', 'Amount', 'Type', 'Category', 'Date'],
            data: [
              for (final item in transactions)
                [
                  item.title,
                  item.amount.toStringAsFixed(2),
                  item.type.name,
                  item.category.label,
                  item.date.toIso8601String().split('T').first,
                ],
            ],
          ),
        ],
      ),
    );
    final file = await _localFile('finora_transactions.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<File> createBackup() async {
    final backup = {
      'transactions': [
        for (final item in await _encryption.readTransactions()) item.toJson(),
      ],
      'budgets': [
        for (final item in await _encryption.readBudgets()) item.toJson(),
      ],
      'settings': Map<String, dynamic>.from(_database.settingsBox.toMap()),
      'createdAt': DateTime.now().toIso8601String(),
    };
    final file = await _localFile('finora_backup.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(backup));
    return file;
  }

  Future<void> shareFile(File file) {
    return Share.shareXFiles([XFile(file.path)]);
  }

  Future<bool> restoreBackupFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return false;
    final file = File(path);
    final content = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    await _database.transactionsBox.clear();
    await _database.budgetsBox.clear();

    final transactions = (content['transactions'] as List<dynamic>? ?? []);
    for (final item in transactions.cast<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(item);
      await _database.transactionsBox.put(map['id'], map);
    }

    final budgets = (content['budgets'] as List<dynamic>? ?? []);
    for (final item in budgets.cast<Map<dynamic, dynamic>>()) {
      final map = Map<String, dynamic>.from(item);
      await _database.budgetsBox.put(map['id'], map);
    }

    final settings = Map<String, dynamic>.from(content['settings'] as Map? ?? {});
    for (final entry in settings.entries) {
      await _database.settingsBox.put(entry.key, entry.value);
    }
    return true;
  }

  Future<File> _localFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }
}
