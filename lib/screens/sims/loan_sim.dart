// loan_sim.dart
// ---------------------------------------------------------------------------
// "Mua xe trả góp" (Lesson 6), based on the toolkit's Auto Loan worksheet.
//
// Pick a vehicle and a down payment. The comparison table shows every loan
// term side by side. Like the worksheet, longer terms have higher interest
// rates: the monthly payment falls, but the total cost rises.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../core/finance.dart';
import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class _Vehicle {
  const _Vehicle(this.name, this.emoji, this.price);
  final String name;
  final String emoji;
  final double price;
}

/// (months, yearly interest rate %) - rates rise with the term.
const _terms = <(int, double)>[(12, 10), (24, 11), (36, 12), (48, 13), (60, 14)];

class LoanSim extends StatefulWidget {
  const LoanSim({super.key, required this.state});

  final AppState state;

  @override
  State<LoanSim> createState() => _LoanSimState();
}

class _LoanSimState extends State<LoanSim> {
  static const _vehicles = [
    _Vehicle('Xe số', '🛵', 22000000),
    _Vehicle('Xe tay ga', '🏍️', 45000000),
    _Vehicle('Xe điện', '⚡', 32000000),
    _Vehicle('Ô tô nhỏ', '🚗', 450000000),
  ];

  int _vehicle = 1;
  double _downPercent = 20;
  int _selectedTerm = 2; // 36 months
  final Set<int> _viewedTerms = {2};

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final vehicle = _vehicles[_vehicle];
    final down = vehicle.price * _downPercent / 100;
    final principal = vehicle.price - down;

    final results = [
      for (final (months, rate) in _terms)
        loanPayment(principal: principal, yearlyRatePercent: rate, months: months),
    ];
    final chosen = results[_selectedTerm];

    // Mission: compare at least 3 different terms.
    if (_viewedTerms.length >= 3) {
      completeMissionAfterBuild(widget.state, 'loan');
    }

    return SimScaffold(
      state: widget.state,
      title: 'Mua xe trả góp',
      courseId: 'buy-vehicle',
      intro: 'Chọn xe và tiền trả trước. So sánh các kỳ hạn để thấy cái giá thật của việc trả góp.',
      children: [
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(width: Gaps.sm),
            itemBuilder: (context, i) => _VehicleChip(
              vehicle: _vehicles[i],
              selected: i == _vehicle,
              onTap: () => setState(() => _vehicle = i),
            ),
          ),
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            children: [
              LabeledSlider(
                label: 'Trả trước',
                value: _downPercent,
                min: 0,
                max: 80,
                divisions: 16,
                display: '${_downPercent.round()}% · ${formatVndCompact(down)}',
                onChanged: (v) => setState(() => _downPercent = v),
              ),
              Row(
                children: [
                  Expanded(child: Text('Số tiền vay', style: text.bodyMedium)),
                  Text(formatVnd(principal), style: text.titleSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Text('Chọn kỳ hạn', style: text.labelMedium),
        const SizedBox(height: Gaps.sm),
        Wrap(
          spacing: Gaps.sm,
          runSpacing: Gaps.sm,
          children: [
            for (var i = 0; i < _terms.length; i++)
              ChoiceChip(
                label: Text('${_terms[i].$1} tháng · ${_terms[i].$2.round()}%'),
                selected: i == _selectedTerm,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _selectedTerm = i;
                  _viewedTerms.add(i);
                }),
              ),
          ],
        ),
        const SizedBox(height: Gaps.lg),
        Row(
          children: [
            Expanded(child: StatTile(label: 'Trả mỗi tháng', value: formatVnd(chosen.monthlyPayment), color: fin.green)),
            const SizedBox(width: Gaps.sm),
            Expanded(child: StatTile(label: 'Tổng tiền lãi', value: formatVnd(chosen.totalInterest), color: fin.red)),
          ],
        ),
        const SizedBox(height: Gaps.sm),
        StatTile(
          label: 'Tổng chi phí thật (trả trước + tất cả kỳ trả góp)',
          value: formatVnd(down + chosen.totalPaid),
          color: fin.coral,
          hint: 'Cao hơn giá xe ${formatVnd(down + chosen.totalPaid - vehicle.price)}',
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Bảng so sánh', subtitle: 'Kỳ hạn dài: nhẹ mỗi tháng, đắt tổng thể'),
              const SizedBox(height: Gaps.md),
              _CompareTable(results: results, selected: _selectedTerm, down: down),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        ScoreBanner(
          emoji: _viewedTerms.length >= 3 ? '✅' : '🔍',
          title: _viewedTerms.length >= 3 ? 'Bạn đã biết so sánh!' : 'Thử thách',
          message: _viewedTerms.length >= 3
              ? 'Luôn "đi chợ" khoản vay trước khi đi chọn xe, và nhớ cộng cả xăng, bảo hiểm, bảo dưỡng.'
              : 'Chọn ít nhất 3 kỳ hạn khác nhau để so sánh (đã xem ${_viewedTerms.length}/3).',
          good: _viewedTerms.length >= 3,
        ),
      ],
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({required this.vehicle, required this.selected, required this.onTap});

  final _Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 116,
        padding: const EdgeInsets.all(Gaps.md),
        decoration: BoxDecoration(
          color: selected ? fin.greenSoft : fin.surface,
          borderRadius: BorderRadius.circular(Gaps.radius),
          border: Border.all(color: selected ? fin.green : fin.border, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vehicle.emoji, style: const TextStyle(fontSize: 22)),
            const Spacer(),
            Text(vehicle.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(formatVndCompact(vehicle.price), style: Theme.of(context).textTheme.bodySmall, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.results, required this.selected, required this.down});

  final List<LoanResult> results;
  final int selected;
  final double down;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;

    Widget cell(String value, {bool bold = false, TextAlign align = TextAlign.right}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(value, textAlign: align, style: bold ? text.labelMedium : text.bodySmall?.copyWith(color: fin.text)),
      );
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(1.1), 1: FlexColumnWidth(1.3), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1.3)},
      children: [
        TableRow(children: [
          cell('Kỳ hạn', bold: true, align: TextAlign.left),
          cell('Mỗi tháng', bold: true),
          cell('Tiền lãi', bold: true),
          cell('Tổng chi phí', bold: true),
        ]),
        for (var i = 0; i < results.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i == selected ? fin.greenSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              cell('${_terms[i].$1}th', align: TextAlign.left),
              cell(formatVndCompact(results[i].monthlyPayment)),
              cell(formatVndCompact(results[i].totalInterest)),
              cell(formatVndCompact(down + results[i].totalPaid)),
            ],
          ),
      ],
    );
  }
}
