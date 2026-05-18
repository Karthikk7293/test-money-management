import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Token
  String? get token => _prefs.getString(AppConstants.prefsToken);
  Future<void> setToken(String value) =>
      _prefs.setString(AppConstants.prefsToken, value);

  // Nickname
  String? get nickname => _prefs.getString(AppConstants.prefsNickname);
  Future<void> setNickname(String value) =>
      _prefs.setString(AppConstants.prefsNickname, value);

  // Phone
  String? get phone => _prefs.getString(AppConstants.prefsPhone);
  Future<void> setPhone(String value) =>
      _prefs.setString(AppConstants.prefsPhone, value);

  // Onboarding
  bool get onboardingCompleted =>
      _prefs.getBool(AppConstants.prefsOnboarded) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(AppConstants.prefsOnboarded, value);

  // Budget alert limit
  double get budgetLimit =>
      _prefs.getDouble(AppConstants.prefsBudgetLimit) ??
      AppConstants.defaultBudgetLimit;
  Future<void> setBudgetLimit(double value) =>
      _prefs.setDouble(AppConstants.prefsBudgetLimit, value);

  // Known users (phone -> nickname). Survives sign-out so returning users
  // are recognised as "existing" by the local auth flow.
  Map<String, String> get knownUsers {
    final raw = _prefs.getString(AppConstants.prefsKnownUsers);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return const {};
  }

  Future<void> upsertKnownUser(String phone, String nickname) async {
    final users = Map<String, String>.from(knownUsers);
    users[phone] = nickname;
    await _prefs.setString(
        AppConstants.prefsKnownUsers, jsonEncode(users));
  }

  String? knownNickname(String phone) => knownUsers[phone];
  bool knowsUser(String phone) => knownUsers.containsKey(phone);

  bool get isAuthenticated => (token ?? '').isNotEmpty;

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.prefsToken);
    await _prefs.remove(AppConstants.prefsNickname);
    await _prefs.remove(AppConstants.prefsPhone);
  }
}
