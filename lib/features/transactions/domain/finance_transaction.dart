import 'package:expensetracker/features/transactions/domain/finance_category.dart';

enum TransactionType { income, expense }

enum Recurrence { none, daily, weekly, monthly }

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes = '',
    this.receiptPath,
    this.isFavorite = false,
    this.recurrence = Recurrence.none,
    this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final FinanceCategory category;
  final DateTime date;
  final String notes;
  final String? receiptPath;
  final bool isFavorite;
  final Recurrence recurrence;
  final DateTime? createdAt;

  FinanceTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    FinanceCategory? category,
    DateTime? date,
    String? notes,
    String? receiptPath,
    bool? isFavorite,
    Recurrence? recurrence,
    DateTime? createdAt,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
      isFavorite: isFavorite ?? this.isFavorite,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category.name,
        'date': date.toIso8601String(),
        'notes': notes,
        'receiptPath': receiptPath,
        'isFavorite': isFavorite,
        'recurrence': recurrence.name,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory FinanceTransaction.fromJson(Map<dynamic, dynamic> json) {
    return FinanceTransaction(
      id: json['id'] as String,
      title: (json['title'] ?? 'Untitled') as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: categoryFromName((json['category'] ?? 'other') as String),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      notes: (json['notes'] ?? '') as String,
      receiptPath: json['receiptPath'] as String?,
      isFavorite: (json['isFavorite'] ?? false) as bool,
      recurrence: Recurrence.values.firstWhere(
        (item) => item.name == json['recurrence'],
        orElse: () => Recurrence.none,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
