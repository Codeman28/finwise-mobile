// models.dart
// ---------------------------------------------------------------------------
// The "shapes" of the data: a transaction, a budget, a savings goal, and the
// list of categories.
//
// Each model can turn itself into a Map (toJson) so it can be saved on the
// phone, and be rebuilt from that Map (fromJson) when the app starts again.
// ---------------------------------------------------------------------------

import 'dart:math';

import 'package:flutter/material.dart';

/// Short random id like "k3f9x2", used to find an item again later.
String newId() {
  const letters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final buffer = StringBuffer();
  for (var i = 0; i < 10; i++) {
    buffer.write(letters[random.nextInt(letters.length)]);
  }
  return buffer.toString();
}

/// The three 50/30/20 groups every expense belongs to.
enum SpendGroup { need, want, savings }

/// Information about one category: its name, icon and 50/30/20 group.
class CategoryInfo {
  const CategoryInfo(this.name, this.icon, this.group);
  final String name;
  final IconData icon;
  final SpendGroup group;
}

/// All categories, in the order they appear in pickers.
class Categories {
  Categories._();

  static const savings = 'Tiết kiệm';

  static const expense = <CategoryInfo>[
    CategoryInfo('Ăn uống', Icons.ramen_dining_rounded, SpendGroup.need),
    CategoryInfo('Nhà ở', Icons.home_rounded, SpendGroup.need),
    CategoryInfo('Đi lại', Icons.two_wheeler_rounded, SpendGroup.need),
    CategoryInfo('Hóa đơn', Icons.bolt_rounded, SpendGroup.need),
    CategoryInfo('Học tập', Icons.school_rounded, SpendGroup.need),
    CategoryInfo('Sức khỏe', Icons.favorite_rounded, SpendGroup.need),
    CategoryInfo('Cà phê & trà sữa', Icons.local_cafe_rounded, SpendGroup.want),
    CategoryInfo('Mua sắm', Icons.shopping_bag_rounded, SpendGroup.want),
    CategoryInfo('Giải trí', Icons.sports_esports_rounded, SpendGroup.want),
    CategoryInfo('Du lịch', Icons.flight_takeoff_rounded, SpendGroup.want),
    CategoryInfo('Quà tặng', Icons.redeem_rounded, SpendGroup.want),
    CategoryInfo(savings, Icons.savings_rounded, SpendGroup.savings),
    CategoryInfo('Khác', Icons.more_horiz_rounded, SpendGroup.want),
  ];

  static const income = <CategoryInfo>[
    CategoryInfo('Lương', Icons.work_rounded, SpendGroup.need),
    CategoryInfo('Làm thêm', Icons.laptop_mac_rounded, SpendGroup.need),
    CategoryInfo('Tiền tiêu vặt', Icons.account_balance_wallet_rounded, SpendGroup.need),
    CategoryInfo('Lì xì & quà', Icons.card_giftcard_rounded, SpendGroup.need),
    CategoryInfo('Kinh doanh nhỏ', Icons.storefront_rounded, SpendGroup.need),
    CategoryInfo('Thu nhập khác', Icons.add_card_rounded, SpendGroup.need),
  ];

  /// Categories you can set a budget for (you never "limit" savings).
  static List<String> get budgetable {
    return expense.where((c) => c.name != savings).map((c) => c.name).toList();
  }

  /// Looks a category up by name in both lists. Unknown names get "Khác".
  static CategoryInfo find(String name) {
    for (final c in expense) {
      if (c.name == name) {
        return c;
      }
    }
    for (final c in income) {
      if (c.name == name) {
        return c;
      }
    }
    return expense.last; // "Khác"
  }

  static SpendGroup groupOf(String name) => find(name).group;
}

/// One movement of money: income (money in) or expense (money out).
class Txn {
  Txn({
    String? id,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.category,
    this.note = '',
  }) : id = id ?? newId();

  final String id;
  final DateTime date;
  final double amount; // always positive; isIncome tells the direction
  final bool isIncome;
  final String category;
  final String note;

  /// What to show in lists: the note, or the category if there is no note.
  String get title => note.trim().isEmpty ? category : note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'isIncome': isIncome,
        'category': category,
        'note': note,
      };

  factory Txn.fromJson(Map<String, dynamic> json) {
    return Txn(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['isIncome'] as bool,
      category: json['category'] as String,
      note: (json['note'] as String?) ?? '',
    );
  }
}

/// A monthly spending limit for one category.
class Budget {
  Budget({required this.category, required this.limit});

  final String category;
  double limit;

  Map<String, dynamic> toJson() => {'category': category, 'limit': limit};

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'] as String,
      limit: (json['limit'] as num).toDouble(),
    );
  }
}

/// Something you are saving towards, e.g. "Laptop mới - 20.000.000 ₫".
class Goal {
  Goal({String? id, required this.name, required this.target, this.saved = 0, this.emoji = '🎯'})
      : id = id ?? newId();

  final String id;
  final String name;
  final double target;
  double saved;
  final String emoji;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
        'saved': saved,
        'emoji': emoji,
      };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String?,
      name: json['name'] as String,
      target: (json['target'] as num).toDouble(),
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
      emoji: (json['emoji'] as String?) ?? '🎯',
    );
  }
}
