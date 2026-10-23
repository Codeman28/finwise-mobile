// sim_common.dart
// ---------------------------------------------------------------------------
// Pieces shared by every simulator in "Luyện tập":
//   SimScaffold   page frame with title, "about" text and link to the lesson
//   LabeledSlider slider with a live value label
//   StatTile      small number box
//   ScoreBanner   result banner at the end of a game
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../content/courses.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../lesson_screen.dart';

/// Marks a mission complete from inside a `build` method.
///
/// Changing AppState makes other screens rebuild, and Flutter does not allow
/// that while it is in the middle of drawing. So we wait until the current
/// frame is finished (addPostFrameCallback) and only then save the progress.
void completeMissionAfterBuild(AppState state, String missionId) {
  if (state.completedMissions.contains(missionId)) {
    return; // already done - nothing to schedule
  }
  WidgetsBinding.instance.addPostFrameCallback((_) => state.completeMission(missionId));
}

class SimScaffold extends StatelessWidget {
  const SimScaffold({
    super.key,
    required this.state,
    required this.title,
    required this.intro,
    required this.children,
    this.courseId,
    this.bottom,
  });

  final AppState state;
  final String title;
  final String intro;
  final List<Widget> children;
  final String? courseId; // lesson this simulator belongs to
  final Widget? bottom; // optional sticky bottom button

  @override
  Widget build(BuildContext context) {
    final course = courseId == null ? null : findCourse(courseId!);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.xl),
                children: [
                  Text(intro, style: text.bodyMedium?.copyWith(color: context.fin.textMuted)),
                  const SizedBox(height: Gaps.lg),
                  ...children,
                  if (course != null) ...[
                    const SizedBox(height: Gaps.lg),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => openLesson(context, state, course),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text('Ôn lại Bài ${course.number}: ${course.title}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.lg),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

/// A slider with its label on the left and live value on the right.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    this.color,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display; // formatted value, e.g. "1.500.000 ₫"
  final ValueChanged<double> onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final tint = color ?? fin.green;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: text.bodyMedium)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                display,
                key: ValueKey(display),
                style: text.titleSmall?.copyWith(color: tint, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: tint,
            inactiveTrackColor: fin.surfaceAlt,
            thumbColor: tint,
            overlayColor: tint.withValues(alpha: 0.12),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: display,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Small box with a label and a big number.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, required this.color, this.hint});

  final String label;
  final String value;
  final Color color;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FinCard(
      padding: const EdgeInsets.all(Gaps.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: text.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w800)),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Colourful result banner used at the end of games.
class ScoreBanner extends StatelessWidget {
  const ScoreBanner({super.key, required this.emoji, required this.title, required this.message, required this.good});

  final String emoji;
  final String title;
  final String message;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return FadeSlideIn(
      child: FinCard(
        color: good ? fin.greenSoft : fin.coralSoft,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: Gaps.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleLarge),
                  const SizedBox(height: 2),
                  Text(message, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
