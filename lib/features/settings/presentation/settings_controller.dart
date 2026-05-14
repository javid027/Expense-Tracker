import 'package:expensetracker/core/services/app_lock_service.dart';
import 'package:expensetracker/core/services/encryption_service.dart';
import 'package:expensetracker/core/services/reminder_service.dart';
import 'package:expensetracker/core/storage/local_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref.watch(localDatabaseProvider))..load();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsControllerProvider).themeMode;
});

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.encryptionEnabled = false,
    this.appLockEnabled = false,
    this.remindersEnabled = false,
    this.loaded = false,
  });

  final ThemeMode themeMode;
  final bool encryptionEnabled;
  final bool appLockEnabled;
  final bool remindersEnabled;
  final bool loaded;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? encryptionEnabled,
    bool? appLockEnabled,
    bool? remindersEnabled,
    bool? loaded,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      loaded: loaded ?? this.loaded,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._database)
      : _encryption = EncryptionService(_database),
        super(const SettingsState());

  final LocalDatabase _database;
  final EncryptionService _encryption;

  static const _themeModeKey = 'theme_mode';
  static const _encryptionKey = 'encryption_enabled';
  static const _appLockKey = 'app_lock_enabled';
  static const _remindersKey = 'reminders_enabled';

  void load() {
    final box = _database.settingsBox;
    final themeModeName = box.get(_themeModeKey) as String?;
    state = SettingsState(
      themeMode: _themeModeFromName(themeModeName),
      encryptionEnabled: (box.get(_encryptionKey) as bool?) ?? false,
      appLockEnabled: (box.get(_appLockKey) as bool?) ?? false,
      remindersEnabled: (box.get(_remindersKey) as bool?) ?? false,
      loaded: true,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _database.settingsBox.put(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setEncryptionEnabled(bool enabled) async {
    await _encryption.migrateAll(enabled);
    await _database.settingsBox.put(_encryptionKey, enabled);
    state = state.copyWith(encryptionEnabled: enabled);
  }

  Future<void> setAppLockEnabled(bool enabled, {String? pin}) async {
    if (enabled && pin != null) {
      await AppLockService.savePin(pin);
    }
    if (!enabled) {
      await AppLockService.clearPin();
    }
    await _database.settingsBox.put(_appLockKey, enabled);
    state = state.copyWith(appLockEnabled: enabled);
  }

  Future<void> setRemindersEnabled(bool enabled, {int hour = 20, int minute = 0}) async {
    if (enabled) {
      await ReminderService.scheduleDailyReminder(hour: hour, minute: minute);
    } else {
      await ReminderService.cancelDailyReminder();
    }
    await _database.settingsBox.put(_remindersKey, enabled);
    state = state.copyWith(remindersEnabled: enabled);
  }

  ThemeMode _themeModeFromName(String? name) {
    return ThemeMode.values.firstWhere(
      (item) => item.name == name,
      orElse: () => ThemeMode.system,
    );
  }
}
