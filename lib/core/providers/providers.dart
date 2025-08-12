import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../router/app_router.dart';
import '../services/notification_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/hazard_service.dart';

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

// Placeholder classes (to be defined in separate files)
class Position {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const Position({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}

class Hazard {
  final String id;
  final HazardType type;
  final int severity;
  final Position position;
  final double radiusM;
  final HazardStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String reporterId;
  final List<String> mediaUrls;
  final int upvotes;
  final int downvotes;

  const Hazard({
    required this.id,
    required this.type,
    required this.severity,
    required this.position,
    required this.radiusM,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    required this.reporterId,
    this.mediaUrls = const [],
    this.upvotes = 0,
    this.downvotes = 0,
  });
}

enum HazardType {
  verbalAggression,
  aggressiveGroup,
  intoxication,
  harassment,
  theft,
  suspiciousActivity,
  other,
}

enum HazardStatus {
  pending,
  confirmed,
  disputed,
  expired,
}

class NotificationSettings {
  final bool proximityAlerts;
  final bool hazardUpdates;
  final bool serviceInfo;
  final double proximityRadiusKm;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.proximityAlerts = true,
    this.hazardUpdates = true,
    this.serviceInfo = true,
    this.proximityRadiusKm = 0.5,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? proximityAlerts,
    bool? hazardUpdates,
    bool? serviceInfo,
    double? proximityRadiusKm,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      proximityAlerts: proximityAlerts ?? this.proximityAlerts,
      hazardUpdates: hazardUpdates ?? this.hazardUpdates,
      serviceInfo: serviceInfo ?? this.serviceInfo,
      proximityRadiusKm: proximityRadiusKm ?? this.proximityRadiusKm,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
