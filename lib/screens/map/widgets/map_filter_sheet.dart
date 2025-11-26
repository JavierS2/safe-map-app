import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../report/widgets/barrios_santa_marta.dart';

class MapFilterSheet extends StatefulWidget {
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;
  final TimeOfDay? initialTimeFrom;
  final TimeOfDay? initialTimeTo;
  final List<String> barrios;
  final List<String> categories;
  final Set<String> initialSelectedBarrios;
  final Set<String> initialSelectedCategories;

  const MapFilterSheet({
    Key? key,
    this.initialDateFrom,
    this.initialDateTo,
    this.initialTimeFrom,
    this.initialTimeTo,
    required this.barrios,
    required this.categories,
    required this.initialSelectedBarrios,
    required this.initialSelectedCategories,
  }) : super(key: key);

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  TimeOfDay? _timeFrom;
  TimeOfDay? _timeTo;
  late Set<String> _selectedBarrios;
  late Set<String> _selectedCategories;
  late TextEditingController _barrioController;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
    _timeFrom = widget.initialTimeFrom;
    _timeTo = widget.initialTimeTo;
    _selectedBarrios = Set.from(widget.initialSelectedBarrios);
    _selectedCategories = Set.from(widget.initialSelectedCategories);
    _barrioController = TextEditingController(text: _selectedBarrios.isNotEmpty ? _selectedBarrios.first : '');
  }

  @override
  void dispose() {
    _barrioController.dispose();
    super.dispose();
  }

  Future<void> _pickDateFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _dateFrom = picked);
  }

  Future<void> _pickDateTo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _dateTo = picked);
  }

  Future<void> _pickTimeFrom() async {
    final picked = await showTimePicker(context: context, initialTime: _timeFrom ?? TimeOfDay(hour: 0, minute: 0));
    if (picked != null) setState(() => _timeFrom = picked);
  }

  Future<void> _pickTimeTo() async {
    final picked = await showTimePicker(context: context, initialTime: _timeTo ?? TimeOfDay(hour: 23, minute: 59));
    if (picked != null) setState(() => _timeTo = picked);
  }

  Widget _buildChips(List<String> items, Set<String> selected, void Function(String, bool) onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items.map((i) {
        final sel = selected.contains(i);
        return FilterChip(
          label: Text(i, style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary)),
          selected: sel,
          showCheckmark: false,
          selectedColor: const Color.fromARGB(255, 60, 60, 60),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: sel ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
          ),
          onSelected: (v) => setState(() => onChanged(i, v)),
        );
      }).toList(),
    );
  }

  void _apply() {
    final barrios = <String>[];
    if (_barrioController.text.trim().isNotEmpty) barrios.add(_barrioController.text.trim());
    Navigator.of(context).pop({
      'dateFrom': _dateFrom,
      'dateTo': _dateTo,
      'timeFrom': _timeFrom,
      'timeTo': _timeTo,
      'barrios': barrios,
      'categories': _selectedCategories.toList(),
    });
  }

  void _clear() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _timeFrom = null;
      _timeTo = null;
      _selectedBarrios.clear();
      _barrioController.clear();
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _clear, child: const Text('Limpiar')),
                ],
              ),

              const SizedBox(height: 8),
              Text('Fecha (desde - hasta)', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateFrom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_dateFrom == null ? 'Desde' : '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateTo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_dateTo == null ? 'Hasta' : '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'),
                  ),
                ),
              ]),

              const SizedBox(height: 12),
              Text('Hora (desde - hasta)', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTimeFrom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_timeFrom == null ? 'Desde' : _timeFrom!.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTimeTo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_timeTo == null ? 'Hasta' : _timeTo!.format(context)),
                  ),
                ),
              ]),

              const SizedBox(height: 12),
              Text('Barrio', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              // Use the reusable BarrioSearchField to show a searchable dropdown-like list
              BarrioSearchField(controller: _barrioController),

              const SizedBox(height: 12),
              Text('Tipo', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              _buildChips(widget.categories, _selectedCategories, (s, v) => v ? _selectedCategories.add(s) : _selectedCategories.remove(s)),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Filtrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
