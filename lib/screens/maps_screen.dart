import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/models/gym_model.dart';
import 'package:move_up/widgets/gym_details_modal.dart';
import 'package:move_up/widgets/loading_overlay.dart';

// Configuration via .env ou valeur par défaut
const double _defaultRadiusKm =
    5.0; // Valeur par défaut si RADIUS_KM_MAPS manque
final double _radiusKm =
    double.tryParse(dotenv.env['RADIUS_KM_MAPS'] ?? '') ?? _defaultRadiusKm;

const String _exactApiFilters =
    "?refine=equip_type_name%3A%22Salle%20de%20musculation%2Fcardiotraining%22&refine=aps_name%3A%22Musculation%22";

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? mapController;

  LatLng _userPosition = const LatLng(47.218371, -1.553621);
  Set<Marker> _markers = {};
  List<Gym> _nearbyGyms = [];
  bool _isLoading = true;
  String _loadingMessage = "Localisation en cours...";

  final String _baseApiUrl =
      "https://equipements.sports.gouv.fr/api/explore/v2.1/catalog/datasets/data-es/records";

  @override
  void initState() {
    super.initState();
    _determinePositionAndFetchData();
  }

  // Obtenir la position de l'utilisateur
  Future<void> _determinePositionAndFetchData() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _loadingMessage = "Le service de localisation est désactivé.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _loadingMessage = "La permission de localisation est refusée.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _loadingMessage =
            "La permission de localisation est refusée de façon permanente.";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userPosition = LatLng(position.latitude, position.longitude);
        _loadingMessage = "Chargement des salles de sport...";
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userPosition, 12.5),
      );

      await _fetchGymData();
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
      setState(() {
        _isLoading = false;
        _loadingMessage = "Impossible de récupérer votre position.";
      });
    }
  }

  // Récupération et Filtrage des données ---
  Future<void> _fetchGymData() async {
    const String limit = "&limit=100";

    final String dynamicApiUrl = "$_baseApiUrl$_exactApiFilters$limit";

    try {
      // Utilisation du package http standard
      final Uri uri = Uri.parse(dynamicApiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic>? records = data['results'] as List<dynamic>?;

        final List<Marker> newMarkers = [];
        final List<Gym> foundGyms = [];

        for (var record in records ?? []) {
          final Gym? gym = _tryParseGym(record as Map<String, dynamic>);

          if (gym != null) {
            // Filtre Geolocator pour la précision finale (côté client)
            final double distanceInMeters = Geolocator.distanceBetween(
              _userPosition.latitude,
              _userPosition.longitude,
              gym.latitude,
              gym.longitude,
            );

            if (distanceInMeters <= _radiusKm * 1000) {
              foundGyms.add(gym);
              newMarkers.add(_createGymMarker(gym));
            }
          }
        }

        setState(() {
          // Ajout du marqueur de la position utilisateur (PIN BLEU)
          newMarkers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: _userPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: const InfoWindow(title: 'Votre Position'),
            ),
          );

          _markers = newMarkers.toSet();
          _nearbyGyms = foundGyms;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load gym data with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur de chargement des données: $e');
      setState(() {
        _isLoading = false;
        _loadingMessage = "Erreur de connexion (Vérifiez la console).";
      });
    }
  }

  // Fonctions utilitaires

  Gym? _tryParseGym(Map<String, dynamic> record) {
    try {
      return Gym.fromJson(record);
    } catch (e) {
      print('Erreur de parsing pour le record: $e');
      return null;
    }
  }

  Marker _createGymMarker(Gym gym) {
    final LatLng position = LatLng(gym.latitude, gym.longitude);
    return Marker(
      markerId: MarkerId(gym.name),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      onTap: () => _showGymDetailsModal(gym),
      infoWindow: InfoWindow(
        title: gym.name,
        snippet: 'Cliquer pour les détails',
      ),
    );
  }

  void _showGymDetailsModal(Gym gym) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryDark,
      builder: (BuildContext context) {
        return GymDetailsModal(gym: gym);
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Widget Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte Google Maps (Partie Supérieure)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: Stack(
              children: [
                if (!_isLoading || _userPosition.latitude != 47.218371)
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _userPosition,
                      zoom: 12.5,
                    ),
                    markers: _markers,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                if (_isLoading) LoadingOverlay(message: _loadingMessage),
              ],
            ),
          ),

          // Liste des Salles de Sport (Partie Inférieure)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salle de sports trouvées (rayon $_radiusKm km) :',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? Center(
                          child: Text(
                            _loadingMessage,
                            style: TextStyle(color: AppColors.grey400),
                          ),
                        )
                      : Expanded(
                          child: _nearbyGyms.isEmpty
                              ? Center(
                                  child: Text(
                                    "Aucune salle trouvée dans le rayon de 5km.",
                                    style: TextStyle(color: AppColors.grey700),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: _nearbyGyms.length,
                                  itemBuilder: (context, index) {
                                    final Gym gym = _nearbyGyms[index];

                                    return InkWell(
                                      onTap: () {
                                        _showGymDetailsModal(gym);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          gym.name,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
