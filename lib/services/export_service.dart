import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/sale_model.dart';
import '../models/client_model.dart';
import '../utils/date_utils.dart';

class ExportService {
  /// Export all sales to CSV, returns the file path
  static Future<String> exportSalesToCsv(List<SaleModel> sales) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'ID,Cliente,Teléfono,Plataforma,Perfil,Email,Precio,Inicio,Vencimiento,Estado,Renovaciones');

    // Rows
    for (final sale in sales) {
      final row = [
        sale.id,
        _escape(sale.clientName),
        sale.clientPhone,
        _escape(sale.platformName),
        _escape(sale.profileName),
        sale.accountEmail,
        sale.price.toStringAsFixed(2),
        AppDateUtils.formatDate(sale.startDate),
        AppDateUtils.formatDate(sale.expirationDate),
        SaleModel.statusToString(sale.status),
        sale.renewalCount.toString(),
      ].join(',');
      buffer.writeln(row);
    }

    return _writeFile('ventas_${_timestamp()}.csv', buffer.toString());
  }

  /// Export a per-client report
  static Future<String> exportClientReport(
      ClientModel client, List<SaleModel> sales) async {
    final buffer = StringBuffer();

    buffer.writeln('REPORTE DE CLIENTE');
    buffer.writeln('==================');
    buffer.writeln('Nombre: ${client.name}');
    buffer.writeln('Teléfono: ${client.phone}');
    buffer.writeln('Email: ${client.email}');
    buffer.writeln('Notas: ${client.notes}');
    buffer.writeln('Generado: ${AppDateUtils.formatDateTime(DateTime.now())}');
    buffer.writeln();
    buffer.writeln('HISTORIAL DE COMPRAS');
    buffer.writeln('──────────────────────');

    double total = 0;
    for (final sale in sales) {
      buffer.writeln(
          '${sale.platformName} - ${sale.profileName}');
      buffer.writeln(
          '  Inicio: ${AppDateUtils.formatDate(sale.startDate)}');
      buffer.writeln(
          '  Vencimiento: ${AppDateUtils.formatDate(sale.expirationDate)}');
      buffer.writeln(
          '  Precio: \$${sale.price.toStringAsFixed(2)}');
      buffer.writeln(
          '  Estado: ${SaleModel.statusToString(sale.status)}');
      buffer.writeln();
      total += sale.price;
    }

    buffer.writeln('──────────────────────');
    buffer.writeln('TOTAL GASTADO: \$${total.toStringAsFixed(2)}');

    final fileName =
        'cliente_${client.name.replaceAll(' ', '_')}_${_timestamp()}.txt';
    return _writeFile(fileName, buffer.toString());
  }

  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'strmflwpr Export',
    );
  }

  static Future<String> _writeFile(String fileName, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content, encoding: const SystemEncoding());
    return file.path;
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
}
