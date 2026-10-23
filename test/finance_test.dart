// Unit tests for the money maths and Vietnamese formatting.
// Run with:  flutter test

import 'package:finwise/core/finance.dart';
import 'package:finwise/core/format.dart';
import 'package:finwise/data/app_state.dart';
import 'package:finwise/data/models.dart';
import 'package:finwise/data/storage.dart';
import 'package:flutter_test/flutter_test.dart';

Txn tx(double amount, bool income, String category, {DateTime? date}) {
  return Txn(date: date ?? DateTime(2026, 9, 10), amount: amount, isIncome: income, category: category);
}

void main() {
  group('format', () {
    test('formatVnd uses dots and the ₫ symbol', () {
      expect(formatVnd(1500000), '1.500.000 ₫');
      expect(formatVnd(999), '999 ₫');
      expect(formatVnd(-20000), '-20.000 ₫');
      expect(formatVnd(1500, showPlus: true), '+1.500 ₫');
      expect(formatVnd(1234567, withSymbol: false), '1.234.567');
    });

    test('formatVndCompact', () {
      expect(formatVndCompact(18500000), '18,5tr');
      expect(formatVndCompact(18000000), '18tr');
      expect(formatVndCompact(750000), '750k');
      expect(formatVndCompact(2300000000), '2,3 tỷ');
    });

    test('parseVnd accepts dots and rejects junk', () {
      expect(parseVnd('1.500.000'), 1500000);
      expect(parseVnd('abc'), isNull);
      expect(parseVnd('0'), isNull);
    });

    test('dates are day/month/year', () {
      expect(formatDate(DateTime(2026, 9, 4)), '04/09/2026');
      expect(formatMonth(DateTime(2026, 9, 4)), 'Tháng 9/2026');
      expect(formatRelativeDay(DateTime(2026, 9, 29), today: DateTime(2026, 9, 29)), 'Hôm nay');
    });
  });

  group('finance', () {
    test('balance and savings rate (savings category is not spending)', () {
      final items = [tx(10000000, true, 'Lương'), tx(6000000, false, 'Nhà ở'), tx(2000000, false, Categories.savings)];
      expect(balanceOf(items), 2000000);
      expect(savingsRate(items), closeTo(0.4, 1e-9));
    });

    test('monthly history wraps into the previous year', () {
      final history = monthlyHistory([], count: 3, today: DateTime(2026, 2, 5));
      expect(history.map((m) => m.month.month).toList(), [12, 1, 2]);
      expect(history.first.month.year, 2025);
    });

    test('budget status thresholds', () {
      final spent = [tx(900000, false, 'Ăn uống')];
      expect(budgetStatus(Budget(category: 'Ăn uống', limit: 1000000), spent).state, BudgetState.warning);
      expect(budgetStatus(Budget(category: 'Ăn uống', limit: 500000), spent).state, BudgetState.over);
      expect(budgetStatus(Budget(category: 'Ăn uống', limit: 5000000), spent).state, BudgetState.ok);
    });

    test('compound growth matches the lesson example', () {
      final points = compoundGrowth(start: 10000000, monthly: 0, yearlyRatePercent: 5, years: 10);
      expect(points.last.balance, closeTo(16470095, 50));
    });

    test('rule of 72 from the toolkit', () {
      expect(ruleOf72(8), 9);
      expect(ruleOf72(12), 6);
      expect(exactDoublingYears(8), closeTo(9.006, 0.01));
    });

    test('loan payment matches the course example', () {
      final loan = loanPayment(principal: 35000000, yearlyRatePercent: 12, months: 12);
      expect(loan.monthlyPayment, closeTo(3109700, 1000));
      expect(loan.totalInterest, closeTo(2316000, 5000));
    });

    test('credit card trap is detected', () {
      final trap = creditCardPayoff(debt: 20000000, yearlyRatePercent: 30, monthlyPayment: 500000);
      expect(trap.isTrap, isTrue);
      final ok = creditCardPayoff(debt: 20000000, yearlyRatePercent: 30, monthlyPayment: 2000000);
      expect(ok.months, lessThanOrEqualTo(12));
    });

    test('payslip: insurance is 10.5%, low salaries pay no tax', () {
      final slip = payslipFor(10000000);
      expect(slip.insurance, closeTo(1050000, 1));
      expect(slip.tax, 0);
      expect(slip.net, closeTo(8950000, 1));
    });
  });

  group('AppState', () {
    test('saves to storage and loads back', () async {
      final storage = MemoryStorage();
      final state = AppState(storage: storage);
      state.addTxn(tx(5000000, true, 'Lương'));
      state.addGoal(Goal(name: 'Quỹ khẩn cấp', target: 10000000));
      state.contributeToGoal(state.goals.first.id, 1000000);
      await Future<void>.delayed(Duration.zero);

      final reloaded = await AppState.load(storage);
      expect(reloaded.txns.length, 2); // income + savings transfer
      expect(reloaded.goals.first.saved, 1000000);
    });

    test('damaged data throws so the app can show its error screen', () async {
      final storage = MemoryStorage('{not json');
      expect(() => AppState.load(storage), throwsA(isA<FormatException>()));
    });

    test('sample data never lies in the future', () {
      final state = AppState();
      final today = DateTime(2026, 9, 10);
      state.loadSampleData(today: today);
      expect(state.txns.every((t) => !t.date.isAfter(today)), isTrue);
      expect(state.budgets, isNotEmpty);
    });
  });
}
