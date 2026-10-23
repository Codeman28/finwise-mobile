// finance.dart
// ---------------------------------------------------------------------------
// All the money maths, with NO user-interface code.
//
// Keeping calculations separate from screens means:
//   * each function can be tested on its own (see test/finance_test.dart),
//   * the real wallet and the practice simulators use the SAME maths.
//
// Every function takes plain inputs and returns a result. None of them
// change anything - they only calculate.
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import '../data/models.dart';

/// A budget is "careful" from 80% used, "over" above 100%.
const double warningLevel = 0.8;

// ===========================================================================
// Totals
// ===========================================================================

/// Only the transactions that happened in the same month as [month].
List<Txn> inMonth(List<Txn> all, DateTime month) {
  return all
      .where((t) => t.date.year == month.year && t.date.month == month.month)
      .toList();
}

double totalIncome(List<Txn> txns) {
  var total = 0.0;
  for (final t in txns) {
    if (t.isIncome) {
      total += t.amount;
    }
  }
  return total;
}

double totalExpense(List<Txn> txns) {
  var total = 0.0;
  for (final t in txns) {
    if (!t.isIncome) {
      total += t.amount;
    }
  }
  return total;
}

/// Money you have = everything in - everything out.
double balanceOf(List<Txn> txns) => totalIncome(txns) - totalExpense(txns);

/// Share of income that was NOT spent (0.0 - 1.0).
///
/// Money moved into the "Tiết kiệm" (savings) category still belongs to
/// you, so it counts as saved, not spent.
double savingsRate(List<Txn> txns) {
  final income = totalIncome(txns);
  if (income <= 0) {
    return 0; // no income yet -> avoid dividing by zero
  }
  var spent = 0.0;
  for (final t in txns) {
    final isRealSpending = !t.isIncome && t.category != Categories.savings;
    if (isRealSpending) {
      spent += t.amount;
    }
  }
  final rate = (income - spent) / income;
  return rate.clamp(0.0, 1.0);
}

/// {category: total spent}, biggest first.
Map<String, double> spendingByCategory(List<Txn> txns) {
  final totals = <String, double>{};
  for (final t in txns) {
    if (t.isIncome) {
      continue;
    }
    totals[t.category] = (totals[t.category] ?? 0) + t.amount;
  }
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // largest amount first
  return Map.fromEntries(entries);
}

/// Splits spending into the 50/30/20 groups: need / want / savings.
Map<SpendGroup, double> spendingByGroup(List<Txn> txns) {
  final groups = {SpendGroup.need: 0.0, SpendGroup.want: 0.0, SpendGroup.savings: 0.0};
  for (final t in txns) {
    if (t.isIncome) {
      continue;
    }
    final group = Categories.groupOf(t.category);
    groups[group] = groups[group]! + t.amount;
  }
  return groups;
}

/// One bar of the "last 6 months" chart.
class MonthTotals {
  const MonthTotals(this.month, this.income, this.expense);
  final DateTime month;
  final double income;
  final double expense;
}

/// Income and expenses for each of the last [count] months, oldest first.
List<MonthTotals> monthlyHistory(List<Txn> all, {int count = 6, DateTime? today}) {
  final now = today ?? DateTime.now();
  final result = <MonthTotals>[];
  for (var back = count - 1; back >= 0; back--) {
    // DateTime handles month 0 or negative months by rolling into last year,
    // e.g. DateTime(2026, 0) is December 2025.
    final month = DateTime(now.year, now.month - back);
    final txns = inMonth(all, month);
    result.add(MonthTotals(month, totalIncome(txns), totalExpense(txns)));
  }
  return result;
}

// ===========================================================================
// Budgets and goals
// ===========================================================================

enum BudgetState { ok, warning, over }

class BudgetStatus {
  const BudgetStatus({required this.budget, required this.spent});

  final Budget budget;
  final double spent;

  double get limit => budget.limit;
  double get remaining => budget.limit - spent;
  double get ratio => budget.limit > 0 ? spent / budget.limit : 0;

  BudgetState get state {
    if (ratio > 1) {
      return BudgetState.over;
    }
    if (ratio >= warningLevel) {
      return BudgetState.warning;
    }
    return BudgetState.ok;
  }
}

/// How much of each budget was used in the given month's transactions.
BudgetStatus budgetStatus(Budget budget, List<Txn> monthTxns) {
  var spent = 0.0;
  for (final t in monthTxns) {
    if (!t.isIncome && t.category == budget.category) {
      spent += t.amount;
    }
  }
  return BudgetStatus(budget: budget, spent: spent);
}

/// Share of a goal already saved, never above 100%.
double goalProgress(Goal goal) {
  if (goal.target <= 0) {
    return 1;
  }
  return (goal.saved / goal.target).clamp(0.0, 1.0);
}

// ===========================================================================
// Growing money and borrowing money
// ===========================================================================

/// One point per year of a savings simulation.
class GrowthPoint {
  const GrowthPoint(this.year, this.balance, this.deposited);
  final int year;
  final double balance;
  final double deposited; // money YOU put in; balance - deposited = interest

  double get interest => balance - deposited;
}

