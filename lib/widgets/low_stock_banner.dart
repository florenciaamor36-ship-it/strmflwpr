import 'package:flutter/material.dart';

class LowStockBanner extends StatefulWidget {
  final int platformCount;
  final VoidCallback onTap;

  const LowStockBanner({
    super.key,
    required this.platformCount,
    required this.onTap,
  });

  @override
  State<LowStockBanner> createState() => _LowStockBannerState();
}

class _LowStockBannerState extends State<LowStockBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.platformCount} plataforma${widget.platformCount > 1 ? "s" : ""} sin perfiles disponibles. Tocá para ver el stock.',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: Colors.orange.shade700,
              onPressed: () => setState(() => _dismissed = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
