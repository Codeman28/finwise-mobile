// needwant_game.dart
// ---------------------------------------------------------------------------
// "Cần hay Muốn?" (Lesson 5): one item at a time, tap CẦN or MUỐN.
// Each answer shows a short explanation - some items are trickier than they
// look (e.g. a phone for work vs. a brand-new phone model).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class _Item {
  const _Item(this.emoji, this.name, this.price, this.isNeed, this.why);
  final String emoji;
  final String name;
  final double price;
  final bool isNeed;
  final String why;
}

const _items = [
  _Item('🍚', 'Gạo và thức ăn cho cả tuần', 450000, true, 'Ăn uống cơ bản là nhu cầu thiết yếu.'),
  _Item('🧋', 'Ly trà sữa thứ 3 trong tuần', 45000, false, 'Ngon nhưng không bắt buộc - một khoản muốn điển hình.'),
  _Item('💡', 'Tiền điện tháng này', 280000, true, 'Hóa đơn thiết yếu; trả chậm còn bị phạt.'),
  _Item('👟', 'Giày phiên bản giới hạn', 2500000, false, 'Bạn vẫn đi học, đi làm bình thường mà không có nó.'),
  _Item('📚', 'Sách giáo khoa năm học mới', 350000, true, 'Phục vụ việc học - một khoản cần.'),
  _Item('🎮', 'Skin mới trong game', 200000, false, 'Chỉ để giải trí - khoản muốn.'),
  _Item('🛵', 'Tiền xăng đi học mỗi tuần', 100000, true, 'Đi lại để học và làm việc là khoản cần.'),
  _Item('📱', 'Đổi điện thoại mới khi máy cũ vẫn tốt', 12000000, false, 'Máy cũ còn dùng tốt nên đây là mong muốn.'),
  _Item('💊', 'Thuốc khi bị ốm', 150000, true, 'Sức khỏe luôn là nhu cầu thiết yếu.'),
  _Item('🍕', 'Đặt đồ ăn ngoài dù nhà có sẵn đồ', 120000, false, 'Tiện nhưng không cần - nấu ở nhà rẻ hơn nhiều.'),
  _Item('🏠', 'Tiền phòng trọ', 2500000, true, 'Chỗ ở là nhu cầu cơ bản.'),
  _Item('🎟️', 'Vé concert thần tượng', 1800000, false, 'Trải nghiệm đáng nhớ, nhưng vẫn là khoản muốn - hãy lên kế hoạch để dành!'),
];

class NeedWantGame extends StatefulWidget {
  const NeedWantGame({super.key, required this.state});

  final AppState state;

  @override
  State<NeedWantGame> createState() => _NeedWantGameState();
}

class _NeedWantGameState extends State<NeedWantGame> {
  int _index = 0;
  int _score = 0;
  bool? _lastAnswerCorrect; // null = not answered this card yet

  bool get _finished => _index >= _items.length;

  void _answer(bool saysNeed) {
    if (_lastAnswerCorrect != null) {
      return;
    }
    final correct = saysNeed == _items[_index].isNeed;
    correct ? HapticFeedback.lightImpact() : HapticFeedback.vibrate();
    setState(() {
      _lastAnswerCorrect = correct;
      if (correct) {
        _score++;
      }
    });
  }

  void _next() {
    setState(() {
      _index++;
      _lastAnswerCorrect = null;
    });
    if (_finished && _score >= 10) {
      widget.state.completeMission('needwant');
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _lastAnswerCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return SimScaffold(
      state: widget.state,
      title: 'Cần hay Muốn?',
      courseId: 'savvy-shopper',
      intro: 'Khoản CẦN giúp bạn sống, học và làm việc. Khoản MUỐN làm cuộc sống vui hơn. Phân loại thật nhanh nhé!',
      children: [
        if (!_finished) ...[
          Row(
            children: [
              Text('Món ${_index + 1}/${_items.length}', style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Pill(text: 'Điểm: $_score', color: fin.green, background: fin.greenSoft),
            ],
          ),
          const SizedBox(height: Gaps.sm),
          SoftProgressBar(value: _index / _items.length, color: fin.coral, height: 6),
          const SizedBox(height: Gaps.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _ItemCard(key: ValueKey(_index), item: _items[_index], answerCorrect: _lastAnswerCorrect),
          ),
          const SizedBox(height: Gaps.lg),
          if (_lastAnswerCorrect == null)
            Row(
              children: [
                Expanded(child: _ChoiceButton(label: 'CẦN', icon: Icons.check_rounded, color: fin.green, onTap: () => _answer(true))),
                const SizedBox(width: Gaps.md),
                Expanded(child: _ChoiceButton(label: 'MUỐN', icon: Icons.favorite_rounded, color: fin.coral, onTap: () => _answer(false))),
              ],
            )
          else
            PrimaryCta(
              label: _index == _items.length - 1 ? 'Xem kết quả' : 'Món tiếp theo',
              icon: Icons.arrow_forward_rounded,
              onPressed: _next,
            ),
        ] else ...[
          ScoreBanner(
            emoji: _score >= 10 ? '🏆' : '🛒',
            title: 'Bạn đúng $_score/${_items.length}',
            message: _score >= 10
                ? 'Tuyệt vời! Bạn phân biệt cần và muốn rất tốt.'
                : 'Đạt 10 điểm trở lên để hoàn thành. Thử lại nhé!',
            good: _score >= 10,
          ),
          const SizedBox(height: Gaps.md),
          SecondaryButton(label: 'Chơi lại', icon: Icons.refresh_rounded, onPressed: _restart),
        ],
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({super.key, required this.item, required this.answerCorrect});

  final _Item item;
  final bool? answerCorrect;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final answered = answerCorrect != null;
    return FinCard(
      padding: const EdgeInsets.all(Gaps.xl),
      child: Column(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: Gaps.md),
          Text(item.name, style: text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: Gaps.xs),
          Text(formatVnd(item.price), style: text.titleMedium?.copyWith(color: fin.textMuted)),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: answered
                ? Padding(
                    padding: const EdgeInsets.only(top: Gaps.lg),
                    child: Column(
                      children: [
                        Pill(
                          text: answerCorrect! ? 'Chính xác! · ${item.isNeed ? "CẦN" : "MUỐN"}' : 'Chưa đúng · là ${item.isNeed ? "CẦN" : "MUỐN"}',
                          color: answerCorrect! ? fin.green : fin.red,
                          background: answerCorrect! ? fin.greenSoft : fin.redSoft,
                        ),
                        const SizedBox(height: Gaps.sm),
                        Text(item.why, style: text.bodyMedium, textAlign: TextAlign.center),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Gaps.radius),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: Gaps.sm),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
