import 'package:latlong2/latlong.dart';

class Report {
  final String id;
  final String title;
  final String barrio;
  final String category;
  final DateTime timestamp;
  final LatLng position;
  final String? description;

  const Report({
    required this.id,
    required this.title,
    required this.barrio,
    required this.category,
    required this.timestamp,
    required this.position,
    this.description,
  });
}
