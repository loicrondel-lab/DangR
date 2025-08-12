import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/hazard_service.dart';
import '../models/hazard.dart'; // Les modèles de données sont maintenant définis dans ../models/hazard.dart

part 'providers.g.dart';

// Theme Mode Provider
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

// Locale Provider
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() {
    return const Locale('en', 'US'); // Default to English
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', '${locale.languageCode}_${locale.countryCode}');
    state = locale;
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString('locale');
    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        state = Locale(parts[0], parts[1]);
      }
    }
  }
}

// Provider for accessing locale
@riverpod
Locale locale(LocaleRef ref) {
  return ref.watch(localeNotifierProvider);
}

// Auth Provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {
    return ref.read(authServiceProvider.notifier).initialize();
  }

  Future<bool> signInAnonymously() async {
    return await ref.read(authServiceProvider.notifier).signInAnonymously();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    return await ref.read(authServiceProvider.notifier).signInWithEmail(email, password);
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    return await ref.read(authServiceProvider.notifier).signUpWithEmail(email, password);
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider.notifier).signOut();
  }

  bool get isAuthenticated => ref.read(authServiceProvider.notifier).isAuthenticated;
  String? get currentUserId => ref.read(authServiceProvider.notifier).currentUserId;
}

// Location Provider
@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  FutureOr<void> build() {
    return ref.read(locationServiceProvider.notifier).initialize();
  }

  Future<Position?> getCurrentPosition() async {
    return await ref.read(locationServiceProvider.notifier).getCurrentPosition();
  }

  Future<void> startBackgroundTracking() async {
    await ref.read(locationServiceProvider.notifier).startBackgroundLocationTracking();
  }

  Future<void> stopBackgroundTracking() async {
    await ref.read(locationServiceProvider.notifier).stopBackgroundLocationTracking();
  }
}

// Hazards Provider
@riverpod
class HazardsNotifier extends _$HazardsNotifier {
  @override
  Future<List<Hazard>> build() async {
    return [];
  }

  Future<void> loadHazardsInArea(double latitude, double longitude, double radius) async {
    final hazards = await ref.read(hazardServiceProvider.notifier).getHazardsInArea(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
    state = AsyncValue.data(hazards);
  }

  Future<void> createHazard({
    required HazardType type,
    required double latitude,
    required double longitude,
    required int severity,
    String? description,
    List<String>? photoUrls,
  }) async {
    final hazard = await ref.read(hazardServiceProvider.notifier).createHazard(
      type: type,
      latitude: latitude,
      longitude: longitude,
      severity: severity,
      description: description,
      photoUrls: photoUrls,
    );
    if (hazard != null) {
      final currentHazards = state.value ?? [];
      state = AsyncValue.data([hazard, ...currentHazards]);
    }
  }

  Future<void> voteHazard(String hazardId, bool isUpvote) async {
    await ref.read(hazardServiceProvider.notifier).voteHazard(
      hazardId: hazardId,
      isUpvote: isUpvote,
    );
    // Refresh hazards after voting
    await loadHazardsInArea(0, 0, 10000); // This should be updated with actual coordinates
  }
}

// Notification Settings Provider
@riverpod
class NotificationSettings extends _$NotificationSettings {
  @override
  NotificationSettings build() {
    return const NotificationSettings(
      pushEnabled: true,
      emailEnabled: false,
      hazardRadius: 1000,
      emergencyAlerts: true,
      dailyDigest: false,
    );
  }

  void updateSettings(NotificationSettings settings) {
    state = settings;
  }

  void togglePushNotifications() {
    state = state.copyWith(pushEnabled: !state.pushEnabled);
  }

  void toggleEmailNotifications() {
    state = state.copyWith(emailEnabled: !state.emailEnabled);
  }

  void updateHazardRadius(double radius) {
    state = state.copyWith(hazardRadius: radius);
  }
}

// App State Provider
@riverpod
class AppState extends _$AppState {
  @override
  Map<String, dynamic> build() {
    return {
      'isLoading': false,
      'currentPage': 'map',
      'showOnboarding': true,
      'lastSync': null,
    };
  }

  void setLoading(bool loading) {
    state = {...state, 'isLoading': loading};
  }

  void setCurrentPage(String page) {
    state = {...state, 'currentPage': page};
  }

  void setShowOnboarding(bool show) {
    state = {...state, 'showOnboarding': show};
  }

  void setLastSync(DateTime? sync) {
    state = {...state, 'lastSync': sync};
  }
}
