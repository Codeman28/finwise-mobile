// bean_game.dart
// ---------------------------------------------------------------------------
// "Trò chơi Hạt đậu" - the toolkit's Bean Game (Lesson 7), localised.
//
//   Phase 1: you have 20 beans (1 bean = 500.000 ₫, so 10 triệu/tháng).
//            Choose ONE option in every category without overspending.
//   Phase 2: twist! A pay cut takes 10 beans away. Re-plan with 10.
//   Phase 3: reflection - what changed and why.
//
// The jar at the top fills bean by bean (AnimatedContainer) as you choose.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

const double _beanValue = 500000; // 1 hạt đậu = 500.000 ₫

class _Option {
  const _Option(this.label, this.beans);
  final String label;
  final int beans;
}

class _Category {
  const _Category(this.name, this.icon, this.options);
  final String name;
  final IconData icon;
  final List<_Option> options;
}

const _categories = [
  _Category('Nhà ở', Icons.home_rounded, [
    _Option('Ở cùng gia đình', 0),
    _Option('Ở ghép với bạn', 3),
    _Option('Thuê phòng riêng', 5),
    _Option('Mua nhà trả góp', 8),
  ]),
  _Category('Đi lại', Icons.two_wheeler_rounded, [
    _Option('Đi bộ / xe đạp', 0),
    _Option('Xe buýt', 1),
    _Option('Xe máy (xăng, bảo dưỡng)', 2),
    _Option('Ô tô riêng', 5),
  ]),
  _Category('Ăn uống', Icons.ramen_dining_rounded, [
    _Option('Tự nấu ở nhà', 2),
    _Option('Nấu + ăn ngoài mỗi tuần', 3),
    _Option('Ăn ngoài mỗi ngày', 5),
  ]),
  _Category('Tiết kiệm', Icons.savings_rounded, [
    _Option('Không tiết kiệm', 0),
    _Option('Tiết kiệm 10%', 2),
    _Option('Tiết kiệm 20%', 4),
  ]),
  _Category('Điện thoại', Icons.smartphone_rounded, [
    _Option('Gói cơ bản', 1),
    _Option('Gói nhiều data', 2),
  ]),
  _Category('Chăm sóc bản thân', Icons.spa_rounded, [
    _Option('Đồ dùng cơ bản', 1),
    _Option('Thêm tập gym', 2),
    _Option('Thêm spa, làm tóc', 3),
  ]),
  _Category('Quần áo', Icons.checkroom_rounded, [
    _Option('Dùng đồ đang có', 0),
    _Option('Đồ giảm giá / secondhand', 1),
    _Option('Hàng hiệu', 3),
  ]),
  _Category('Giải trí', Icons.celebration_rounded, [
    _Option('Hoạt động miễn phí', 0),
    _Option('Xem phim 1 lần/tháng', 1),
    _Option('Concert, sự kiện mỗi tháng', 2),
  ]),
  _Category('Thú cưng', Icons.pets_rounded, [
    _Option('Không nuôi', 0),
    _Option('Cá hoặc chim', 1),
    _Option('Chó hoặc mèo', 2),
  ]),
];

enum _Phase { plan, twist, done }

class BeanGame extends StatefulWidget {
  const BeanGame({super.key, required this.state});

  final AppState state;

  @override
  State<BeanGame> createState() => _BeanGameState();
}

class _BeanGameState extends State<BeanGame> {
  _Phase _phase = _Phase.plan;
  final Map<int, int> _choices = {}; // category index -> option index
  Map<int, int> _firstPlan = {}; // saved when the twist starts

  int get _capacity => _phase == _Phase.plan ? 20 : 10;

  int _beansUsed(Map<int, int> plan) {
    var total = 0;
    plan.forEach((category, option) => total += _categories[category].options[option].beans);
    return total;
  }

  bool get _complete => _choices.length == _categories.length;
  bool get _overBudget => _beansUsed(_choices) > _capacity;

  void _choose(int category, int option) {
    HapticFeedback.selectionClick();
    setState(() => _choices[category] = option);
  }

  void _confirmPlan() {
    if (_phase == _Phase.plan) {
      setState(() {
        _firstPlan = Map.of(_choices);
        _phase = _Phase.twist;
      });
      HapticFeedback.heavyImpact();
      return;
    }
    setState(() => _phase = _Phase.done);
    widget.state.completeMission('bean');
  }

