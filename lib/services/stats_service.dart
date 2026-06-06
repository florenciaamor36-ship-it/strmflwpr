import '../models/sale_model.dart';
import '../models/profile_model.dart';
import '../utils/date_utils.dart';

class StatsService {
  /// Total revenue for the current month
  static double totalRevenueThisMonth(List<SaleModel> sales) {
    final now = DateTime.now();
    return sales
        .where((s) =>
            s.createdAt.year == now.year && s.createdAt.month == now.month)
        .fold(0.0, (sum, s) => sum + s.price);
  }

  /// Total revenue all time
  static double totalRevenueAllTime(List<SaleModel> sales) {
    return sales.fold(0.0, (sum, s) => sum + s.price);
  }

  /// Revenue grouped by platform name
  static Map<String, double> revenueByPlatform(List<SaleModel> sales) {
    final Map<String, double> result = {};
    for (final sale in sales) {
      result[sale.platformName] =
          (result[sale.platformName] ?? 0) + sale.price;
    }
    return result;
  }

  /// Sale count grouped by platform
  static Map<String, int> salesCountByPlatform(List<SaleModel> sales) {
    final Map<String, int> result = {};
    for (final sale in sales) {
      result[sale.platformName] = (result[sale.platformName] ?? 0) + 1;
    }
    return result;
  }

  /// Revenue per month for the last N months (sorted ascending)
  static List<MapEntry<String, double>> monthlyRevenueLast6Months(
      List<SaleModel> sales) {
    final months = AppDateUtils.last6MonthStarts();
    final Map<String, double> result = {};

    for (final monthStart in months) {
      final key =
          '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}';
      result[key] = 0.0;
    }

    for (final sale in sales) {
      final key =
          '${sale.createdAt.year}-${sale.createdAt.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        result[key] = result[key]! + sale.price;
      }
    }

    final entries = result.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Count of available profiles across all
  static int availableProfilesCount(List<ProfileModel> profiles) {
    return profiles.where((p) => p.status == ProfileStatus.available).length;
  }

  /// Active sales expiring within N days
  static List<SaleModel> expiringSoon(List<SaleModel> sales, int days) {
    return sales.where((s) {
      if (s.status != SaleStatus.active) return false;
      final remaining = s.daysRemaining;
      return remaining >= 0 && remaining <= days;
    }).toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
  }

  /// Expired sales (status still active but date passed)
  static List<SaleModel> overdueActive(List<SaleModel> sales) {
    return sales.where((s) {
      if (s.status != SaleStatus.active) return false;
      return s.daysRemaining < 0;
    }).toList();
  }

  /// Average sale price
  static double averageSalePrice(List<SaleModel> sales) {
    if (sales.isEmpty) return 0;
    return totalRevenueAllTime(sales) / sales.length;
  }

  /// Best performing platform (by revenue)
  static String? bestPlatformByRevenue(List<SaleModel> sales) {
    if (sales.isEmpty) return null;
    final rev = revenueByPlatform(sales);
    if (rev.isEmpty) return null;
    return rev.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Number of unique clients
  static int uniqueClientsCount(List<SaleModel> sales) {
    return sales.map((s) => s.clientId).toSet().length;
  }

  /// Platforms with zero available profiles
  static List<String> platformsWithNoStock(
      Map<String, Map<String, int>> inventory) {
    return inventory.entries
        .where((e) => (e.value['available'] ?? 0) == 0)
        .map((e) => e.key)
        .toList();
  }
}
