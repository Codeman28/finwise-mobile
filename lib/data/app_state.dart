// app_state.dart
// ---------------------------------------------------------------------------
// AppState is the app's "wallet + notebook".
//
//   * Screens READ from it to draw themselves.
//   * Screens ask it to CHANGE things (add a transaction, set a budget...).
//   * After every change it:
//       1. saves itself to the phone (if it has a Storage), and
//       2. calls notifyListeners(), which makes every screen that listens
//          rebuild with the new numbers.
//
// The practice area creates a second AppState WITHOUT storage - a "sandbox"
// wallet with pretend money that is never saved. Because screens only talk to
// an AppState, the same screens work for real and pretend money.
// ---------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'storage.dart';

class AppState extends ChangeNotifier {
  AppState({this.storage});

  /// Where data is saved. `null` = sandbox (nothing is ever written).
  final Storage? storage;

  final List<Txn> _txns = [];
  final List<Budget> _budgets = [];
  final List<Goal> _goals = [];
  final Set<String> _completedLessons = {};
  final Set<String> _completedMissions = {};

  // Read-only views, so screens cannot change the lists by accident.
  List<Txn> get txns => List.unmodifiable(_txns);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<Goal> get goals => List.unmodifiable(_goals);
  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);
  Set<String> get completedMissions => Set.unmodifiable(_completedMissions);

  bool get isSandbox => storage == null;
  bool get isEmpty => _txns.isEmpty && _budgets.isEmpty && _goals.isEmpty;

  /// Transactions newest first (like a bank statement).
  List<Txn> get txnsNewestFirst {
    final copy = List<Txn>.of(_txns);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  // =========================================================================
  // Loading and saving
  // =========================================================================

  /// Creates an AppState and fills it from storage.
  /// Throws [FormatException] if the saved data is damaged - the app then
  /// shows an error screen with a "start fresh" button.
  static Future<AppState> load(Storage storage) async {
    final state = AppState(storage: storage);
    final raw = await storage.read();
    if (raw != null && raw.isNotEmpty) {
      state._fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return state;
  }

  void _fromJson(Map<String, dynamic> json) {
    List<dynamic> listOf(String key) => (json[key] as List<dynamic>?) ?? const [];

    _txns
      ..clear()
      ..addAll(listOf('txns').map((e) => Txn.fromJson(e as Map<String, dynamic>)));
    _budgets
      ..clear()
      ..addAll(listOf('budgets').map((e) => Budget.fromJson(e as Map<String, dynamic>)));
    _goals
      ..clear()
      ..addAll(listOf('goals').map((e) => Goal.fromJson(e as Map<String, dynamic>)));
    _completedLessons
      ..clear()
      ..addAll(listOf('lessons').cast<String>());
    _completedMissions
      ..clear()
      ..addAll(listOf('missions').cast<String>());
  }

  Map<String, dynamic> _toJson() => {
        'version': 1,
        'txns': _txns.map((t) => t.toJson()).toList(),
        'budgets': _budgets.map((b) => b.toJson()).toList(),
        'goals': _goals.map((g) => g.toJson()).toList(),
        'lessons': _completedLessons.toList(),
        'missions': _completedMissions.toList(),
      };

  /// Saves (if not a sandbox) and tells every listening screen to rebuild.
  void _changed() {
    final store = storage;
    if (store != null) {
      // Saving takes a few milliseconds; we don't make the UI wait for it.
      store.write(jsonEncode(_toJson()));
    }
    notifyListeners();
  }

  // =========================================================================
  // Transactions
  // =========================================================================

  void addTxn(Txn txn) {
    _txns.add(txn);
    _changed();
  }

  /// Removes a transaction and returns it, so the screen can offer "Hoàn tác".
  Txn? deleteTxn(String id) {
    final index = _txns.indexWhere((t) => t.id == id);
    if (index == -1) {
      return null;
    }
    final removed = _txns.removeAt(index);
    _changed();
    return removed;
  }

  // =========================================================================
  // Budgets (one per category - saving again replaces the limit)
  // =========================================================================

  void setBudget(String category, double limit) {
    final existing = _budgets.where((b) => b.category == category);
    if (existing.isNotEmpty) {
      existing.first.limit = limit;
    } else {
      _budgets.add(Budget(category: category, limit: limit));
    }
    _changed();
  }

  void removeBudget(String category) {
    _budgets.removeWhere((b) => b.category == category);
    _changed();
  }

  // =========================================================================
  // Goals
  // =========================================================================

  void addGoal(Goal goal) {
    _goals.add(goal);
    _changed();
  }

  /// Puts money into a goal. It is also recorded as a "Tiết kiệm" expense,
  /// so it leaves your spendable balance - like moving cash into a savings
  /// account at the bank.
  void contributeToGoal(String goalId, double amount) {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    goal.saved += amount;
    _txns.add(Txn(
      date: DateTime.now(),
      amount: amount,
      isIncome: false,
      category: Categories.savings,
      note: 'Để dành: ${goal.name}',
    ));
    _changed();
  }

  void deleteGoal(String goalId) {
    _goals.removeWhere((g) => g.id == goalId);
    _changed();
  }

  // =========================================================================
  // Learning progress
  // =========================================================================

  void completeLesson(String lessonId) {
    if (_completedLessons.add(lessonId)) {
      _changed();
    }
  }

  void completeMission(String missionId) {
    if (_completedMissions.add(missionId)) {
      _changed();
    }
  }

  // =========================================================================
  // Housekeeping
  // =========================================================================

  /// Deletes money data but keeps learning progress.
  void resetMoney() {
    _txns.clear();
    _budgets.clear();
    _goals.clear();
    _changed();
  }

  /// Replaces everything with an empty wallet (used by the error screen).
  void resetAll() {
    _completedLessons.clear();
    _completedMissions.clear();
    resetMoney();
  }

  /// Three months of realistic example data for a student / first job.
  void loadSampleData({DateTime? today}) {
    final now = today ?? DateTime.now();

    // (day of month, note, amount, isIncome, category)
    const pattern = <(int, String, double, bool, String)>[
      (1, 'Lương part-time', 6500000, true, 'Lương'),
      (1, 'Tiền tiêu vặt bố mẹ cho', 2000000, true, 'Tiền tiêu vặt'),
      (2, 'Tiền phòng trọ', 2500000, false, 'Nhà ở'),
      (4, 'Đi chợ tuần 1', 450000, false, 'Ăn uống'),
      (6, 'Đổ xăng', 120000, false, 'Đi lại'),
      (8, 'Điện nước + wifi', 380000, false, 'Hóa đơn'),
      (9, 'Trà sữa với bạn', 90000, false, 'Cà phê & trà sữa'),
      (11, 'Đi chợ tuần 2', 420000, false, 'Ăn uống'),
      (13, 'Xem phim', 150000, false, 'Giải trí'),
      (15, 'Bán đồ handmade', 800000, true, 'Kinh doanh nhỏ'),
      (16, 'Áo khoác mới', 350000, false, 'Mua sắm'),
      (18, 'Đi chợ tuần 3', 460000, false, 'Ăn uống'),
      (20, 'Sách luyện thi', 180000, false, 'Học tập'),
      (22, 'Cà phê học nhóm', 75000, false, 'Cà phê & trà sữa'),
      (25, 'Đi chợ tuần 4', 400000, false, 'Ăn uống'),
    ];

    for (var monthsBack = 2; monthsBack >= 0; monthsBack--) {
      for (final (day, note, amount, isIncome, category) in pattern) {
        final date = DateTime(now.year, now.month - monthsBack, day, 12);
        if (date.isAfter(now)) {
          continue; // never create transactions in the future
        }
        _txns.add(Txn(date: date, amount: amount, isIncome: isIncome, category: category, note: note));
      }
    }

    _budgets
      ..clear()
      ..addAll([
        Budget(category: 'Ăn uống', limit: 2000000),
        Budget(category: 'Cà phê & trà sữa', limit: 200000),
        Budget(category: 'Mua sắm', limit: 500000),
        Budget(category: 'Giải trí', limit: 300000),
      ]);

    _goals
      ..clear()
      ..addAll([
        Goal(name: 'Quỹ khẩn cấp', target: 10000000, saved: 3500000, emoji: '🛟'),
        Goal(name: 'Laptop cho đại học', target: 18000000, saved: 4200000, emoji: '💻'),
      ]);
    _changed();
  }
}
