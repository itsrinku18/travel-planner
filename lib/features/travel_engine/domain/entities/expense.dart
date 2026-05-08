import 'package:equatable/equatable.dart';

enum ExpenseCategory { transport, stay, food, activities, shopping, other }

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, amount, category, createdAt];
}
