import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/pin_login_screen.dart';
import 'screens/auth/pin_setup_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/balance/check_balance_screen.dart';
import 'screens/contacts/saved_contacts_screen.dart';
import 'screens/history/transaction_history_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/mini_statement/mini_statement_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/send_money/send_money_screen.dart';
import 'screens/splash/splash_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/pin-setup', builder: (_, __) => const PinSetupScreen()),
    GoRoute(path: '/login', builder: (_, __) => const PinLoginScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/send', builder: (_, __) => const SendMoneyScreen()),
    GoRoute(path: '/balance', builder: (_, __) => const CheckBalanceScreen()),
    GoRoute(path: '/statement', builder: (_, __) => const MiniStatementScreen()),
    GoRoute(path: '/history', builder: (_, __) => const TransactionHistoryScreen()),
    GoRoute(path: '/contacts', builder: (_, __) => const SavedContactsScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);

class SmartUSSDApp extends ConsumerWidget {
  const SmartUSSDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'SmartUSSD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
