import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import 'widgets/report_marker.dart';
import 'widgets/map_controls.dart';
import 'widgets/filter_button.dart';
import 'widgets/map_filter_sheet.dart';
import 'widgets/report_bottom_sheet.dart';
import '../report/widgets/barrios_santa_marta.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  // Centro inicial: Santa Marta
  LatLng _center = LatLng(11.2408, -74.1990);
  double _zoom = 13.0;

  StreamSubscription<Position?>? _positionSub;

  // Reports loaded from Firestore via provider
  List<ReportModel> _reports = [];

  // Active filtered list (starts showing all)
  late List<ReportModel> _filteredReports = [];

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

  @override
  void initState() {
    super.initState();
    // Load reports from provider once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReportProvider>(context, listen: false);

      // read route args to check for a selected report id (optional)
      final args = ModalRoute.of(context)?.settings.arguments;
      String? selectedReportId;
      if (args is Map && args['reportId'] != null) {
        selectedReportId = args['reportId'] as String;
      } else if (args is String) {
        selectedReportId = args;
      }

      await provider.fetchAllReports();
      if (!mounted) return;
      setState(() {
        _reports = List.from(provider.allReports);
        _filteredReports = List.from(_reports);
      });

      // If a reportId was provided, try to center the map and show its bottom sheet
      if (selectedReportId != null && selectedReportId.isNotEmpty) {
        final found = _reports.firstWhere((r) => r.id == selectedReportId, orElse: () => ReportModel(id: '', userId: '', date: DateTime.now(), time: '', category: '', neighborhood: '', details: '', createdAt: DateTime.now()));
        if (found.id.isNotEmpty && found.lat != null && found.lng != null) {
          final latlng = LatLng(found.lat!, found.lng!);
          // give the map a frame to initialize, then move and open
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _animatedMapMove(latlng, 15.0);
            } catch (_) {
              try {
                _mapController.move(latlng, 15.0);
              } catch (_) {}
            }
            _showReport(found);
          });
        }
      }
    });
  }

  void _showReport(ReportModel r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReportBottomSheet(report: r),
    );
  }

  // Smoothly animate the map center and zoom to [dest] over a short duration.
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(begin: _center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      final lat = latTween.evaluate(animation);
      final lng = lngTween.evaluate(animation);
      final zoom = zoomTween.evaluate(animation);
      try {
        _mapController.move(LatLng(lat, lng), zoom);
      } catch (_) {}
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _center = destLocation;
        _zoom = destZoom;
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _applyFilters() {
    setState(() {
      _filteredReports = _reports.where((r) {
        // date filter
        if (_filterDateFrom != null) {
          final fromDate = DateTime(_filterDateFrom!.year, _filterDateFrom!.month, _filterDateFrom!.day);
          if (r.date.isBefore(fromDate)) return false;
        }
        if (_filterDateTo != null) {
          final toDate = DateTime(_filterDateTo!.year, _filterDateTo!.month, _filterDateTo!.day, 23, 59, 59);
          if (r.date.isAfter(toDate)) return false;
        }

        // time of day filter: allow start-only, end-only or both
        if (_filterTimeFrom != null || _filterTimeTo != null) {
          // parse report.time string like '5:12 PM' or '17:12'
          int? parseTimeToMinutes(String s) {
            final reg = RegExp(r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?');
            final m = reg.firstMatch(s.trim());
            if (m == null) return null;
            final h = int.tryParse(m.group(1) ?? '0');
            final min = int.tryParse(m.group(2) ?? '0');
            final ampm = m.group(3);
            if (h == null || min == null) return null;
            var hour = h;
            if (ampm != null) {
              final a = ampm.toLowerCase();
              if (a == 'pm' && hour < 12) hour += 12;
              if (a == 'am' && hour == 12) hour = 0;
            }
            return hour * 60 + min;
          }

          final minutesOfDay = parseTimeToMinutes(r.time);
          if (minutesOfDay == null) return false;

          if (_filterTimeFrom != null) {
            final startMinutes = _filterTimeFrom!.hour * 60 + _filterTimeFrom!.minute;
            if (minutesOfDay < startMinutes) return false;
          }
          if (_filterTimeTo != null) {
            final endMinutes = _filterTimeTo!.hour * 60 + _filterTimeTo!.minute;
            if (minutesOfDay > endMinutes) return false;
          }
        }

        // barrio filter
        if (_filterBarrios.isNotEmpty && !_filterBarrios.contains(r.neighborhood)) return false;

        // category filter
        if (_filterCategories.isNotEmpty && !_filterCategories.contains(r.category)) return false;

        return true;
      }).toList();
    });
  }

  void _openFilterSheet() async {
    // Use the canonical barrios list from the report creation widget
    final availableBarrios = List<String>.from(barriosSantaMarta);
    // Fixed categories per product requirement
    final availableCategories = ['Hurto Simple', 'Robo Violento', 'Otro'];

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
                                      .where((r) => r.lat != null && r.lng != null)
                                      .map((r) => Marker(
                                            point: LatLng(r.lat!, r.lng!),
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

