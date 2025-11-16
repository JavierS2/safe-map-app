import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        // Wrap child in a Stack so we can overlay the error above the field
        Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (errorText != null)
              Positioned(
                top: -14,
                right: 6,
                child: GestureDetector(
                  onTap: () {
                    // show full message on tap
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(errorText!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Tooltip(
                    message: errorText!,
                    preferBelow: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              errorText!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.error_outline,
                              size: 14, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
