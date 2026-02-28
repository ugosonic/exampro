import 'package:flutter/material.dart';

class ZenovFooter extends StatelessWidget {
  final Color color;

  const ZenovFooter({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final sub = color.withValues(alpha: 0.75);
    final year = DateTime.now().year;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Developed by ZenovTech \u00A9 $year',
          textAlign: TextAlign.center,
          style: TextStyle(color: sub, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'info@zenovtech.com',
          textAlign: TextAlign.center,
          style: TextStyle(color: sub),
        ),
        const SizedBox(height: 4),
        Text(
          'Contact for websites and mobile app development',
          textAlign: TextAlign.center,
          style: TextStyle(color: sub),
        ),
      ],
    );
  }
}
