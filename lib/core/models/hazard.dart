import 'package:isar/isar.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hazard.freezed.dart';
part 'hazard.g.dart';

@freezed
@collection
class Hazard with _$Hazard {
  const factory Hazard({
    @Id() required String id,
    @enumerated required HazardType type,
    required double latitude,
    required double longitude,
    required int severity,
    String? description,
    @Default([]) List<String> photoUrls,
    @enumerated @Default(HazardStatus.active) HazardStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int upvotes,
    @Default(0) int downvotes,
    required String reporterId,
    @Default('') String syncStatus,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Hazard;

  factory Hazard.fromJson(Map<String, dynamic> json) => _$HazardFromJson(json);
}

@freezed
class HazardType with _$HazardType {
  const factory HazardType.accident() = _Accident;
  const factory HazardType.traffic() = _Traffic;
  const factory HazardType.weather() = _Weather;
  const factory HazardType.construction() = _Construction;
  const factory HazardType.obstacle() = _Obstacle;
  const factory HazardType.police() = _Police;
  const factory HazardType.emergency() = _Emergency;
  const factory HazardType.other() = _Other;
}

@freezed
class HazardStatus with _$HazardStatus {
  const factory HazardStatus.active() = _Active;
  const factory HazardStatus.resolved() = _Resolved;
  const factory HazardStatus.expired() = _Expired;
  const factory HazardStatus.falseReport() = _FalseReport;
}

@freezed
class Position with _$Position {
  const factory Position({
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
    required DateTime timestamp,
  }) = _Position;

  factory Position.fromJson(Map<String, dynamic> json) => _$PositionFromJson(json);
}

@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool pushNotifications,
    @Default(true) bool geolocatedAlerts,
    @Default(false) bool emergencyAlerts,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(5000.0) double alertRadius,
    @Default([]) List<HazardType> filteredTypes,
    @Default({}) Map<String, bool> customSettings,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => _$NotificationSettingsFromJson(json);
}

// Extensions pour faciliter l'utilisation
extension HazardTypeExtension on HazardType {
  String get name {
    return when(
      accident: () => 'Accident',
      traffic: () => 'Trafic',
      weather: () => 'Météo',
      construction: () => 'Travaux',
      obstacle: () => 'Obstacle',
      police: () => 'Police',
      emergency: () => 'Urgence',
      other: () => 'Autre',
    );
  }

  String get icon {
    return when(
      accident: () => '🚗',
      traffic: () => '🚦',
      weather: () => '🌧️',
      construction: () => '🚧',
      obstacle: () => '⚠️',
      police: () => '👮',
      emergency: () => '🚨',
      other: () => '❓',
    );
  }

  int get priority {
    return when(
      accident: () => 1,
      traffic: () => 2,
      weather: () => 3,
      construction: () => 4,
      obstacle: () => 5,
      police: () => 6,
      emergency: () => 0, // Plus haute priorité
      other: () => 7,
    );
  }
}

extension HazardStatusExtension on HazardStatus {
  String get name {
    return when(
      active: () => 'Actif',
      resolved: () => 'Résolu',
      expired: () => 'Expiré',
      falseReport: () => 'Faux signalement',
    );
  }

  bool get isActive {
    return when(
      active: () => true,
      resolved: () => false,
      expired: () => false,
      falseReport: () => false,
    );
  }
}

extension HazardExtension on Hazard {
  bool get isExpired {
    final now = DateTime.now();
    final age = now.difference(createdAt);
    return age.inHours > 24; // Expire après 24h
  }

  double get voteRatio {
    final total = upvotes + downvotes;
    if (total == 0) return 0.0;
    return upvotes / total;
  }

  bool get isReliable {
    return voteRatio > 0.7 && upvotes > 5;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  double get distanceFrom(double userLat, double userLng) {
    // Formule de Haversine pour calculer la distance
    const double earthRadius = 6371000; // Rayon de la Terre en mètres
    
    final lat1 = latitude * (3.14159 / 180);
    final lat2 = userLat * (3.14159 / 180);
    final deltaLat = (userLat - latitude) * (3.14159 / 180);
    final deltaLng = (userLng - longitude) * (3.14159 / 180);

    final a = (deltaLat / 2).sin() * (deltaLat / 2).sin() +
        lat1.cos() * lat2.cos() * (deltaLng / 2).sin() * (deltaLng / 2).sin();
    final c = 2 * (a.sqrt() / (1 - a).sqrt()).atan();

    return earthRadius * c;
  }
}
