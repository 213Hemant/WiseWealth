// lib/providers/asset_provider.dart
import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/net_worth_event.dart';

class AssetProvider extends ChangeNotifier {
  final List<Asset> _assets = [];
  final List<NetWorthEvent> _netWorthHistory = [];

  List<Asset> get assets => _assets;

  double get totalAssets =>
      _assets.fold(0, (previous, element) => previous + element.value);

  /// Returns a mapping of asset type to total value.
  Map<String, double> get assetDistribution {
    Map<String, double> distribution = {};
    for (var asset in _assets) {
      distribution[asset.type] = (distribution[asset.type] ?? 0) + asset.value;
    }
    return distribution;
  }

  /// Returns the three most recently added assets.
  List<Asset> get recentAssets {
    List<Asset> sorted = List.from(_assets);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  /// Returns a modifiable copy of the net worth history for the asset growth chart.
  List<NetWorthEvent> get netWorthHistory => List.from(_netWorthHistory);

  /// Adds a new asset and records a net worth event.
  void addAsset(Asset asset) {
    _assets.add(asset);
    _recordNetWorth();
    notifyListeners();
  }

  /// Removes an asset and records a net worth event.
  void removeAsset(Asset asset) {
    _assets.remove(asset);
    _recordNetWorth();
    notifyListeners();
  }

  /// Records the current net worth event with timestamp.
  void _recordNetWorth() {
    _netWorthHistory.add(
      NetWorthEvent(
        timestamp: DateTime.now(),
        netWorth: totalAssets,
      ),
    );
  }
}
