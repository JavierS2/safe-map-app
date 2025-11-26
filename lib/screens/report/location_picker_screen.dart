import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'widgets/report_header.dart';
import '../map/widgets/map_controls.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _center = LatLng(11.2408, -74.1990);
  double _zoom = 15.0;
  LatLng? _selected;
  bool _loading = true;

  // City polygon loaded from GeoJSON. Must be present for validation to work.
  List<LatLng> _cityPolygon = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadCityPolygon();
  }

  Future<void> _loadCityPolygon() async {
    try {
      final content = await rootBundle.loadString('assets/geo/santa_marta_polygon.geojson');
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Support both FeatureCollection and raw Geometry
      List coordinates = [];
      if (data['type'] == 'FeatureCollection' && data['features'] is List) {
        // find first Polygon or MultiPolygon feature
        for (final f in data['features']) {
          final geom = f['geometry'] as Map<String, dynamic>?;
          if (geom == null) continue;
          if (geom['type'] == 'Polygon') {
            coordinates = geom['coordinates'] as List;
            break;
          }
          if (geom['type'] == 'MultiPolygon') {
            final mp = geom['coordinates'] as List;
            if (mp.isNotEmpty) {
              coordinates = mp[0] as List;
              break;
            }
          }
        }
      } else if (data['type'] == 'Polygon') {
        coordinates = data['coordinates'] as List;
      } else if (data['type'] == 'MultiPolygon') {
        final mp = data['coordinates'] as List;
        if (mp.isNotEmpty) coordinates = mp[0] as List;
      }

      if (coordinates.isNotEmpty) {
        // GeoJSON Polygon coordinates are: [ [ [lon, lat], ... ] , ...rings]
        final outerRing = coordinates[0] as List;
        final poly = <LatLng>[];
        for (final pt in outerRing) {
          if (pt is List && pt.length >= 2) {
            final lon = (pt[0] as num).toDouble();
            final lat = (pt[1] as num).toDouble();
            poly.add(LatLng(lat, lon));
          }
        }
        if (poly.isNotEmpty) {
          setState(() => _cityPolygon = poly);
        }
      }
    } catch (e) {
      // Asset not present or parse error: silently ignore and keep bbox fallback
    }
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // keep default center
        setState(() => _loading = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = latlng;
        _selected = latlng;
        _loading = false;
      });
      // move after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(latlng, _zoom);
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onTapMap(TapPosition tapPos, LatLng latlng) {
    // If the tapped point is outside the configured city bounds, show a message
    if (!_isInsideCity(latlng)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La ubicación debe estar dentro de la ciudad.'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    setState(() {
      _selected = latlng;
    });
  }

  void _onConfirm() {
    if (_selected == null) return;
    if (!_isInsideCity(_selected!)) {
      // Prevent confirming a location outside the city
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ubicación no válida'),
          content: const Text('Solo puede seleccionar ubicaciones dentro de la ciudad.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Aceptar')),
          ],
        ),
      );
      return;
    }

    final gp = GeoPoint(_selected!.latitude, _selected!.longitude);
    Navigator.of(context).pop(gp);
  }

  bool _isInsideCity(LatLng p) {
    // Require a loaded polygon. If the polygon is not available, treat the
    // location as outside the city so selection is prevented until the
    // GeoJSON asset is provided.
    if (_cityPolygon.isEmpty) return false;
    return _pointInPolygon(p, _cityPolygon);
  }

  // Ray-casting algorithm for point-in-polygon. Returns true if point is inside.
  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    final x = point.longitude;
    final y = point.latitude;
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude, yi = polygon[i].latitude;
      final xj = polygon[j].longitude, yj = polygon[j].latitude;

      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi + 0.0) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  void _centerOnDevice() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = latlng;
        _selected = latlng;
      });
      _mapController.move(latlng, _zoom);
    } catch (e) {
      // ignore
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1).clamp(1.0, 18.0);
    });
    final center = _selected ?? _center;
    _mapController.move(center, _zoom);
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1).clamp(1.0, 18.0);
    });
    final center = _selected ?? _center;
    _mapController.move(center, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ReportHeader(title: 'Seleccionar ubicación'),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: _zoom,
                      onTap: _onTapMap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      if (_cityPolygon.isNotEmpty)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _cityPolygon,
                              color: Theme.of(context).primaryColor.withOpacity(0.08),
                              borderColor: Theme.of(context).primaryColor.withOpacity(0.9),
                              borderStrokeWidth: 2.0,
                            ),
                          ],
                        ),
                      if (_selected != null)
                        MarkerLayer(markers: [
                          Marker(
                            point: _selected!,
                            width: 56,
                            height: 56,
                            child: const Icon(Icons.location_on, size: 48, color: Colors.red),
                          )
                        ])
                    ],
                  ),
                  if (_loading) const Center(child: CircularProgressIndicator()),
                  // Reuse the same controls as the main map screen (zoom, center)
                  PositionedMapControls(
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onCenter: _centerOnDevice,
                  ),
                  // Confirm button placed near the other controls
                  Positioned(
                    right: 12,
                    bottom: 84,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: FloatingActionButton(
                        heroTag: 'confirm_location',
                        mini: true,
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: _onConfirm,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
