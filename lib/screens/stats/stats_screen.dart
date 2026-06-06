import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/stats_service.dart';
import '../../models/sale_model.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId ?? '';
    final settings = context.read<SettingsProvider>();
    final service = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: StreamBuilder<List<SaleModel>>(
        stream: service.salesStream(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sales = snap.data ?? [];
          final activeSales =
              sales.where((s) => s.status == SaleStatus.active).toList();
          final totalRevenue = StatsService.totalRevenueAllTime(sales);
          final monthRevenue =
              StatsService.totalRevenueThisMonth(sales);
          final avgPrice = StatsService.averageSalePrice(sales);
          final bestPlatform =
              StatsService.bestPlatformByRevenue(sales);
          final revenueByPlatform =
              StatsService.revenueByPlatform(sales);
          final monthlyRevenue =
              StatsService.monthlyRevenueLast6Months(sales);
          final uniqueClients =
              StatsService.uniqueClientsCount(activeSales);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Este mes',
                      value: CurrencyUtils.formatCompact(monthRevenue,
                          symbol: settings.currencySymbol),
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total histórico',
                      value: CurrencyUtils.formatCompact(totalRevenue,
                          symbol: settings.currencySymbol),
                      icon: Icons.account_balance_wallet,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Clientes activos',
                      value: '$uniqueClients',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Precio promedio',
                      value: CurrencyUtils.formatCompact(avgPrice,
                          symbol: settings.currencySymbol),
                      icon: Icons.price_check,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Best platform
              if (bestPlatform != null) ...[
                Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                    title: const Text('Mejor plataforma'),
                    subtitle: Text(bestPlatform),
                    trailing: Text(
                      CurrencyUtils.formatCompact(
                          revenueByPlatform[bestPlatform] ?? 0,
                          symbol: settings.currencySymbol),
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Monthly revenue chart
              if (monthlyRevenue.isNotEmpty) ...[
                Text('Ingresos últimos 6 meses',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _MonthlyLineChart(
                    data: monthlyRevenue,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Revenue by platform pie chart
              if (revenueByPlatform.isNotEmpty) ...[
                Text('Ingresos por plataforma',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: _PlatformPieChart(data: revenueByPlatform),
                ),
                const SizedBox(height: 16),

                // Legend
                ...revenueByPlatform.entries.toList().asMap().entries.map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _pieColors[
                                entry.key % _pieColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(entry.value.key),
                        trailing: Text(
                          CurrencyUtils.format(entry.value.value,
                              symbol: settings.currencySymbol),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
              ],

              if (sales.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Todavía no hay datos',
                            style: TextStyle(fontSize: 16)),
                        Text(
                            'Las estadísticas aparecerán cuando tengas ventas',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

const List<Color> _pieColors = [
  Color(0xFF6C63FF),
  Color(0xFF03DAC6),
  Color(0xFFFF6B6B),
  Color(0xFFFFB347),
  Color(0xFF4ECDC4),
  Color(0xFF45B7D1),
  Color(0xFFFF8A65),
];

class _MonthlyLineChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final Color color;

  const _MonthlyLineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}K',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                final key = data[index].key;
                final parts = key.split('-');
                final month = parts.length > 1 ? parts[1] : key;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _monthLabel(int.tryParse(month) ?? 0),
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              getDotPainter: (spot, _, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: color,
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return month > 0 && month <= 12 ? months[month] : '';
  }
}

class _PlatformPieChart extends StatelessWidget {
  final Map<String, double> data;

  const _PlatformPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    final sections = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      final percentage = (e.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: _pieColors[index % _pieColors.length],
        value: e.value,
        title: '$percentage%',
        radius: 80,
        titleStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 3,
        centerSpaceRadius: 30,
      ),
    );
  }
}
