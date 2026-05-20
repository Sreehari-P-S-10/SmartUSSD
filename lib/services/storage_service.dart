import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _pinKey = 'user_pin';
  static const _biometricKey = 'biometric_enabled';
  static const _nameKey = 'user_name';

  // ─── PIN ─────────────────────────────────────────────────────────────────────

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await getPin();
    return stored == pin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }

  // ─── Biometric ───────────────────────────────────────────────────────────────

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricKey);
    return val == 'true';
  }

  // ─── Profile Name ────────────────────────────────────────────────────────────

  Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String> getName() async {
    return await _storage.read(key: _nameKey) ?? 'Sreehari';
  }

  // ─── Wipe ────────────────────────────────────────────────────────────────────

  Future<void> wipeAll() async {
    await _storage.deleteAll();
  }
}
