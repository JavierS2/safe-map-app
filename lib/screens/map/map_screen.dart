import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'models/report.dart';
import 'widgets/report_marker.dart';
import 'widgets/map_controls.dart';
import 'widgets/filter_button.dart';
import 'widgets/map_filter_sheet.dart';
import 'widgets/report_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Centro inicial: Santa Marta
  LatLng _center = LatLng(11.2408, -74.1990);
  double _zoom = 13.0;

  StreamSubscription<Position?>? _positionSub;

  // Example reports
  final List<Report> _reports = [
    Report(
      id: 'r1',
      barrio: 'Centro',
      category: 'Hurto simple',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      position: LatLng(11.2410, -74.2017),
      title: 'Reporte',
      description: 'Un ciudadano reportó un hurto simple cerca de la plaza central. Se escucharon gritos y la víctima perdió su teléfono.',
    ),
    Report(
      id: 'r2',
      barrio: 'Bello Horizonte',
      category: 'Robo violento',
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      position: LatLng(11.14696, -74.22651),
      title: 'Reporte',
      description: 'Robo con agresión reportado en la vía principal. Testigos indican que fue en la madrugada.',
    ),
    Report(
      id: 'r3',
      barrio: 'El Rodadero',
      category: 'Hurto simple',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      position: LatLng(11.203873, -74.227876),
      title: 'Reporte',
      description: 'Objeto perdido en la playa y reporte de hurto en zona turística cerca del malecón.',
    ),
  ];

  // Active filtered list (starts showing all)
  late List<Report> _filteredReports = List.from(_reports);

  // Current filter criteria
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  TimeOfDay? _filterTimeFrom;
  TimeOfDay? _filterTimeTo;
  Set<String> _filterBarrios = {};
  Set<String> _filterCategories = {};

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void _showReport(Report r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReportBottomSheet(report: r),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredReports = _reports.where((r) {
        // date filter
        if (_filterDateFrom != null) {
          final fromDate = DateTime(_filterDateFrom!.year, _filterDateFrom!.month, _filterDateFrom!.day);
          if (r.timestamp.isBefore(fromDate)) return false;
        }
        if (_filterDateTo != null) {
          final toDate = DateTime(_filterDateTo!.year, _filterDateTo!.month, _filterDateTo!.day, 23, 59, 59);
          if (r.timestamp.isAfter(toDate)) return false;
        }

        // time of day filter: compare only when both bounds provided
        if (_filterTimeFrom != null && _filterTimeTo != null) {
          final rTime = TimeOfDay.fromDateTime(r.timestamp);
          bool beforeFrom = (rTime.hour < _filterTimeFrom!.hour) || (rTime.hour == _filterTimeFrom!.hour && rTime.minute < _filterTimeFrom!.minute);
          bool afterTo = (rTime.hour > _filterTimeTo!.hour) || (rTime.hour == _filterTimeTo!.hour && rTime.minute > _filterTimeTo!.minute);
          if (beforeFrom || afterTo) return false;
        }

        // barrio filter
        if (_filterBarrios.isNotEmpty && !_filterBarrios.contains(r.barrio)) return false;

        // category filter
        if (_filterCategories.isNotEmpty && !_filterCategories.contains(r.category)) return false;

        return true;
      }).toList();
    });
  }

  void _openFilterSheet() async {
    final availableBarrios = _reports.map((r) => r.barrio).toSet().toList();
    final availableCategories = _reports.map((r) => r.category).toSet().toList();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MapFilterSheet(
        initialDateFrom: _filterDateFrom,
        initialDateTo: _filterDateTo,
        initialTimeFrom: _filterTimeFrom,
        initialTimeTo: _filterTimeTo,
        barrios: availableBarrios,
        categories: availableCategories,
        initialSelectedBarrios: _filterBarrios,
        initialSelectedCategories: _filterCategories,
      ),
    );

    if (result != null) {
      // unpack and apply
      _filterDateFrom = result['dateFrom'] as DateTime?;
      _filterDateTo = result['dateTo'] as DateTime?;
      _filterTimeFrom = result['timeFrom'] as TimeOfDay?;
      _filterTimeTo = result['timeTo'] as TimeOfDay?;
      _filterBarrios = Set<String>.from(result['barrios'] as List<dynamic>);
      _filterCategories = Set<String>.from(result['categories'] as List<dynamic>);
      _applyFilters();
    }
  }

  Future<void> _centerOnDevice() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = latlng;
      });
      _mapController.move(latlng, _zoom);
    } catch (e) {
      // ignore errors; maybe no permission
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1).clamp(1.0, 18.0);
    });
    _mapController.move(_center, _zoom);
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1).clamp(1.0, 18.0);
    });
    _mapController.move(_center, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the body to extend under the bottomNavigationBar so the map
      // is visible beneath the navbar's rounded corners (prevents a visible
      // background band). Keep the navbar design (white, curved) unchanged.
      extendBody: true,
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.map),
      // Allow the body to extend under the bottom nav: keep top SafeArea
      // but allow content to reach the bottom so the map renders beneath
      // the curved white navbar. This avoids any background rectangle
      // showing between the map and the navbar.
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // No bottom padding here so the body can extend fully under
              // the bottomNavigationBar (we use extendBody: true on Scaffold).
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight, maxHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _center,
                                initialZoom: _zoom,
                                maxZoom: 18.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'com.example.safe_map_application',
                                ),
                                MarkerLayer(
                                  markers: _filteredReports
                                      .map((r) => Marker(
                                            point: r.position,
                                            width: 56,
                                            // increase height to accommodate the small pin tip below the circle
                                            height: 72,
                                            child: ReportMarker(report: r, onTap: () => _showReport(r)),
                                          ))
                                      .toList(),
                                ),
                              ],
                              ),

                            // Reusable controls/widgets on top of the map
                            PositionedMapControls(onZoomIn: _zoomIn, onZoomOut: _zoomOut, onCenter: _centerOnDevice),
                            PositionedFilterButton(onPressed: _openFilterSheet),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

