import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import '../providers/providers.dart';

part 'hazard_service.g.dart';

@riverpod
class HazardService extends _$HazardService {
  late Dio _dio;
  late Isar _isar;

  @override
  FutureOr<void> build() {
    // Initialisation du service de gestion des incidents
  }

  Future<void> initialize() async {
    // Initialiser Dio pour les appels API
    _dio = Dio(BaseOptions(
      baseUrl: 'YOUR_SUPABASE_URL', // À configurer
      headers: {
        'Content-Type': 'application/json',
        'apikey': 'YOUR_SUPABASE_ANON_KEY', // À configurer
      },
    ));

    // Initialiser Isar pour le cache local
    _isar = await Isar.open([HazardSchema]);
  }

  // Récupérer les incidents dans une zone géographique
  Future<List<Hazard>> getHazardsInArea({
    required double latitude,
    required double longitude,
    required double radius,
    List<HazardType>? types,
    HazardStatus? status,
  }) async {
    try {
      // Appel API pour récupérer les incidents
      final response = await _dio.get('/rest/v1/hazards', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        if (types != null) 'types': types.map((t) => t.name).toList(),
        if (status != null) 'status': status.name,
      });

      final List<dynamic> data = response.data;
      final hazards = data.map((json) => Hazard.fromJson(json)).toList();

      // Mettre en cache les incidents
      await _cacheHazards(hazards);

      return hazards;
    } catch (e) {
      // En cas d'erreur, retourner les incidents en cache
      return await _getCachedHazards();
    }
  }

  // Créer un nouvel incident
  Future<Hazard?> createHazard({
    required HazardType type,
    required double latitude,
    required double longitude,
    required int severity,
    String? description,
    List<String>? photoUrls,
  }) async {
    try {
      final hazard = Hazard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        latitude: latitude,
        longitude: longitude,
        severity: severity,
        description: description,
        photoUrls: photoUrls ?? [],
        status: HazardStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotes: 0,
        downvotes: 0,
        reporterId: 'current_user_id', // À récupérer depuis AuthService
      );

      // Envoyer à l'API
      final response = await _dio.post('/rest/v1/hazards', data: hazard.toJson());
      
      final createdHazard = Hazard.fromJson(response.data);
      
      // Mettre en cache
      await _cacheHazard(createdHazard);
      
      return createdHazard;
    } catch (e) {
      // En cas d'erreur, sauvegarder en local pour synchronisation ultérieure
      await _saveHazardForSync(hazard);
      return null;
    }
  }

  // Voter sur un incident
  Future<bool> voteHazard({
    required String hazardId,
    required bool isUpvote,
  }) async {
    try {
      final response = await _dio.post('/rest/v1/hazards/$hazardId/vote', data: {
        'vote': isUpvote ? 'up' : 'down',
      });

      // Mettre à jour le cache local
      await _updateHazardVotes(hazardId, isUpvote);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Marquer un incident comme résolu
  Future<bool> resolveHazard(String hazardId) async {
    try {
      await _dio.patch('/rest/v1/hazards/$hazardId', data: {
        'status': HazardStatus.resolved.name,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Mettre à jour le cache local
      await _updateHazardStatus(hazardId, HazardStatus.resolved);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Signaler un incident comme faux
  Future<bool> reportHazard(String hazardId, String reason) async {
    try {
      await _dio.post('/rest/v1/hazards/$hazardId/report', data: {
        'reason': reason,
        'reported_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Récupérer les incidents en cache
  Future<List<Hazard>> _getCachedHazards() async {
    try {
      return await _isar.hazards.where().findAll();
    } catch (e) {
      return [];
    }
  }

  // Mettre en cache un incident
  Future<void> _cacheHazard(Hazard hazard) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.hazards.put(hazard);
      });
    } catch (e) {
      // Gérer l'erreur de cache
    }
  }

  // Mettre en cache plusieurs incidents
  Future<void> _cacheHazards(List<Hazard> hazards) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.hazards.putAll(hazards);
      });
    } catch (e) {
      // Gérer l'erreur de cache
    }
  }

  // Sauvegarder un incident pour synchronisation ultérieure
  Future<void> _saveHazardForSync(Hazard hazard) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.hazards.put(hazard);
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  // Mettre à jour les votes d'un incident
  Future<void> _updateHazardVotes(String hazardId, bool isUpvote) async {
    try {
      final hazard = await _isar.hazards.get(hazardId);
      if (hazard != null) {
        if (isUpvote) {
          hazard.upvotes++;
        } else {
          hazard.downvotes++;
        }
        await _isar.writeTxn(() async {
          await _isar.hazards.put(hazard);
        });
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  // Mettre à jour le statut d'un incident
  Future<void> _updateHazardStatus(String hazardId, HazardStatus status) async {
    try {
      final hazard = await _isar.hazards.get(hazardId);
      if (hazard != null) {
        hazard.status = status;
        hazard.updatedAt = DateTime.now();
        await _isar.writeTxn(() async {
          await _isar.hazards.put(hazard);
        });
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  // Synchroniser les incidents en attente
  Future<void> syncPendingHazards() async {
    try {
      final pendingHazards = await _isar.hazards
          .filter()
          .syncStatusEqualTo('pending')
          .findAll();

      for (final hazard in pendingHazards) {
        await createHazard(
          type: hazard.type,
          latitude: hazard.latitude,
          longitude: hazard.longitude,
          severity: hazard.severity,
          description: hazard.description,
          photoUrls: hazard.photoUrls,
        );
      }
    } catch (e) {
      // Gérer l'erreur de synchronisation
    }
  }

  // Nettoyer les anciens incidents
  Future<void> cleanupOldHazards() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final oldHazards = await _isar.hazards
          .filter()
          .createdAtLessThan(cutoffDate)
          .findAll();

      await _isar.writeTxn(() async {
        await _isar.hazards.deleteAll(oldHazards.map((h) => h.id).toList());
      });
    } catch (e) {
      // Gérer l'erreur de nettoyage
    }
  }
}
