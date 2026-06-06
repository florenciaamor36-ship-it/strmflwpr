import 'package:flutter/material.dart';

class ExpirationBadge extends StatelessWidget {
  final int daysRemaining;

  const ExpirationBadge({super.key, required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    if (daysRemaining < 0) {
      color = Colors.red;
      text = 'Vencido';
    } else if (daysRemaining == 0) {
      color = Colors.red;
      text = 'Hoy';
    } else if (daysRemaining <= 3) {
      color = Colors.red;
      text = '${daysRemaining}d';
    } else if (daysRemaining <= 7) {
      color = Colors.orange;
      text = '${daysRemaining}d';
    } else if (daysRemaining <= 14) {
      color = const Color(0xFFD4AC0D); // amber-ish
      text = '${daysRemaining}d';
    } else {
      color = Colors.green;
      text = '${daysRemaining}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
