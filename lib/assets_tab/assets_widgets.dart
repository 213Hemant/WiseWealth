// lib/assets_tab/assets_widgets.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';

/// Displays the Total Assets value in a card.
class TotalAssetsSection extends StatelessWidget {
  const TotalAssetsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Assets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${assetProvider.totalAssets.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a pie chart for asset allocation. Tapping on it navigates to a detailed view.
class PieChartSection extends StatelessWidget {
  const PieChartSection({super.key});

  // Returns a color based on asset type.
  Color _getColor(String assetType) {
    switch (assetType) {
      case "Real Estate":
        return Colors.blue;
      case "Investment":
        return Colors.green;
      case "Cash":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    final distribution = assetProvider.assetDistribution;

    if (assetProvider.totalAssets == 0) {
      return const Text("No assets to display allocation.");
    }

    // Generate sections for the PieChart.
    final sections = distribution.entries.map((entry) {
      final percentage = (entry.value / assetProvider.totalAssets) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: "${entry.key}\n${percentage.toStringAsFixed(1)}%",
        color: _getColor(entry.key),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return GestureDetector(
      onTap: () {
        // Navigate to a detailed asset allocation view.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AssetAllocationDetailScreen(),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Asset Allocation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays a line chart for asset growth over time with a smoother look and animation.
/// Tapping on it navigates to a detailed view. This chart uses data from AssetProvider's
/// netWorthHistory list (which should record each net worth change on add/remove).
class AssetGrowthGraphSection extends StatelessWidget {
  const AssetGrowthGraphSection({super.key});

  // Generate spots from net worth history.
  List<FlSpot> _generateSpotsFromHistory(List netWorthHistory) {
    // Sort events by timestamp to ensure chronological order.
    netWorthHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return netWorthHistory.map<FlSpot>((event) {
      return FlSpot(
        event.timestamp.millisecondsSinceEpoch.toDouble(),
        event.netWorth,
      );
    }).toList();
  }

  // Format timestamp as HH:mm or HH:mm:ss if needed.
  String _formatTimestamp(double timestamp) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat.Hm().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    final netWorthHistory = assetProvider.netWorthHistory;

    if (netWorthHistory.isEmpty) {
      return const Text("No data to display asset growth.");
    }

    // Show a sliding window of the last 10 events if there are more than 10.
    final recentHistory = netWorthHistory.length > 10
        ? netWorthHistory.sublist(netWorthHistory.length - 10)
        : netWorthHistory;
    final spots = _generateSpotsFromHistory(recentHistory);

    // Determine chart boundaries.
    final double minX = spots.first.x;
    final double maxX = spots.last.x;
    double minY = spots.first.y;
    double maxY = spots.first.y;
    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }
    // Ensure intervals are not zero.
    final double intervalX = (maxX - minX) == 0 ? 1 : (maxX - minX) / 4;
    final double intervalY = (maxY - minY) == 0 ? 1 : (maxY - minY) / 4;

    return GestureDetector(
      onTap: () {
        // Navigate to a detailed asset growth view.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssetGrowthDetailScreen()),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Asset Growth Over Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    // Instead of specifying swapAnimationDuration in the data,
                    // we do it in the LineChart constructor below.

                    minX: minX,
                    maxX: maxX,
                    minY: minY * 0.95,
                    maxY: maxY * 1.05,

                    // Interaction / tooltip
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        // tooltipBgColor: Colors.blueAccent,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              "${_formatTimestamp(spot.x)}\n₹${spot.y.toStringAsFixed(2)}",
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    // Remove the chart border, keep grid lines for reference
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: intervalY,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: intervalX,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatTimestamp(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: intervalY,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              "₹${value.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        barWidth: 3,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  // Animate transitions for each new data set
                  // swapAnimationDuration: const Duration(milliseconds: 800),
                  // swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays a list of recent assets.
class RecentAssetsSection extends StatelessWidget {
  const RecentAssetsSection({super.key});

  IconData _getIconForAsset(Asset asset) {
    switch (asset.type) {
      case "Real Estate":
        return Icons.home;
      case "Investment":
        return Icons.trending_up;
      case "Cash":
        return Icons.money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    final recentAssets = assetProvider.recentAssets;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Assets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (recentAssets.isNotEmpty)
              ...recentAssets.map((asset) => ListTile(
                    leading: Icon(_getIconForAsset(asset)),
                    title: Text(asset.name),
                    subtitle: Text("₹${asset.value.toStringAsFixed(2)}"),
                  ))
            else
              const Text("No recent assets added."),
          ],
        ),
      ),
    );
  }
}

/// Dummy detailed view for Asset Allocation.
class AssetAllocationDetailScreen extends StatelessWidget {
  const AssetAllocationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asset Allocation Details")),
      body: const Center(child: Text("Detailed view for Asset Allocation")),
    );
  }
}

/// Dummy detailed view for Asset Growth.
class AssetGrowthDetailScreen extends StatelessWidget {
  const AssetGrowthDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asset Growth Details")),
      body: const Center(child: Text("Detailed view for Asset Growth")),
    );
  }
}
