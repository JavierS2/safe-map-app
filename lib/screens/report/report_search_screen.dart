import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/report_model.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'widgets/report_search_bar.dart';
import 'widgets/report_header.dart';
import 'widgets/report_filters.dart';
import 'widgets/report_list.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/time_range_picker_sheet.dart';
import 'widgets/date_picker_sheet.dart';
import 'widgets/neighborhood_dialog.dart';

class ReportSearchScreen extends StatefulWidget {
  const ReportSearchScreen({super.key});

  @override
  State<ReportSearchScreen> createState() => _ReportSearchScreenState();
}

class _ReportSearchScreenState extends State<ReportSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _innerScrollController = ScrollController();

  List<ReportModel> _allReports = [];
  List<ReportModel> _filtered = [];
  String? _selectedCategory;
  String? _selectedNeighborhood;
  String? _selectedNeighborhoodFilter;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
  String _normalizedQuery = '';

  String _normalize(String? s) {
    if (s == null) return '';
    var collapsed = s.trim().replaceAll(RegExp(r"\s+"), ' ').toLowerCase();
    const Map<String, String> _diacriticsMap = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', 'ē': 'e', 'ė': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'ī': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o', 'ō': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'ū': 'u',
      'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y',
      'œ': 'oe', 'æ': 'ae'
    };
    _diacriticsMap.forEach((k, v) { collapsed = collapsed.replaceAll(k, v); });
    collapsed = collapsed.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    return collapsed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      await provider.fetchAllReports();
      if (!mounted) return;
      setState(() {
        _allReports = List.from(provider.allReports);
        _filtered = List.from(_allReports);
      });
    });
  }

  void _onSearchChanged(String q) {
    _normalizedQuery = _normalize(q);
    _applyFilters();
  }

  void _applyFilters() {
    final query = _normalizedQuery.isNotEmpty ? _normalizedQuery : _normalize(_searchController.text);

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

    setState(() {
      _filtered = _allReports.where((r) {
        final title = _normalize(r.category);
        final neighborhood = _normalize(r.neighborhood);
        final dateTimeStr = '${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}/${r.date.year} - ${r.time}';
        final dateTime = _normalize(dateTimeStr);
        final description = _normalize(r.details);

        if (query.isNotEmpty) {
          final matchesQuery = title.contains(query) || neighborhood.contains(query) || dateTime.contains(query) || description.contains(query);
          if (!matchesQuery) return false;
        }

        if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
          if (r.category != _selectedCategory) return false;
        }

        if (_selectedNeighborhoodFilter != null && _selectedNeighborhoodFilter!.isNotEmpty) {
          final neigh = _normalize(r.neighborhood);
          if (!neigh.contains(_selectedNeighborhoodFilter!)) return false;
        }

        if (_selectedDate != null) {
          final expected = '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
          if (dateTimeStr.split(' - ').first != expected) return false;
        }

        if (_selectedTimeStart != null || _selectedTimeEnd != null) {
          final parts = dateTimeStr.split(' - ');
          if (parts.length < 2) return false;
          final minutesOfDay = parseTimeToMinutes(parts[1]);
          if (minutesOfDay == null) return false;
          if (_selectedTimeStart != null) {
            final startMinutes = _selectedTimeStart!.hour * 60 + _selectedTimeStart!.minute;
            if (minutesOfDay < startMinutes) return false;
          }
          if (_selectedTimeEnd != null) {
            final endMinutes = _selectedTimeEnd!.hour * 60 + _selectedTimeEnd!.minute;
            if (minutesOfDay > endMinutes) return false;
          }
        }

        return true;
      }).toList();
    });
  }

  Future<void> _showCategoryPicker() async {
    final categories = ['Hurto Simple', 'Robo Violento', 'Otro'];
    final picked = await showModalBottomSheet<String?>(context: context, builder: (_) => CategoryPickerSheet(categories: categories));
    if (picked != null) {
      _selectedCategory = picked.isEmpty ? null : picked;
      _applyFilters();
    }
  }

  Future<void> _showNeighborhoodDialog() async {
    final picked = await showDialog<String?>(context: context, builder: (_) => NeighborhoodDialog(initial: _selectedNeighborhood));
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
    final result = await showModalBottomSheet<Map<String, dynamic>?>(context: context, builder: (_) => DatePickerSheet(initialDate: _selectedDate));
    if (result == null) return; // canceled
    if (result['clear'] == true) {
      _selectedDate = null;
      _applyFilters();
      return;
    }
    _selectedDate = result['date'] as DateTime?;
    _applyFilters();
  }

  Future<void> _showTimeRangePicker() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(context: context, builder: (_) => TimeRangePickerSheet(start: _selectedTimeStart, end: _selectedTimeEnd));
    if (result == null) return; // canceled
    if (result['clear'] == true) {
      _selectedTimeStart = null;
      _selectedTimeEnd = null;
      _applyFilters();
      return;
    }
    _selectedTimeStart = result['start'] as TimeOfDay?;
    _selectedTimeEnd = result['end'] as TimeOfDay?;
    _applyFilters();
  }

  Future<void> _pickTime() async {
    await _showTimeRangePicker();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(selectedRoute: AppRoutes.reportSearch),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 104),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              controller: _innerScrollController,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                                    timeLabel: (_selectedTimeStart == null && _selectedTimeEnd == null)
                                        ? 'Hora'
                                        : (_selectedTimeStart != null && _selectedTimeEnd != null)
                                            ? '${_selectedTimeStart!.format(context)} - ${_selectedTimeEnd!.format(context)}'
                                            : (_selectedTimeStart != null)
                                                ? 'Desde ${_selectedTimeStart!.format(context)}'
                                                : 'Hasta ${_selectedTimeEnd!.format(context)}',
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
                                        final provider = Provider.of<ReportProvider>(context, listen: false);
                                        provider.viewReport(r);
                                        Navigator.pushNamed(context, AppRoutes.viewDetails, arguments: {'reportId': r.id});
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
              ),
            );
          },
        ),
      ),
    );
  }
}
