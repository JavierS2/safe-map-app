import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _initLocation();
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
    setState(() {
      _selected = latlng;
    });
  }

  void _onConfirm() {
    if (_selected == null) return;
    final gp = GeoPoint(_selected!.latitude, _selected!.longitude);
    Navigator.of(context).pop(gp);
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
