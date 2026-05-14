import 'package:expensetracker/core/services/secure_storage_service.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService._();

  static const pinKey = 'finora_app_pin';
  static final _auth = LocalAuthentication();

  static Future<void> savePin(String pin) => SecureStorageService.write(pinKey, pin);

  static Future<String?> readPin() => SecureStorageService.read(pinKey);

  static Future<void> clearPin() => SecureStorageService.delete(pinKey);

  static Future<bool> authenticateBiometric() async {
    try {
      final available = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!available) return false;
      return await _auth.authenticate(
        localizedReason: 'Unlock Finora',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }

  static Future<bool> verifyPin(String candidate) async {
    final current = await readPin();
    return current != null && current == candidate;
  }
}
