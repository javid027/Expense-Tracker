import 'package:flutter/material.dart';

enum FinanceCategory {
  food('Food', Icons.restaurant_rounded, Color(0xFFFF7A59)),
  transport('Transport', Icons.directions_car_rounded, Color(0xFF45A3FF)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFF7C5CFF)),
  bills('Bills', Icons.receipt_long_rounded, Color(0xFFFFC857)),
  health('Health', Icons.favorite_rounded, Color(0xFFEF476F)),
  travel('Travel', Icons.flight_takeoff_rounded, Color(0xFF06D6A0)),
  salary('Salary', Icons.payments_rounded, Color(0xFF37D6A3)),
  investment('Investment', Icons.trending_up_rounded, Color(0xFF2EC4B6)),
  other('Other', Icons.more_horiz_rounded, Color(0xFF9AA4B2));

  const FinanceCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

FinanceCategory categoryFromName(String value) {
  return FinanceCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => FinanceCategory.other,
  );
}