  void _restart() {
    setState(() {
      _phase = _Phase.plan;
      _choices.clear();
      _firstPlan = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final used = _beansUsed(_choices);

    final String ctaLabel;
    if (!_complete) {
      ctaLabel = 'Chọn đủ ${_categories.length} mục (${_choices.length}/${_categories.length})';
    } else if (_overBudget) {
      ctaLabel = 'Vượt ${used - _capacity} hạt - hãy bớt lại';
    } else {
      ctaLabel = _phase == _Phase.plan ? 'Chốt kế hoạch' : 'Chốt kế hoạch mới';
    }

    return SimScaffold(
      state: widget.state,
      title: 'Trò chơi Hạt đậu',
      courseId: 'budgets',
      intro: 'Mỗi hạt đậu = ${formatVnd(_beanValue)}. Chọn MỘT lựa chọn cho mỗi mục mà không vượt số hạt bạn có.',
      bottom: _phase == _Phase.done
          ? null
          : PrimaryCta(
              label: ctaLabel,
              icon: Icons.check_rounded,
              onPressed: _complete && !_overBudget ? _confirmPlan : null,
            ),
      children: [
        if (_phase == _Phase.done)
          _Reflection(firstPlan: _firstPlan, secondPlan: _choices, onRestart: _restart, beansUsed: _beansUsed)
        else ...[
          if (_phase == _Phase.twist) const _TwistBanner(),
          _BeanJar(used: used, capacity: _capacity),
          const SizedBox(height: Gaps.lg),
          for (var c = 0; c < _categories.length; c++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.md),
              child: _CategoryCard(
                category: _categories[c],
                selected: _choices[c],
                onSelect: (option) => _choose(c, option),
              ),
            ),
        ],
      ],
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _BeanJar extends StatelessWidget {
  const _BeanJar({required this.used, required this.capacity});

  final int used;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final over = used > capacity;
    final left = capacity - used;

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Hũ đậu của bạn', style: text.titleMedium),
              const Spacer(),
              Pill(
                text: over ? 'Vượt ${-left} hạt' : 'Còn $left hạt',
                color: over ? fin.red : fin.green,
                background: over ? fin.redSoft : fin.greenSoft,
              ),
            ],
          ),
          const SizedBox(height: Gaps.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Draw one dot per available bean, plus red dots for overspending.
              for (var i = 0; i < (used > capacity ? used : capacity); i++)
                AnimatedContainer(
                  duration: Duration(milliseconds: 200 + i * 15),
                  curve: Curves.easeOutBack,
                  width: 20,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i >= capacity ? fin.red : (i < used ? const Color(0xFF8B5A2B) : fin.surfaceAlt),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: i < used ? Colors.transparent : fin.border),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gaps.sm),
          Text('Đã dùng $used/$capacity hạt · ${formatVnd(used * _beanValue)} / ${formatVnd(capacity * _beanValue)}',
              style: text.bodySmall),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.selected, required this.onSelect});

  final _Category category;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: fin.green, size: 20),
              const SizedBox(width: Gaps.sm),
              Text(category.name, style: text.titleMedium),
              const Spacer(),
              if (selected != null) Icon(Icons.check_circle_rounded, color: fin.green, size: 20),
            ],
          ),
          const SizedBox(height: Gaps.sm),
          for (var o = 0; o < category.options.length; o++)
            _OptionRow(
              option: category.options[o],
              selected: selected == o,
              onTap: () => onSelect(o),
            ),
        ],
      ),
    );
  }
}

/// Full-width selectable row: label on the left, bean cost on the right.
class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option, required this.selected, required this.onTap});

  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.sm),
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: Gaps.md, vertical: Gaps.md),
          decoration: BoxDecoration(
            color: selected ? fin.greenSoft : fin.surfaceAlt,
            borderRadius: BorderRadius.circular(Gaps.radiusSm),
            border: Border.all(color: selected ? fin.green : Colors.transparent, width: 1.6),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? fin.green : fin.textMuted,
              ),
              const SizedBox(width: Gaps.sm),
              Expanded(child: Text(option.label, style: text.bodyMedium)),
              const SizedBox(width: Gaps.sm),
              Text(
                option.beans == 0 ? 'Miễn phí' : '${option.beans} hạt',
                style: text.titleSmall?.copyWith(color: selected ? fin.green : fin.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwistBanner extends StatelessWidget {
  const _TwistBanner();

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.lg),
      child: FadeSlideIn(
        child: Container(
          padding: const EdgeInsets.all(Gaps.lg),
          decoration: BoxDecoration(color: fin.red, borderRadius: BorderRadius.circular(Gaps.radius)),
          child: const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 30)),
              SizedBox(width: Gaps.md),
              Expanded(
                child: Text(
                  'BẤT NGỜ! Công ty cắt giảm, thu nhập giảm một nửa - bạn chỉ còn 10 hạt. '
                  'Hãy sắp xếp lại kế hoạch.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection({
    required this.firstPlan,
    required this.secondPlan,
    required this.onRestart,
    required this.beansUsed,
  });

  final Map<int, int> firstPlan;
  final Map<int, int> secondPlan;
  final VoidCallback onRestart;
  final int Function(Map<int, int>) beansUsed;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final savingsIndex = _categories.indexWhere((c) => c.name == 'Tiết kiệm');
    final keptSaving = (secondPlan[savingsIndex] ?? 0) > 0;
    final leftover = 10 - beansUsed(secondPlan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScoreBanner(
          emoji: '🎉',
          title: 'Bạn đã vượt qua cú sốc!',
          message: keptSaving
              ? 'Tuyệt vời - bạn vẫn giữ được thói quen tiết kiệm dù thu nhập giảm.'
              : 'Bạn đã cân đối được. Lần sau, thử giữ lại dù chỉ 1 phần nhỏ cho tiết kiệm nhé.',
          good: true,
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn đã thay đổi những gì?', style: text.titleMedium),
              const SizedBox(height: Gaps.md),
              for (var c = 0; c < _categories.length; c++)
                if (firstPlan[c] != secondPlan[c])
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gaps.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_categories[c].icon, size: 18, color: fin.coral),
                        const SizedBox(width: Gaps.sm),
                        Expanded(
                          child: Text(
                            '${_categories[c].name}: ${_categories[c].options[firstPlan[c]!].label} → '
                            '${_categories[c].options[secondPlan[c]!].label}',
                            style: text.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              if (leftover > 0)
                Text('Bạn còn dư $leftover hạt - hãy cân nhắc đưa vào tiết kiệm.', style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          color: fin.coralSoft,
          child: Text(
            'Suy ngẫm: Khoản nào là CẦN, khoản nào là MUỐN? Khi thu nhập giảm, bạn cắt khoản tùy ý trước '
            'hay khoản linh hoạt? Ngoài đời, ngân sách cũng phải thay đổi như vậy.',
            style: text.bodyMedium,
          ),
        ),
        const SizedBox(height: Gaps.lg),
        SecondaryButton(label: 'Chơi lại', icon: Icons.refresh_rounded, onPressed: onRestart),
      ],
    );
  }
}
