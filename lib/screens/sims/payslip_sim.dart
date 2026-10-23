// payslip_sim.dart
// ---------------------------------------------------------------------------
// "Đọc phiếu lương" (Lesson 3). From gross salary to take-home pay:
//   gross - insurance (BHXH 8% + BHYT 1.5% + BHTN 1%) - estimated tax = net.
// The stacked bar shows how the gross salary is split.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../core/finance.dart';
import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class PayslipSim extends StatefulWidget {
  const PayslipSim({super.key, required this.state});

  final AppState state;

  @override
  State<PayslipSim> createState() => _PayslipSimState();
}

class _PayslipSimState extends State<PayslipSim> {
  double _gross = 12000000;
  double _dependants = 0;
  final Set<String> _tried = {}; // salary brackets explored, for the mission

  void _onGross(double value) {
    setState(() {
      _gross = value;
      _tried.add(value < 15000000 ? 'low' : (value < 30000000 ? 'mid' : 'high'));
    });
    if (_tried.length >= 3) {
      widget.state.completeMission('payslip');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final slip = payslipFor(_gross, dependants: _dependants.round());

    return SimScaffold(
      state: widget.state,
      title: 'Đọc phiếu lương',
      courseId: 'get-the-job',
      intro: 'Lương gộp là số bạn kiếm được; lương thực nhận là số về tài khoản. '
          'Kéo thanh trượt để xem các khoản bị trừ.',
      children: [
        FinCard(
          child: Column(
            children: [
              LabeledSlider(
                label: 'Lương gộp mỗi tháng',
                value: _gross,
                min: 3000000,
                max: 60000000,
                divisions: 57,
                display: formatVnd(_gross),
                onChanged: _onGross,
              ),
              LabeledSlider(
                label: 'Người phụ thuộc',
                value: _dependants,
                min: 0,
                max: 3,
                divisions: 3,
                display: '${_dependants.round()} người',
                color: fin.coral,
                onChanged: (v) => setState(() => _dependants = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Phiếu lương của bạn'),
              const SizedBox(height: Gaps.md),
              _SplitBar(slip: slip),
              const SizedBox(height: Gaps.lg),
              _Line(label: 'Lương gộp (gross)', value: formatVnd(slip.gross), bold: true),
              _Line(label: 'BHXH 8%', value: '-${formatVnd(slip.gross * 0.08)}', color: fin.coral),
              _Line(label: 'BHYT 1,5%', value: '-${formatVnd(slip.gross * 0.015)}', color: fin.coral),
              _Line(label: 'BHTN 1%', value: '-${formatVnd(slip.gross * 0.01)}', color: fin.coral),
              _Line(label: 'Thuế TNCN (ước tính)', value: '-${formatVnd(slip.tax)}', color: fin.red),
              const Divider(height: Gaps.xl),
              _Line(label: 'Lương thực nhận (net)', value: formatVnd(slip.net), bold: true, color: fin.green),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Text(
          'Thuế chỉ tính trên phần thu nhập vượt mức giảm trừ gia cảnh '
          '(${formatVndCompact(personalDeduction)}/tháng cho bản thân, '
          '${formatVndCompact(dependantDeduction)} cho mỗi người phụ thuộc). '
          'Số liệu mang tính minh họa; quy định thuế có thể thay đổi.',
          style: text.bodySmall,
        ),
        const SizedBox(height: Gaps.lg),
        ScoreBanner(
          emoji: _tried.length >= 3 ? '✅' : '🧾',
          title: _tried.length >= 3 ? 'Bạn đọc phiếu lương rất chuẩn!' : 'Thử thách',
          message: _tried.length >= 3
              ? 'Nhớ nhé: luôn lập ngân sách bằng lương THỰC NHẬN.'
              : 'Thử 3 mức lương: dưới 15 triệu, 15-30 triệu và trên 30 triệu (${_tried.length}/3).',
          good: _tried.length >= 3,
        ),
      ],
    );
  }
}

class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.slip});

  final Payslip slip;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    // flex values must be whole numbers, so use thousandths of the gross.
    int part(double value) => (value / slip.gross * 1000).round().clamp(1, 1000);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 18,
        child: Row(
          children: [
            Expanded(flex: part(slip.net), child: Container(color: fin.green)),
            Expanded(flex: part(slip.insurance), child: Container(color: fin.coral)),
            if (slip.tax > 0) Expanded(flex: part(slip.tax), child: Container(color: fin.red)),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.bold = false, this.color});

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = bold ? text.titleSmall : text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style?.copyWith(color: color, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
