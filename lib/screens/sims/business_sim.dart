// business_sim.dart
// ---------------------------------------------------------------------------
// "Kế hoạch kinh doanh" (Lesson 4), from the toolkit's Business Plan
// template's "Projected Budget" box:
//   profit per item = price - cost per item
//   break-even      = start-up cost ÷ profit per item (rounded up)
// Pick a starter idea, then tune the numbers.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class _Idea {
  const _Idea(this.name, this.emoji, this.startCost, this.unitCost, this.price, this.perMonth);
  final String name;
  final String emoji;
  final double startCost;
  final double unitCost;
  final double price;
  final double perMonth;
}

class BusinessSim extends StatefulWidget {
  const BusinessSim({super.key, required this.state});

  final AppState state;

  @override
  State<BusinessSim> createState() => _BusinessSimState();
}

class _BusinessSimState extends State<BusinessSim> {
  static const _ideas = [
    _Idea('Móc khóa handmade', '🧶', 600000, 15000, 45000, 30),
    _Idea('Gia sư Toán', '📐', 200000, 20000, 150000, 16),
    _Idea('Bánh flan', '🍮', 800000, 6000, 15000, 150),
    _Idea('In áo thun', '👕', 3000000, 90000, 180000, 20),
  ];

  int _idea = 0;
  late double _startCost = _ideas[0].startCost;
  late double _unitCost = _ideas[0].unitCost;
  late double _price = _ideas[0].price;
  late double _perMonth = _ideas[0].perMonth;

  void _choose(int index) {
    final idea = _ideas[index];
    setState(() {
      _idea = index;
      _startCost = idea.startCost;
      _unitCost = idea.unitCost;
      _price = idea.price;
      _perMonth = idea.perMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final profitPerUnit = _price - _unitCost;
    final monthlyProfit = profitPerUnit * _perMonth;
    final losing = profitPerUnit <= 0;

    // Break-even: how many items until the start-up cost is paid back.
    int? breakEvenUnits;
    double? breakEvenMonths;
    if (!losing) {
      breakEvenUnits = (_startCost / profitPerUnit).ceil();
      breakEvenMonths = _perMonth > 0 ? breakEvenUnits / _perMonth : null;
    }

    final recoversInThreeMonths = breakEvenMonths != null && breakEvenMonths <= 3;
    if (recoversInThreeMonths) {
      completeMissionAfterBuild(widget.state, 'business');
    }

    return SimScaffold(
      state: widget.state,
      title: 'Kế hoạch kinh doanh',
      courseId: 'entrepreneur',
      intro: 'Chọn một ý tưởng rồi chỉnh các con số. Mục tiêu: thu hồi vốn trong 3 tháng.',
      children: [
        Wrap(
          spacing: Gaps.sm,
          runSpacing: Gaps.sm,
          children: [
            for (var i = 0; i < _ideas.length; i++)
              ChoiceChip(
                label: Text('${_ideas[i].emoji} ${_ideas[i].name}'),
                selected: i == _idea,
                showCheckmark: false,
                onSelected: (_) => _choose(i),
              ),
          ],
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            children: [
              LabeledSlider(
                label: 'Vốn ban đầu',
                value: _startCost,
                min: 0,
                max: 5000000,
                divisions: 50,
                display: formatVnd(_startCost),
                onChanged: (v) => setState(() => _startCost = v),
              ),
              LabeledSlider(
                label: 'Chi phí mỗi sản phẩm',
                value: _unitCost,
                min: 0,
                max: 200000,
                divisions: 40,
                display: formatVnd(_unitCost),
                color: fin.red,
                onChanged: (v) => setState(() => _unitCost = v),
              ),
              LabeledSlider(
                label: 'Giá bán',
                value: _price,
                min: 5000,
                max: 300000,
                divisions: 59,
                display: formatVnd(_price),
                color: fin.coral,
                onChanged: (v) => setState(() => _price = v),
              ),
              LabeledSlider(
                label: 'Bán được mỗi tháng',
                value: _perMonth,
                min: 0,
                max: 200,
                divisions: 40,
                display: '${_perMonth.round()} sản phẩm',
                onChanged: (v) => setState(() => _perMonth = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Lãi mỗi sản phẩm',
                value: formatVnd(profitPerUnit),
                color: losing ? fin.red : fin.green,
              ),
            ),
            const SizedBox(width: Gaps.sm),
            Expanded(
              child: StatTile(
                label: 'Lợi nhuận/tháng',
                value: formatVndCompact(monthlyProfit),
                color: monthlyProfit > 0 ? fin.green : fin.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gaps.sm),
        StatTile(
          label: 'Điểm hòa vốn',
          value: losing ? 'Không bao giờ' : '$breakEvenUnits sản phẩm',
          color: fin.coral,
          hint: losing
              ? 'Giá bán phải cao hơn chi phí mỗi sản phẩm!'
              : (breakEvenMonths == null
                  ? 'Cần bán được hàng để thu hồi vốn'
                  : 'Khoảng ${breakEvenMonths.toStringAsFixed(1).replaceAll('.', ',')} tháng để thu hồi vốn'),
        ),
        const SizedBox(height: Gaps.lg),
        ScoreBanner(
          emoji: recoversInThreeMonths ? '🚀' : '📋',
          title: recoversInThreeMonths ? 'Kế hoạch khả thi!' : 'Thử thách',
          message: recoversInThreeMonths
              ? 'Tiếp theo: tìm hiểu khách hàng và đối thủ trước khi bắt đầu thật.'
              : 'Điều chỉnh giá, chi phí hoặc số lượng để thu hồi vốn trong tối đa 3 tháng.',
          good: recoversInThreeMonths,
        ),
      ],
    );
  }
}
