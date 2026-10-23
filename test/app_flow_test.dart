// Widget tests: run the real app off-screen and use it like a person would.
// Run with:  flutter test

import 'package:finwise/app.dart';
import 'package:finwise/content/courses.dart';
import 'package:finwise/data/app_state.dart';
import 'package:finwise/data/storage.dart';
import 'package:finwise/screens/practice_screen.dart';
import 'package:finwise/theme/app_theme.dart';
import 'package:finwise/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the app on a typical phone-sized screen.
Future<void> pumpApp(WidgetTester tester, {Storage? storage, Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(FinWiseApp(storage: storage ?? MemoryStorage()));
  await tester.pumpAndSettle();
}

/// Taps "Xem với dữ liệu mẫu" on the welcome card and checks it worked.
Future<void> loadSampleData(WidgetTester tester) async {
  final button = find.text('Xem với dữ liệu mẫu');
  // Scroll the button towards the middle of the screen, away from the edges.
  await tester.scrollUntilVisible(button, 120, scrollable: find.byType(Scrollable).first);
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -120));
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  expect(find.text('6 tháng gần đây'), findsOneWidget, reason: 'sample data should fill the home screen');
}

void main() {
  testWidgets('first launch shows the welcome card', (tester) async {
    await pumpApp(tester);
    expect(find.text('Bắt đầu hành trình tài chính ✨'), findsOneWidget);
    expect(find.text('Tổng số dư'), findsOneWidget);
  });

  testWidgets('add an expense through the bottom sheet', (tester) async {
    final storage = MemoryStorage();
    await pumpApp(tester, storage: storage);

    // Empty wallet: the welcome card's button is the main call-to-action.
    await tester.tap(find.text('Thêm giao dịch đầu tiên'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm giao dịch'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '45000');
    await tester.pumpAndSettle();
    expect(find.text('45.000'), findsOneWidget); // dots added while typing

    await tester.tap(find.text('Lưu 45.000 ₫'));
    await tester.pumpAndSettle();

    final saved = await AppState.load(storage);
    expect(saved.txns.single.amount, 45000);
    expect(saved.txns.single.isIncome, isFalse);
  });

  testWidgets('sample data fills every tab without errors', (tester) async {
    await pumpApp(tester);
    await loadSampleData(tester);
    expect(find.text('6 tháng gần đây'), findsOneWidget);

    for (final tab in ['Giao dịch', 'Kế hoạch', 'Học', 'Luyện tập', 'Tổng quan']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('complete a lesson by answering the quiz correctly', (tester) async {
    final storage = MemoryStorage();
    await pumpApp(tester, storage: storage);
    await tester.tap(find.text('Học').last);
    await tester.pumpAndSettle();

    final course = courses.first;
    await tester.tap(find.text(course.title));
    await tester.pumpAndSettle();

    // Intro + every card.
    for (var i = 0; i <= course.cards.length; i++) {
      await tester.tap(find.byType(PrimaryCta).last);
      await tester.pumpAndSettle();
    }
    // Every question: tap the right option, then continue.
    for (final question in course.quiz) {
      await tester.tap(find.text(question.options[question.answer]));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryCta).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('Hoàn thành bài học!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    final saved = await AppState.load(storage);
    expect(saved.completedLessons, contains(course.id));
  });

  testWidgets('every simulator opens and renders', (tester) async {
    for (final sim in sims) {
      final state = AppState();
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: sim.builder(state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'simulator ${sim.id}');
    }
    tester.view.reset();
  });

  testWidgets('large system font (130%) on a normal phone still fits', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester);
    await loadSampleData(tester);
    expect(find.text('Thêm'), findsOneWidget); // floating button appears once there is data
    for (final tab in ['Giao dịch', 'Kế hoạch', 'Học', 'Luyện tập', 'Tổng quan']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode and a small phone render without overflow', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester, size: const Size(320, 640));
    await loadSampleData(tester);
    for (final tab in ['Giao dịch', 'Kế hoạch', 'Học', 'Luyện tập']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
