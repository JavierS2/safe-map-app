import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'widgets/report_search_bar.dart';
import 'widgets/report_header.dart';
import 'widgets/report_result_card.dart';
import 'widgets/report_filters.dart';
import 'widgets/report_list.dart';

class ReportSearchScreen extends StatefulWidget {
  const ReportSearchScreen({super.key});

  @override
  State<ReportSearchScreen> createState() => _ReportSearchScreenState();
}

class _ReportSearchScreenState extends State<ReportSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allReports = [
    {
      'neighborhood': 'El Líbano',
      'dateTime': '30/10/2025 - 07:20',
      'type': 'Hurto simple',
      'description': 'Arrebato de celular en zona turística cerca al parque.',
    },
    {
      'neighborhood': 'Mamatoco',
      'dateTime': '29/10/2025 - 20:15',
      'type': 'Robo violento',
      'description': 'Intento de robo con arma en la vía principal.',
    },
    {
      'neighborhood': 'El Prado',
      'dateTime': '29/10/2025 - 14:50',
      'type': 'Hurto simple',
      'description': 'Hurto de pertenencias en transporte público.',
    },
  ];

  List<Map<String, String>> _filtered = [];
  String? _selectedCategory;
  String? _selectedNeighborhood;
  String? _selectedNeighborhoodFilter;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _normalizedQuery = '';

  String _normalize(String? s) {
    if (s == null) return '';
    // trim, collapse multiple spaces and lowercase for stable comparisons
    var collapsed = s.trim().replaceAll(RegExp(r"\s+"), ' ').toLowerCase();

    // remove common diacritics (Spanish/Latin) so searches ignore accents
    const Map<String, String> _diacriticsMap = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', 'ē': 'e', 'ė': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'ī': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', 'ō': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'ū': 'u',
      'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y',
      'œ': 'oe', 'æ': 'ae'
    };

    _diacriticsMap.forEach((k, v) {
      collapsed = collapsed.replaceAll(k, v);
    });

    // remove punctuation and other non-alphanumeric chars to make contains() checks reliable
    collapsed = collapsed.replaceAll(RegExp(r'[^a-z0-9\s]'), '');

    return collapsed;
  }

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allReports);
  }

  void _onSearchChanged(String q) {
    _normalizedQuery = _normalize(q);
    _applyFilters();
  }

  void _applyFilters() {
    final query = _normalizedQuery.isNotEmpty ? _normalizedQuery : _normalize(_searchController.text);

    setState(() {
      _filtered = _allReports.where((r) {
        // search query across fields
        if (query.isNotEmpty) {
          // explicitly check the important fields so description is always included
          final title = _normalize(r['type']);
          final neighborhood = _normalize(r['neighborhood']);
          final dateTime = _normalize(r['dateTime']);
          final description = _normalize(r['description']);

          final matchesQuery = title.contains(query) ||
              neighborhood.contains(query) ||
              dateTime.contains(query) ||
              description.contains(query);

          if (!matchesQuery) return false;
        }

        if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
          if ((r['type'] ?? '') != _selectedCategory) return false;
        }

        if (_selectedNeighborhoodFilter != null && _selectedNeighborhoodFilter!.isNotEmpty) {
          final neigh = _normalize(r['neighborhood']);
          if (!neigh.contains(_selectedNeighborhoodFilter!)) return false;
        }

        if (_selectedDate != null) {
          final parts = (r['dateTime'] ?? '').split(' - ');
          if (parts.isEmpty) return false;
          final dateStr = parts[0]; // dd/MM/yyyy
          final expected = '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
          if (dateStr != expected) return false;
        }

        if (_selectedTime != null) {
          final parts = (r['dateTime'] ?? '').split(' - ');
          if (parts.length < 2) return false;
          final timeStr = parts[1]; // HH:mm
          final expected = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
          if (timeStr != expected) return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _showCategoryPicker() async {
    final categories = _allReports.map((e) => e['type'] ?? '').toSet().toList();
    final picked = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) {
        return ListView(
          children: [
            ListTile(
              title: const Text('Clear'),
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            ...categories.map((c) => ListTile(
                  title: Text(c),
                  onTap: () => Navigator.of(ctx).pop(c),
                )),
          ],
        );
      },
    );

    if (picked != null) {
      _selectedCategory = picked.isEmpty ? null : picked;
      _applyFilters();
    }
  }

  Future<void> _showNeighborhoodDialog() async {
    final controller = TextEditingController(text: _selectedNeighborhood);
    final picked = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Buscar barrio'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Escribe el barrio'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Apply')),
          ],
        );
      },
    );

    if (picked != null) {
      if (picked.isEmpty) {
        _selectedNeighborhood = null;
        _selectedNeighborhoodFilter = null;
      } else {
        _selectedNeighborhood = picked;
        _selectedNeighborhoodFilter = _normalize(picked);
      }
      _applyFilters();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _selectedDate = picked;
      _applyFilters();
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (picked != null) {
      _selectedTime = picked;
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.reportSearch),
      body: SafeArea(
        child: Column(
          children: [
            const ReportHeader(title: 'Buscar reportes'),

            // extender azul como en otras pantallas
            Container(height: 48, color: AppColors.primary),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFFFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReportSearchBar(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                        ),

                        const SizedBox(height: 12),

                        // Filter chips / buttons (centered and responsive)
                        ReportFilters(
                          categoryLabel: _selectedCategory ?? 'Categoría',
                          neighborhoodLabel: _selectedNeighborhood ?? 'Barrio',
                          dateLabel: _selectedDate != null
                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                              : 'Fecha',
                          timeLabel: _selectedTime != null
                              ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                              : 'Hora',
                          onCategoryTap: _showCategoryPicker,
                          onNeighborhoodTap: _showNeighborhoodDialog,
                          onDateTap: _pickDate,
                          onTimeTap: _pickTime,
                        ),

                        const SizedBox(height: 12),

                        if (_filtered.isEmpty)
                          Center(
                            child: Text(
                              'No reports found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        else
                          ReportList(
                            reports: _filtered,
                            onTap: (r) {
                              // place for navigation to detail or further action
                            },
                          ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
