import 'package:local_auth/local_auth.dart';
import 'storage_service.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final StorageService _storage = StorageService();

  Future<bool> isBiometricAvailable() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access SmartUSSD',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) => _storage.verifyPin(pin);

  Future<void> savePin(String pin) => _storage.savePin(pin);

  Future<bool> hasPin() => _storage.hasPin();

  Future<void> clearPin() => _storage.deletePin();

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.setBiometricEnabled(enabled);

  Future<bool> isBiometricEnabled() => _storage.isBiometricEnabled();
}
