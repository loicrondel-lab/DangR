import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../router/app_router.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/hazard_service.dart';
import '../models/hazard.dart';

part 'providers.g.dart';

// Theme provider
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

// Auth provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<bool> build() async {
    return ref.read(authServiceProvider.notifier).isAuthenticated();
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    try {
      final success = await ref.read(authServiceProvider.notifier).signInAnonymously();
      state = AsyncValue.data(success);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider.notifier).signOut();
      state = const AsyncValue.data(false);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Location provider
@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  Future<Position?> build() async {
    return ref.read(locationServiceProvider.notifier).getCurrentLocation();
  }

  Future<void> startLocationTracking() async {
    await ref.read(locationServiceProvider.notifier).startTracking();
  }

  Future<void> stopLocationTracking() async {
    await ref.read(locationServiceProvider.notifier).stopTracking();
  }
}

// Hazards provider
@riverpod
class HazardsNotifier extends _$HazardsNotifier {
  @override
  Future<List<Hazard>> build() async {
    return ref.read(hazardServiceProvider.notifier).getNearbyHazards();
  }

  Future<void> createHazard(Hazard hazard) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(hazardServiceProvider.notifier).createHazard(hazard);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> voteHazard(String hazardId, int vote) async {
    try {
      await ref.read(hazardServiceProvider.notifier).voteHazard(hazardId, vote);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshHazards() async {
    ref.invalidateSelf();
  }
}

// Notification settings provider
@riverpod
class NotificationSettings extends _$NotificationSettings {
  @override
  Future<NotificationSettings> build() async {
    return ref.read(notificationServiceProvider.notifier).getSettings();
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(notificationServiceProvider.notifier).updateSettings(settings);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// App state provider
@riverpod
class AppState extends _$AppState {
  @override
  AppStateData build() => const AppStateData();

  void setCurrentLocation(Position position) {
    state = state.copyWith(currentLocation: position);
  }

  void setSelectedHazard(Hazard? hazard) {
    state = state.copyWith(selectedHazard: hazard);
  }

  void setMapStyle(MapStyle style) {
    state = state.copyWith(mapStyle: style);
  }

  void setFilters(HazardFilters filters) {
    state = state.copyWith(filters: filters);
  }
}

// Data classes
class AppStateData {
  final Position? currentLocation;
  final Hazard? selectedHazard;
  final MapStyle mapStyle;
  final HazardFilters filters;

  const AppStateData({
    this.currentLocation,
    this.selectedHazard,
    this.mapStyle = MapStyle.streets,
    this.filters = const HazardFilters(),
  });

  AppStateData copyWith({
    Position? currentLocation,
    Hazard? selectedHazard,
    MapStyle? mapStyle,
    HazardFilters? filters,
  }) {
    return AppStateData(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedHazard: selectedHazard ?? this.selectedHazard,
      mapStyle: mapStyle ?? this.mapStyle,
      filters: filters ?? this.filters,
    );
  }
}

enum MapStyle { streets, satellite, dark }

class HazardFilters {
  final List<HazardType> types;
  final int? maxAgeHours;
  final double? maxDistanceKm;
  final int? minSeverity;

  const HazardFilters({
    this.types = const [],
    this.maxAgeHours,
    this.maxDistanceKm,
    this.minSeverity,
  });

  HazardFilters copyWith({
    List<HazardType>? types,
    int? maxAgeHours,
    double? maxDistanceKm,
    int? minSeverity,
  }) {
    return HazardFilters(
      types: types ?? this.types,
      maxAgeHours: maxAgeHours ?? this.maxAgeHours,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minSeverity: minSeverity ?? this.minSeverity,
    );
  }
}

// Les modèles de données sont maintenant définis dans ../models/hazard.dart
