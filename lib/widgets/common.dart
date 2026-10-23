// common.dart
// ---------------------------------------------------------------------------
// Reusable building blocks ("Lego bricks") used by every screen:
//   FinCard, PressableScale, PrimaryCta, SecondaryButton, SectionHeader,
//   IconBubble, Pill, AnimatedMoney, SoftProgressBar, EmptyState, ErrorState,
//   FadeSlideIn, TxnTile, VndInputFormatter, showFinSnack ...
//
// Anything that appears on more than one screen is defined ONCE here, so the
// whole app stays consistent and each screen file stays short.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/finance.dart';
import '../core/format.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

// ===========================================================================
// Surfaces
// ===========================================================================

/// A white rounded card with a soft green-tinted shadow.
class FinCard extends StatelessWidget {
  const FinCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gaps.lg),
    this.color,
    this.gradient,
    this.onTap,
    this.radius = Gaps.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? fin.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: fin.shadow, blurRadius: 24, offset: const Offset(0, 8))],
      ),
      // A transparent Material lets ListTiles and buttons inside the card
      // draw their ripple ("ink") effect on top of the card's colour.
      child: Material(type: MaterialType.transparency, child: child),
    );

    if (onTap == null) {
      return card;
    }
    return PressableScale(onTap: onTap, child: card);
  }
}

/// Shrinks its child slightly while pressed - makes taps feel physical.
/// Also gives a light haptic "tick" on both iOS and Android.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.onTap, this.scale = 0.97});

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ===========================================================================
// Buttons
// ===========================================================================

/// THE main call-to-action: coral gradient, bold label, glowing shadow.
/// Only one of these should be visible per screen - it must stand out.
class PrimaryCta extends StatelessWidget {
  const PrimaryCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool busy; // shows a small spinner (loading state)

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final enabled = onPressed != null && !busy;

    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        else if (icon != null)
          Icon(icon, color: Colors.white, size: 22),
        if (busy || icon != null) const SizedBox(width: Gaps.sm),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );

    return PressableScale(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: Gaps.xl, vertical: Gaps.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [fin.coral, Color.lerp(fin.coral, fin.red, 0.45)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Gaps.radius),
            boxShadow: [
              BoxShadow(color: fin.coral.withValues(alpha: 0.38), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Quieter outlined button for secondary actions.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.color});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.fin.green;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: tint,
        minimumSize: const Size(0, 50),
        side: BorderSide(color: tint.withValues(alpha: 0.5), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Gaps.radius)),
        textStyle: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

// ===========================================================================
// Small pieces
// ===========================================================================

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: text.bodySmall),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: context.fin.green),
            child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

/// A coloured circle with an icon inside.
class IconBubble extends StatelessWidget {
  const IconBubble({super.key, required this.icon, required this.color, required this.background, this.size = 44});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// A small rounded label, e.g. "Vượt ngân sách".
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, required this.color, required this.background, this.icon});

  final String text;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Money amount that "counts" smoothly to its new value when it changes.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({super.key, required this.amount, this.style, this.showPlus = false});

  final double amount;
  final TextStyle? style;
  final bool showPlus;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          formatVnd(value, showPlus: showPlus),
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// Rounded progress bar whose fill animates when the value changes.
class SoftProgressBar extends StatelessWidget {
  const SoftProgressBar({super.key, required this.value, required this.color, this.height = 10, this.track});

  final double value; // 0.0 - 1.0 (larger values are shown as full)
  final Color color;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: track ?? context.fin.surfaceAlt,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: target),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) {
            return FractionallySizedBox(
              widthFactor: animated,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Fades and slides its child in once, when it first appears.
/// [delayIndex] staggers lists: item 0, then 1, then 2 ...
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delayIndex = 0});

  final Widget child;
  final int delayIndex;

  @override
  Widget build(BuildContext context) {
    // A later item simply uses a longer animation, which looks like a delay.
    final duration = Duration(milliseconds: 380 + delayIndex * 70);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
        );
      },
      child: child,
    );
  }
}

// ===========================================================================
// States: empty / error
// ===========================================================================

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gaps.xl, horizontal: Gaps.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [fin.greenSoft, fin.coralSoft]),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: fin.green),
          ),
          const SizedBox(height: Gaps.lg),
          Text(title, style: text.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: Gaps.sm),
          Text(message, style: text.bodyMedium?.copyWith(color: fin.textMuted), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: Gaps.lg), action!],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry, this.retryLabel = 'Thử lại'});

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Ôi, có lỗi xảy ra',
      message: message,
      action: SecondaryButton(label: retryLabel, onPressed: onRetry, icon: Icons.refresh_rounded, color: fin.red),
    );
  }
}

// ===========================================================================
// Transactions
// ===========================================================================

/// One row in a transaction list: icon, title, category, signed amount.
class TxnTile extends StatelessWidget {
  const TxnTile({super.key, required this.txn, this.showDate = false});

  final Txn txn;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final info = Categories.find(txn.category);
    final color = txn.isIncome ? fin.green : fin.red;
    final background = txn.isIncome ? fin.greenSoft : fin.redSoft;
    final subtitle = showDate ? '${txn.category} · ${formatDayMonth(txn.date)}' : txn.category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gaps.sm),
      child: Row(
        children: [
          IconBubble(icon: info.icon, color: color, background: background),
          const SizedBox(width: Gaps.md),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: Gaps.sm),
          // The amount may shrink a little on very narrow phones instead of
          // pushing the row off-screen.
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatVnd(txn.isIncome ? txn.amount : -txn.amount, showPlus: true),
                  style: text.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colours for a budget state: (main colour, soft background).
(Color, Color) budgetColors(BuildContext context, BudgetState state) {
  final fin = context.fin;
  switch (state) {
    case BudgetState.over:
      return (fin.red, fin.redSoft);
    case BudgetState.warning:
      return (fin.coral, fin.coralSoft);
    case BudgetState.ok:
      return (fin.green, fin.greenSoft);
  }
}

// ===========================================================================
// Input helpers
// ===========================================================================

/// Adds thousand-separator dots while the user types: 1500000 -> 1.500.000
class VndInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    // Cap at 12 digits (999 tỷ) so numbers stay sensible.
    final capped = digits.length > 12 ? digits.substring(0, 12) : digits;
    final formatted = formatVnd(int.parse(capped), withSymbol: false);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// A money text field: numeric keyboard, live dots, "₫" suffix.
class VndField extends StatelessWidget {
  const VndField({
    super.key,
    required this.controller,
    this.label,
    this.hint = '0',
    this.errorText,
    this.autofocus = false,
    this.big = false,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final String? errorText;
  final bool autofocus;
  final bool big; // large display style for the "add transaction" sheet
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final style = big
        ? TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: fin.text, letterSpacing: -0.5)
        : TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fin.text);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [VndInputFormatter()],
      style: style,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        suffixText: '₫',
        suffixStyle: style.copyWith(color: fin.textMuted),
      ),
    );
  }
}

/// Floating message at the bottom, with an optional action (e.g. "Hoàn tác").
void showFinSnack(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, textColor: context.fin.pink, onPressed: onAction ?? () {}),
    ),
  );
}

/// "Are you sure?" dialog for destructive actions. Returns true if confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xóa',
}) async {
  final fin = context.fin;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: fin.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Standard page padding that also respects the phone's safe areas.
const pagePadding = EdgeInsets.fromLTRB(Gaps.page, Gaps.md, Gaps.page, 120);
