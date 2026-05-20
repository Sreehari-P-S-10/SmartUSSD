import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceState {
  final double amount;
  final bool isVisible;
  final DateTime? lastUpdated;

  const BalanceState({
    this.amount = 0.0,
    this.isVisible = false,
    this.lastUpdated,
  });

  BalanceState copyWith({
    double? amount,
    bool? isVisible,
    DateTime? lastUpdated,
  }) {
    return BalanceState(
      amount: amount ?? this.amount,
      isVisible: isVisible ?? this.isVisible,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class BalanceNotifier extends StateNotifier<BalanceState> {
  BalanceNotifier() : super(const BalanceState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final amount = prefs.getDouble('balance_amount') ?? 12450.80;
    final isVisible = prefs.getBool('balance_visible') ?? false;
    final lastTs = prefs.getInt('balance_updated');
    state = BalanceState(
      amount: amount,
      isVisible: isVisible,
      lastUpdated: lastTs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastTs)
          : null,
    );
  }

  Future<void> updateBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setDouble('balance_amount', amount);
    await prefs.setInt('balance_updated', now.millisecondsSinceEpoch);
    state = state.copyWith(amount: amount, lastUpdated: now);
  }

  Future<void> toggleVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !state.isVisible;
    await prefs.setBool('balance_visible', next);
    state = state.copyWith(isVisible: next);
  }
}

final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>(
  (ref) => BalanceNotifier(),
);
