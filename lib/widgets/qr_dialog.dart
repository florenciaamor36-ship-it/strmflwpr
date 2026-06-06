import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../models/sale_model.dart';
import '../utils/date_utils.dart';

class QrDialog extends StatelessWidget {
  final SaleModel sale;

  const QrDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrData = sale.clientPageUrl;
    final displayData =
        '${sale.clientName}\n${sale.platformName} · ${sale.profileName}\nVence: ${AppDateUtils.formatDate(sale.expirationDate)}';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.qr_code),
          const SizedBox(width: 8),
          Expanded(
            child: Text(sale.clientName, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Sale info
            Text(
              displayData,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              qrData,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Compartir link'),
          onPressed: () {
            Share.share(
              'Tu acceso a ${sale.platformName}: $qrData\n\n${sale.clientName} - ${sale.profileName}\nVence: ${AppDateUtils.formatDate(sale.expirationDate)}',
              subject: 'Tu acceso a ${sale.platformName}',
            );
          },
        ),
      ],
    );
  }
}
