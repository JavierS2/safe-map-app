import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../config/routes.dart';
import 'widgets/report_search_bar.dart';
import 'widgets/report_header.dart';
import 'widgets/report_filters.dart';
import 'widgets/report_list.dart';

class ReportSearchScreen extends StatefulWidget {
  const ReportSearchScreen({super.key});

  @override
  State<ReportSearchScreen> createState() => _ReportSearchScreenState();
}

class _ReportSearchScreenState extends State<ReportSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _innerScrollController = ScrollController();
  bool _reserveBottomPadding = false;
  final GlobalKey _contentKey = GlobalKey();
  double? _lastConstraintsMaxHeight;
  bool _useOuterPadding = false;

  List<Map<String, String>> _allReports = [];

  List<Map<String, String>> _filtered = [];
  String? _selectedCategory;
  String? _selectedNeighborhood;
  String? _selectedNeighborhoodFilter;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeStart;
  TimeOfDay? _selectedTimeEnd;
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
    _filtered = [];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      await provider.fetchAllReports();

      if (!mounted) return;
      setState(() {
        _allReports = provider.allReports
            .map((r) => {
                  'neighborhood': r.neighborhood,
                  'dateTime':
                      '${r.date.day.toString().padLeft(2, '0')}/${r.date.month.toString().padLeft(2, '0')}/${r.date.year} - ${r.time}',
                  'type': r.category,
                  'description': r.details,
                })
            .toList();
        _filtered = List.from(_allReports);
      });

      _updateReservePadding();
    });
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

        // Time range filtering: parse the report time and ensure it falls within start/end if provided
        if (_selectedTimeStart != null || _selectedTimeEnd != null) {
          final parts = (r['dateTime'] ?? '').split(' - ');
          if (parts.length < 2) return false;
          final timeStr = parts[1].trim(); // could be '07:20', '7:20 AM', '11:45 PM', etc.

          int? parseTimeToMinutes(String s) {
            final reg = RegExp(r"^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?");
            final m = reg.firstMatch(s);
            if (m == null) return null;
            final hStr = m.group(1);
            final mStr = m.group(2);
            final ampm = m.group(3);
            final h = int.tryParse(hStr ?? '0');
            final min = int.tryParse(mStr ?? '0');
            if (h == null || min == null) return null;
            var hour = h;
            if (ampm != null) {
              final a = ampm.toLowerCase();
              if (a == 'pm' && hour < 12) hour += 12;
              if (a == 'am' && hour == 12) hour = 0;
            }
            return hour * 60 + min;
          }

          final minutesOfDay = parseTimeToMinutes(timeStr);
          if (minutesOfDay == null) return false;

          if (_selectedTimeStart != null) {
            final int startMinutes = _selectedTimeStart!.hour * 60 + _selectedTimeStart!.minute;
            if (minutesOfDay < startMinutes) return false;
          }
          if (_selectedTimeEnd != null) {
            final int endMinutes = _selectedTimeEnd!.hour * 60 + _selectedTimeEnd!.minute;
            if (minutesOfDay > endMinutes) return false;
          }
        }

        return true;
      }).toList();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateReservePadding());
  }

  void _updateReservePadding() {
    if (!mounted) return;
    if (!_innerScrollController.hasClients) {
      setState(() {
        _reserveBottomPadding = false;
      });
      return;
    }

    final needs = _innerScrollController.position.maxScrollExtent > 0;
    if (needs != _reserveBottomPadding) {
      setState(() {
        _reserveBottomPadding = needs;
      });
    }
    // also trigger content measurement to decide outer padding
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureContent());
  }

  void _measureContent() {
    if (!mounted) return;
    final ctx = _contentKey.currentContext;
    if (ctx == null || _lastConstraintsMaxHeight == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final contentHeight = box.size.height;
    final needsOuter = contentHeight > _lastConstraintsMaxHeight!;
    if (needsOuter != _useOuterPadding) {
      setState(() {
        _useOuterPadding = needsOuter;
      });
    }
  }

  Future<void> _showCategoryPicker() async {
    // Fixed category list as requested
    final categories = ['Hurto Simple', 'Robo Violento', 'Otro'];
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
            TextButton(onPressed: () => Navigator.of(ctx).pop(''), child: const Text('Clear')),
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
    // Use a bottom sheet with an inline CalendarDatePicker so we can provide Clear
    DateTime temp = _selectedDate ?? DateTime.now();
    final picked = await showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Clear')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(temp), child: const Text('Apply')),
                  ],
                ),
              ),
              SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: temp,
                  firstDate: DateTime(temp.year - 5),
                  lastDate: DateTime(temp.year + 5),
                  onDateChanged: (d) {
                    temp = d;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    final DateTime? pickedDate = picked;
    if (pickedDate == null) {
      // cleared
      if (_selectedDate != null) {
        _selectedDate = null;
        _applyFilters();
      }
    } else {
      _selectedDate = pickedDate;
      _applyFilters();
    }
  }

  Future<void> _showTimeRangePicker() async {
    TimeOfDay? tempStart = _selectedTimeStart;
    TimeOfDay? tempEnd = _selectedTimeEnd;

    final result = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Clear')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Apply')),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Hora inicio'),
                subtitle: Text(tempStart?.format(ctx) ?? 'No establecido'),
                onTap: () async {
                  final picked = await showTimePicker(context: ctx, initialTime: tempStart ?? TimeOfDay(hour: 0, minute: 0));
                  if (picked != null) tempStart = picked;
                },
              ),
              ListTile(
                title: const Text('Hora fin'),
                subtitle: Text(tempEnd?.format(ctx) ?? 'No establecido'),
                onTap: () async {
                  final picked = await showTimePicker(context: ctx, initialTime: tempEnd ?? TimeOfDay(hour: 23, minute: 59));
                  if (picked != null) tempEnd = picked;
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (result == false) {
      // Clear requested
      _selectedTimeStart = null;
      _selectedTimeEnd = null;
      _applyFilters();
    } else if (result == true) {
      _selectedTimeStart = tempStart;
      _selectedTimeEnd = tempEnd;
      _applyFilters();
    }
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
              ),
            );
          },
        ),
      ),
    );
  }
}
