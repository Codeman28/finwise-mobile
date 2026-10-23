// app.dart
// ---------------------------------------------------------------------------
// The MaterialApp: themes (light + dark), Vietnamese language, and the three
// states of start-up:
//
//   loading  -> branded splash with a spinner
//   error    -> friendly message + "Thử lại" / "Bắt đầu lại"
//   ready    -> the real app (AppShell with the bottom tabs)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/app_state.dart';
import 'data/storage.dart';
import 'screens/shell.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

class FinWiseApp extends StatelessWidget {
  const FinWiseApp({super.key, required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // follows the phone's light/dark setting
      // Vietnamese for built-in widgets (date picker, "Copy/Paste" menu ...).
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _Bootstrap(storage: storage),
    );
  }
}

/// Loads saved data once, showing loading / error / ready states.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap({required this.storage});

  final Storage storage;

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<AppState> _loading = AppState.load(widget.storage);

  void _retry() {
    setState(() => _loading = AppState.load(widget.storage));
  }

  /// Saved data is damaged: start with an empty wallet instead.
  void _startFresh() {
    final fresh = AppState(storage: widget.storage);
    fresh.resetAll(); // also overwrites the damaged data on the phone
    setState(() => _loading = Future.value(fresh));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _loading,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.hasError) {
          child = _StartupError(onRetry: _retry, onStartFresh: _startFresh);
        } else if (!snapshot.hasData) {
          child = const _Splash();
        } else {
          child = AppShell(state: snapshot.data!);
        }
        // Cross-fade between splash, error and the app.
        return AnimatedSwitcher(duration: const Duration(milliseconds: 450), child: child);
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Scaffold(
      backgroundColor: fin.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Logo(size: 84),
            const SizedBox(height: Gaps.lg),
            Text('FinWise', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: Gaps.xl),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 3, color: fin.coral),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.onRetry, required this.onStartFresh});

  final VoidCallback onRetry;
  final VoidCallback onStartFresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gaps.page),
            child: Column(
              children: [
                ErrorState(
                  message: 'Không đọc được dữ liệu đã lưu trên máy. Hãy thử lại; '
                      'nếu vẫn lỗi, bạn có thể bắt đầu lại với ví trống.',
                  onRetry: onRetry,
                ),
                TextButton(onPressed: onStartFresh, child: const Text('Bắt đầu lại với ví trống')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The round "F" badge from the palette card, drawn in code (no image file).
class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Palette.greenLight, Palette.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'F',
        style: TextStyle(color: Colors.white, fontSize: size * 0.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}
