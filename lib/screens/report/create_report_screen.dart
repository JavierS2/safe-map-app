import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/safe_bottom_nav_bar.dart';
import 'widgets/report_header.dart';
import 'widgets/report_text_field.dart';
import 'widgets/report_dropdown_field.dart';
import 'widgets/evidence_upload_box.dart';

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

  String _selectedCategory = 'Hurto';
  final List<String> _categories = ['Hurto', 'Robo', 'Acoso', 'Otro'];

  @override
  void initState() {
    super.initState();
    _dateController.text = 'Octubre 29, 2025';
    _timeController.text = '11:45 P.M';
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
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitReport() {
    // TODO: enviar datos a tu backend / firestore, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte enviado (demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header azul con título
            const ReportHeader(),

            // extend blue a bit so top of white panel overlays blue
            Container(height: 48, color: AppColors.primary),

            // White rounded panel overlapping the header
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ReportTextField(
                                controller: _neighborhoodController,
                                label: null,
                                hintText: 'Escribe el barrio',
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
                                      onPressed: () {
                                        // TODO: obtener ubicación actual
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
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
                        // Evidencias
                        const EvidenceUploadBox(),
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
