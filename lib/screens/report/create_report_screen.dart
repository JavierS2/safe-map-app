import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import '../../providers/report_provider.dart';

import 'widgets/report_header.dart';
import 'widgets/report_text_field.dart';
import 'widgets/report_dropdown_field.dart';
import 'widgets/evidence_upload_box.dart';
import 'widgets/barrios_santa_marta.dart';
import 'location_picker_screen.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _neighborhoodController =
      TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String _selectedCategory = 'Hurto simple';
  final List<String> _categories = ['Hurto simple', 'Robo violento', 'Otro'];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  GeoPoint? _selectedLocation; // ubicación escogida

  // 🔹 NUEVO: lista de evidencias (URLs Cloudinary)
  List<String> _evidenceUrls = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = now;
    _dateController.text = '${now.day}/${now.month}/${now.year}';

    _selectedTime = TimeOfDay.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime!.format(context);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _neighborhoodController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _setCurrentLocation() async {
    // Open a map picker that centers on device location and allows the user
    // to adjust the marker. Returns a GeoPoint when the user confirms.
    final result = await Navigator.of(context).push<GeoPoint>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ubicación seleccionada.")),
      );
    }
  }

  void _submitReport() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero envía tu ubicación.")),
      );
      return;
    }

    // Validate barrio is provided
    if ((_neighborhoodController.text.trim()).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El barrio es obligatorio.")),
      );
      return;
    }

    // Aquí asumimos que tu ReportProvider tiene un parámetro `evidences`
    final success = await provider.sendReport(
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      category: _selectedCategory,
      neighborhood: _neighborhoodController.text.trim(),
      details: _detailsController.text.trim(),
      lat: _selectedLocation!.latitude,
      lng: _selectedLocation!.longitude,
      evidences: _evidenceUrls, // 🔹 NUEVO
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? "Error inesperado")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reporte enviado correctamente")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            const ReportHeader(),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Fecha
                        ReportTextField(
                          label: 'Fecha',
                          controller: _dateController,
                          readOnly: true,
                          suffixIcon: Icons.calendar_today_outlined,
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 12),

                        // Hora
                        ReportTextField(
                          label: 'Hora',
                          controller: _timeController,
                          readOnly: true,
                          suffixIcon: Icons.access_time_outlined,
                          onTap: _selectTime,
                        ),
                        const SizedBox(height: 12),

                        // Categoría
                        ReportDropdownField(
                          label: 'Categoría',
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Barrio + ubicación
                        Text(
                          'Barrio',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: BarrioSearchField(
                                controller: _neighborhoodController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '¿Estás en el lugar de los hechos?',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 34,
                                    child: ElevatedButton(
                                      onPressed: _setCurrentLocation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        'Enviar ubicación',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Detalles
                        ReportTextField(
                          label: 'Detalles',
                          controller: _detailsController,
                          hintText: 'Describe lo que ocurrió...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Evidencias (Cloudinary)
                        EvidenceUploadBox(
                          onEvidenceChanged: (urls) {
                            setState(() {
                              _evidenceUrls = urls;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botón Reportar
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Reportar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
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
