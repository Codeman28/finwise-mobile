// lesson_screen.dart
// ---------------------------------------------------------------------------
// A lesson is a sequence of swipeable pages:
//
//   [intro] -> [card 1] ... [card n] -> [question 1] ... [question 4] -> [result]
//
// * The progress bar at the top grows as you move forward.
// * Questions give instant feedback: the chosen answer turns green or red and
//   the explanation fades in. You cannot skip a question without answering.
// * On the result page, passing (3/4 or better) marks the course complete and
//   offers the matching simulator in "Luyện tập".
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../content/courses.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'learn_screen.dart';
import 'practice_screen.dart';

/// Opens a course full-screen.
void openLesson(BuildContext context, AppState state, Course course) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LessonScreen(state: state, course: course)),
  );
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.state, required this.course});

  final AppState state;
  final Course course;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _pages = PageController();
  int _page = 0;

  /// Chosen option per question index (null = not answered yet).
  late final List<int?> _answers = List.filled(widget.course.quiz.length, null);

  Course get _course => widget.course;

  // Page layout: 1 intro page, the cards, the questions, 1 result page.
  int get _cardCount => _course.cards.length;
  int get _questionCount => _course.quiz.length;
  int get _firstQuestionPage => 1 + _cardCount;
  int get _resultPage => _firstQuestionPage + _questionCount;
  int get _pageCount => _resultPage + 1;

  bool get _onQuestion => _page >= _firstQuestionPage && _page < _resultPage;
  int get _questionIndex => _page - _firstQuestionPage;

  int get _score {
    var right = 0;
    for (var i = 0; i < _questionCount; i++) {
      if (_answers[i] == _course.quiz[i].answer) {
        right++;
      }
    }
    return right;
  }

  bool get _passed => _score / _questionCount >= passRatio;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _pages.animateToPage(page, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _goTo(_page + 1);
    }
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    if (page == _resultPage && _passed) {
      widget.state.completeLesson(_course.id);
      HapticFeedback.heavyImpact();
    }
  }

  void _answer(int option) {
    if (_answers[_questionIndex] != null) {
      return; // already answered - answers are final
    }
    final correct = option == _course.quiz[_questionIndex].answer;
    correct ? HapticFeedback.lightImpact() : HapticFeedback.vibrate();
    setState(() => _answers[_questionIndex] = option);
  }

  void _restart() {
    setState(() {
      for (var i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
    });
    _goTo(_firstQuestionPage);
  }

  /// Text of the big bottom button for the current page.
  String get _ctaLabel {
    if (_page == 0) {
      return 'Bắt đầu học';
    }
    if (_page < _firstQuestionPage - 1) {
      return 'Tiếp tục';
    }
    if (_page == _firstQuestionPage - 1) {
      return 'Làm bài kiểm tra nhanh';
    }
    if (_onQuestion) {
      return _questionIndex == _questionCount - 1 ? 'Xem kết quả' : 'Câu tiếp theo';
    }
    return 'Hoàn tất';
  }

  @override
  Widget build(BuildContext context) {
    final (strong, soft) = toneColors(context, _course.tone);
    final ctaEnabled = !_onQuestion || _answers[_questionIndex] != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              progress: (_page + 1) / _pageCount,
              color: strong,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: _onPageChanged,
                // Swiping is allowed for reading, but questions must be
                // answered with the button (so nobody skips one by accident).
                physics: _onQuestion ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                children: [
                  _IntroPage(course: _course, strong: strong, soft: soft),
                  for (var i = 0; i < _cardCount; i++)
                    _CardPage(card: _course.cards[i], index: i, total: _cardCount, accent: strong),
                  for (var q = 0; q < _questionCount; q++)
                    _QuestionPage(
                      question: _course.quiz[q],
                      index: q,
                      total: _questionCount,
                      chosen: _answers[q],
                      onChoose: _answer,
                    ),
                  _ResultPage(
                    course: _course,
                    score: _score,
                    total: _questionCount,
                    passed: _passed,
                    onRetry: _restart,
                    onPractice: _course.simId == null ? null : () => openSim(context, widget.state, _course.simId!),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.lg),
              child: PrimaryCta(
                label: _ctaLabel,
                icon: _page == _resultPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onPressed: !ctaEnabled
                    ? null
                    : (_page == _resultPage ? () => Navigator.of(context).pop() : _next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.color, required this.onClose});

  final double progress;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.sm, Gaps.sm, Gaps.page, Gaps.sm),
      child: Row(
        children: [
          IconButton(tooltip: 'Đóng bài học', onPressed: onClose, icon: const Icon(Icons.close_rounded)),
          const SizedBox(width: Gaps.xs),
          Expanded(child: SoftProgressBar(value: progress, color: color, height: 10)),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.course, required this.strong, required this.soft});

  final Course course;
  final Color strong;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(Gaps.page),
      children: [
        Center(
          child: Hero(
            tag: 'course-icon-${course.id}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(36)),
              child: Icon(course.icon, color: strong, size: 58),
            ),
          ),
        ),
        const SizedBox(height: Gaps.xl),
        Text('BÀI ${course.number} · ${course.minutes} PHÚT', style: text.labelSmall, textAlign: TextAlign.center),
        const SizedBox(height: Gaps.sm),
        Text(course.title, style: text.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: Gaps.sm),
        Text(course.subtitle, style: text.bodyLarge?.copyWith(color: context.fin.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: Gaps.xl),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sau bài này, bạn sẽ:', style: text.titleMedium),
              const SizedBox(height: Gaps.md),
              for (final goal in course.objectives)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: strong, size: 20),
                      const SizedBox(width: Gaps.sm),
                      Expanded(child: Text(goal, style: text.bodyMedium)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardPage extends StatelessWidget {
  const _CardPage({required this.card, required this.index, required this.total, required this.accent});

  final LessonCard card;
  final int index;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    return ListView(
      padding: const EdgeInsets.all(Gaps.page),
      children: [
        Text('THẺ ${index + 1}/$total', style: text.labelSmall?.copyWith(color: accent)),
        const SizedBox(height: Gaps.sm),
        Text(card.title, style: text.headlineSmall),
        const SizedBox(height: Gaps.md),
        Text(card.body, style: text.bodyLarge),
        if (card.bullets.isNotEmpty) ...[
          const SizedBox(height: Gaps.md),
          for (final bullet in card.bullets) _Bullet(text: bullet, color: accent),
        ],
        if (card.example != null) ...[
          const SizedBox(height: Gaps.lg),
          _Callout(icon: Icons.calculate_rounded, label: 'Ví dụ', body: card.example!, color: fin.green, background: fin.greenSoft),
        ],
        if (card.tip != null) ...[
          const SizedBox(height: Gaps.md),
          _Callout(icon: Icons.lightbulb_rounded, label: 'Mẹo', body: card.tip!, color: fin.coral, background: fin.coralSoft),
        ],
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9),
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Gaps.md),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.label, required this.body, required this.color, required this.background});

  final IconData icon;
  final String label;
  final String body;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gaps.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Gaps.radius),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.index,
    required this.total,
    required this.chosen,
    required this.onChoose,
  });

  final QuizQuestion question;
  final int index;
  final int total;
  final int? chosen;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    final answered = chosen != null;
    final correct = chosen == question.answer;

    return ListView(
      padding: const EdgeInsets.all(Gaps.page),
      children: [
        Text('CÂU HỎI ${index + 1}/$total', style: text.labelSmall?.copyWith(color: fin.coral)),
        const SizedBox(height: Gaps.sm),
        Text(question.question, style: text.headlineSmall),
        const SizedBox(height: Gaps.xl),
        for (var i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.md),
            child: _OptionTile(
              label: question.options[i],
              letter: String.fromCharCode(65 + i), // A, B, C, D
              state: _optionState(i),
              onTap: answered ? null : () => onChoose(i),
            ),
          ),
        AnimatedOpacity(
          opacity: answered ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          child: answered
              ? _Callout(
                  icon: correct ? Icons.celebration_rounded : Icons.info_rounded,
                  label: correct ? 'Chính xác!' : 'Chưa đúng',
                  body: question.explanation,
                  color: correct ? fin.green : fin.red,
                  background: correct ? fin.greenSoft : fin.redSoft,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  _OptionState _optionState(int i) {
    if (chosen == null) {
      return _OptionState.idle;
    }
    if (i == question.answer) {
      return _OptionState.correct;
    }
    if (i == chosen) {
      return _OptionState.wrong;
    }
    return _OptionState.faded;
  }
}

enum _OptionState { idle, correct, wrong, faded }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.letter, required this.state, required this.onTap});

  final String label;
  final String letter;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final (border, background, badge) = switch (state) {
      _OptionState.correct => (fin.green, fin.greenSoft, fin.green),
      _OptionState.wrong => (fin.red, fin.redSoft, fin.red),
      _OptionState.faded => (fin.border, fin.surface, fin.textMuted),
      _OptionState.idle => (fin.border, fin.surface, fin.green),
    };

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(Gaps.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Gaps.radius),
          border: Border.all(color: border, width: state == _OptionState.idle ? 1.2 : 2),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: badge.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: state == _OptionState.correct
                  ? Icon(Icons.check_rounded, color: badge, size: 20)
                  : state == _OptionState.wrong
                      ? Icon(Icons.close_rounded, color: badge, size: 20)
                      : Text(letter, style: TextStyle(color: badge, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: Gaps.md),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 260),
                opacity: state == _OptionState.faded ? 0.55 : 1,
                child: Text(label, style: Theme.of(context).textTheme.titleSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.course,
    required this.score,
    required this.total,
    required this.passed,
    required this.onRetry,
    required this.onPractice,
  });

  final Course course;
  final int score;
  final int total;
  final bool passed;
  final VoidCallback onRetry;
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    return ListView(
      padding: const EdgeInsets.all(Gaps.page),
      children: [
        const SizedBox(height: Gaps.xl),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Text(passed ? '🎉' : '💪', style: const TextStyle(fontSize: 88)),
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Text(
          passed ? 'Hoàn thành bài học!' : 'Gần được rồi!',
          style: text.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Gaps.sm),
        Text(
          'Bạn trả lời đúng $score/$total câu.',
          style: text.bodyLarge?.copyWith(color: fin.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Gaps.xl),
        if (!passed)
          SecondaryButton(label: 'Làm lại câu hỏi', icon: Icons.refresh_rounded, onPressed: onRetry),
        if (onPractice != null) ...[
          const SizedBox(height: Gaps.md),
          FinCard(
            color: fin.coralSoft,
            onTap: onPractice,
            child: Row(
              children: [
                IconBubble(icon: Icons.sports_esports_rounded, color: Colors.white, background: fin.coral),
                const SizedBox(width: Gaps.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thực hành ngay', style: text.titleMedium),
                      Text(simTitle(course.simId!), style: text.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: fin.coral),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
