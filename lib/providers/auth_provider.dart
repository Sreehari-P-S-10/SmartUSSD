import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLocked;
  final int failedAttempts;
  final DateTime? lockoutEndTime;

  const AuthState({
    this.isAuthenticated = false,
    this.isLocked = false,
    this.failedAttempts = 0,
    this.lockoutEndTime,
  });

  bool get isInLockout {
    if (!isLocked || lockoutEndTime == null) return false;
    return DateTime.now().isBefore(lockoutEndTime!);
  }

  int get lockoutSecondsRemaining {
    if (!isInLockout) return 0;
    return lockoutEndTime!.difference(DateTime.now()).inSeconds;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLocked,
    int? failedAttempts,
    DateTime? lockoutEndTime,
    bool clearLockout = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLocked: isLocked ?? this.isLocked,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutEndTime: clearLockout ? null : lockoutEndTime ?? this.lockoutEndTime,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<bool> loginWithPin(String pin) async {
    if (state.isInLockout) return false;

    final isValid = await _authService.verifyPin(pin);
    if (isValid) {
      state = const AuthState(isAuthenticated: true);
      return true;
    } else {
      final attempts = state.failedAttempts + 1;
      if (attempts >= 3) {
        state = state.copyWith(
          failedAttempts: attempts,
          isLocked: true,
          lockoutEndTime: DateTime.now().add(const Duration(seconds: 30)),
        );
      } else {
        state = state.copyWith(failedAttempts: attempts);
      }
      return false;
    }
  }

  Future<bool> loginWithBiometrics() async {
    final success = await _authService.authenticateWithBiometrics();
    if (success) {
      state = const AuthState(isAuthenticated: true);
    }
    return success;
  }

  Future<void> setupPin(String pin) async {
    await _authService.savePin(pin);
    state = const AuthState(isAuthenticated: true);
  }

  void logout() {
    state = const AuthState();
  }

  void lock() {
    state = state.copyWith(isAuthenticated: false);
  }

  Future<bool> hasPin() => _authService.hasPin();
  Future<bool> isBiometricAvailable() => _authService.isBiometricAvailable();
  Future<bool> isBiometricEnabled() => _authService.isBiometricEnabled();
  Future<void> setBiometricEnabled(bool v) => _authService.setBiometricEnabled(v);
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);
