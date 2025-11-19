import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 44,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            elevation: 2,
            textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
          ),
          child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const LogoutButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 44,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0), side: BorderSide(color: Colors.grey.shade300)),
            elevation: 0,
            textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
          ),
          child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