/// Compound interest, month by month. Each month:
///   1. the balance earns interest (yearly rate / 12),
///   2. then you add your monthly deposit.
List<GrowthPoint> compoundGrowth({
  required double start,
  required double monthly,
  required double yearlyRatePercent,
  required int years,
}) {
  final monthlyRate = yearlyRatePercent / 100 / 12;
  var balance = start;
  var deposited = start;
  final points = <GrowthPoint>[GrowthPoint(0, balance, deposited)];

  for (var year = 1; year <= years; year++) {
    for (var month = 0; month < 12; month++) {
      balance += balance * monthlyRate; // step 1: interest
      balance += monthly; // step 2: deposit
      deposited += monthly;
    }
    points.add(GrowthPoint(year, balance, deposited));
  }
  return points;
}

/// "Rule of 72" from the toolkit: years to double = 72 / interest rate.
double ruleOf72(double yearlyRatePercent) {
  if (yearlyRatePercent <= 0) {
    return double.infinity;
  }
  return 72 / yearlyRatePercent;
}

/// Exact years to double with yearly compounding, to compare with the rule.
double exactDoublingYears(double yearlyRatePercent) {
  if (yearlyRatePercent <= 0) {
    return double.infinity;
  }
  return math.log(2) / math.log(1 + yearlyRatePercent / 100);
}

/// Result of a fixed-payment loan (car, motorbike, phone instalment ...).
class LoanResult {
  const LoanResult({required this.monthlyPayment, required this.totalPaid, required this.principal});
  final double monthlyPayment;
  final double totalPaid;
  final double principal;

  double get totalInterest => totalPaid - principal;
}

/// Standard loan (amortisation) formula:
///
///   payment = P * r / (1 - (1 + r)^-n)
///
///   P = amount borrowed, r = monthly interest rate, n = number of months.
/// With 0% interest it is simply P / n.
LoanResult loanPayment({required double principal, required double yearlyRatePercent, required int months}) {
  if (months <= 0 || principal <= 0) {
    return LoanResult(monthlyPayment: 0, totalPaid: 0, principal: math.max(principal, 0));
  }
  final r = yearlyRatePercent / 100 / 12;
  double payment;
  if (r == 0) {
    payment = principal / months;
  } else {
    payment = principal * r / (1 - math.pow(1 + r, -months));
  }
  return LoanResult(monthlyPayment: payment, totalPaid: payment * months, principal: principal);
}

/// Result of paying off a credit card with a fixed monthly payment.
class PayoffResult {
  const PayoffResult({this.months, this.totalInterest});

  /// null means "never" - the payment does not even cover the interest.
  final int? months;
  final double? totalInterest;

  bool get isTrap => months == null;
}

/// Month by month: add interest, subtract the payment, until the debt is 0.
PayoffResult creditCardPayoff({
  required double debt,
  required double yearlyRatePercent,
  required double monthlyPayment,
  int maxMonths = 600,
}) {
  final r = yearlyRatePercent / 100 / 12;
  var remaining = debt;
  var interestPaid = 0.0;
  var months = 0;

  while (remaining > 0) {
    final interest = remaining * r;
    if (monthlyPayment <= interest) {
      return const PayoffResult(); // the classic debt trap
    }
    interestPaid += interest;
    remaining = remaining + interest - monthlyPayment;
    months++;
    if (months >= maxMonths) {
      return const PayoffResult();
    }
  }
  return PayoffResult(months: months, totalInterest: interestPaid);
}

/// Vietnamese employee payslip (Lesson 3): from gross salary to take-home pay.
///
/// Compulsory insurance paid by the employee (Luật BHXH):
///   BHXH 8% + BHYT 1.5% + BHTN 1% = 10.5% of the insured salary.
/// Personal income tax is an ESTIMATE for learning: it is only charged on the
/// part above the family deduction, using progressive brackets. Tax rules
/// change - update [personalDeduction], [dependantDeduction] and the brackets
/// below when the law changes. Real payslips can differ.
const double personalDeduction = 15500000; // giảm trừ gia cảnh bản thân / tháng
const double dependantDeduction = 6200000; // mỗi người phụ thuộc / tháng

class Payslip {
  const Payslip({required this.gross, required this.insurance, required this.tax});
  final double gross;
  final double insurance;
  final double tax;

  double get net => gross - insurance - tax;
}

Payslip payslipFor(double gross, {int dependants = 0}) {
  final insurance = gross * 0.105;
  final deduction = personalDeduction + dependants * dependantDeduction;
  final taxable = math.max(0.0, gross - insurance - deduction);

  // Progressive brackets (monthly): 5% up to 5tr, 10% to 10tr, 15% to 18tr,
  // 20% to 32tr, 25% to 52tr, 30% to 80tr, 35% above.
  const brackets = <List<double>>[
    [5000000, 0.05],
    [10000000, 0.10],
    [18000000, 0.15],
    [32000000, 0.20],
    [52000000, 0.25],
    [80000000, 0.30],
    [double.infinity, 0.35],
  ];

  var tax = 0.0;
  var lowerEdge = 0.0;
  for (final bracket in brackets) {
    final upperEdge = bracket[0];
    final rate = bracket[1];
    if (taxable <= lowerEdge) {
      break;
    }
    final portion = math.min(taxable, upperEdge) - lowerEdge;
    tax += portion * rate;
    lowerEdge = upperEdge;
  }
  return Payslip(gross: gross, insurance: insurance, tax: tax);
}
