import 'package:expensetracker/features/transactions/domain/finance_category.dart';

class Budget {
  const Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
  });

  final String id;
  final FinanceCategory category;
  final double monthlyLimit;

  Budget copyWith({String? id, FinanceCategory? category, double? monthlyLimit}) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'monthlyLimit': monthlyLimit,
      };

  factory Budget.fromJson(Map<dynamic, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      category: categoryFromName((json['category'] ?? 'other') as String),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}
