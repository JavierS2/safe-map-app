import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, this.logoImage});

  final ImageProvider? logoImage;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(12));
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: logoImage != null
          ? ClipRRect(
              borderRadius: borderRadius,
              child: Image(
                image: logoImage!,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.location_on_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
    );
  }
}
