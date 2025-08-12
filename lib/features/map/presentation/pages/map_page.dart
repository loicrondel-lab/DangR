import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';
import '../widgets/hazard_marker.dart';
import '../widgets/map_controls.dart';
import '../widgets/location_button.dart';
import '../widgets/hazard_info_card.dart';
import '../widgets/quick_report_fab.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  MapLibreMapController? _mapController;
  bool _isMapReady = false;
  List<Hazard> _hazards = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Demander les permissions de localisation
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // Charger les hazards
    _loadHazards();
  }

  Future<void> _loadHazards() async {
    try {
      final hazards = await ref.read(hazardsNotifierProvider.future);
      setState(() {
        _hazards = hazards;
      });
    } catch (e) {
      // Gérer l'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationNotifierProvider);
    final selectedHazard = ref.watch(appStateProvider).selectedHazard;

    return Scaffold(
      body: Stack(
        children: [
          // Carte principale
          MapLibreMap(
            accessToken: 'YOUR_MAPLIBRE_TOKEN', // À configurer
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522), // Paris par défaut
              zoom: 12.0,
            ),
            styleString: MapboxStyles.MAPBOX_STREETS,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            myLocationRenderMode: MyLocationRenderMode.COMPASS,
            onMapClick: _onMapClick,
            onCameraIdle: _onCameraIdle,
          ),

          // Contrôles de la carte
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: MapControls(
              onStyleChanged: _onMapStyleChanged,
              onFiltersChanged: _onFiltersChanged,
            ),
          ),

          // Bouton de localisation
          Positioned(
            bottom: 120,
            right: 16,
            child: LocationButton(
              onPressed: _centerOnUserLocation,
            ),
          ),

          // Carte d'information du hazard sélectionné
          if (selectedHazard != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: HazardInfoCard(
                hazard: selectedHazard,
                onClose: () => ref.read(appStateProvider.notifier).setSelectedHazard(null),
                onVote: _onHazardVote,
              ),
            ),

          // Indicateur de chargement
          if (!_isMapReady)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: QuickReportFab(
        onPressed: _onQuickReport,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() {
    setState(() {
      _isMapReady = true;
    });
    _addHazardMarkers();
  }

  void _addHazardMarkers() {
    if (_mapController == null) return;

    for (final hazard in _hazards) {
      _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(hazard.position.latitude, hazard.position.longitude),
          iconImage: _getHazardIcon(hazard.type),
          iconSize: _getHazardIconSize(hazard.severity),
          iconAllowOverlap: true,
        ),
        {
          'hazardId': hazard.id,
          'type': hazard.type.toString(),
          'severity': hazard.severity,
        },
      );
    }
  }

  String _getHazardIcon(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
        return 'hazard-red';
      case HazardType.aggressiveGroup:
        return 'hazard-orange';
      case HazardType.intoxication:
        return 'hazard-yellow';
      case HazardType.harassment:
        return 'hazard-red';
      case HazardType.theft:
        return 'hazard-purple';
      case HazardType.suspiciousActivity:
        return 'hazard-blue';
      case HazardType.other:
        return 'hazard-gray';
    }
  }

  double _getHazardIconSize(int severity) {
    return 0.8 + (severity * 0.2);
  }

  void _onMapClick(LatLng point) {
    // Désélectionner le hazard actuel
    ref.read(appStateProvider.notifier).setSelectedHazard(null);
  }

  void _onCameraIdle() {
    // Recharger les hazards dans la zone visible
    _loadHazards();
  }

  void _onMapStyleChanged(MapStyle style) {
    ref.read(appStateProvider.notifier).setMapStyle(style);
    
    String styleString;
    switch (style) {
      case MapStyle.streets:
        styleString = MapboxStyles.MAPBOX_STREETS;
        break;
      case MapStyle.satellite:
        styleString = MapboxStyles.MAPBOX_SATELLITE;
        break;
      case MapStyle.dark:
        styleString = MapboxStyles.MAPBOX_DARK;
        break;
    }
    
    _mapController?.setStyleString(styleString);
  }

  void _onFiltersChanged(HazardFilters filters) {
    ref.read(appStateProvider.notifier).setFilters(filters);
    _loadHazards();
  }

  Future<void> _centerOnUserLocation() async {
    final location = await ref.read(locationNotifierProvider.future);
    if (location != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude, location.longitude),
        ),
      );
    }
  }

  void _onHazardVote(String hazardId, int vote) {
    ref.read(hazardsNotifierProvider.notifier).voteHazard(hazardId, vote);
  }

  void _onQuickReport() {
    // Naviguer vers la page de signalement
    context.push('/report');
  }
}
