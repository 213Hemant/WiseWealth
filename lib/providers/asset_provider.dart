// lib/providers/asset_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      distribution[asset.type] =
          (distribution[asset.type] ?? 0) + asset.value;
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

  /// Adds a new asset, records a net worth event, and syncs to Firestore.
  Future<void> addAsset(Asset asset) async {
    _assets.add(asset);
    _recordNetWorth();
    notifyListeners();

    await _syncAssetToFirestore(asset);
  }

  /// Removes an asset, records a net worth event, and deletes from Firestore.
  Future<void> removeAsset(Asset asset) async {
    _assets.remove(asset);
    _recordNetWorth();
    notifyListeners();

    await _deleteAssetFromFirestore(asset);
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

  /// PRIVATE: Syncs an asset to Firestore.
  Future<void> _syncAssetToFirestore(Asset asset) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('assets');
        await firestoreRef.add({
          'name': asset.name,
          'value': asset.value,
          'type': asset.type,
          // Store as ISO8601 string for consistency.
          'createdAt': asset.createdAt.toIso8601String(),
          // Optionally: include a server timestamp for sync purposes.
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error syncing asset: $e");
      // Optionally, handle errors (retry, queue for later, etc.)
    }
  }

  /// PRIVATE: Deletes an asset from Firestore.
  Future<void> _deleteAssetFromFirestore(Asset asset) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestoreRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('assets');

        // In this simple example, we delete by matching name and createdAt.
        // Adjust the query criteria if you store a mapping between your local asset ID and Firestore doc ID.
        final snapshot = await firestoreRef
            .where('name', isEqualTo: asset.name)
            .where('createdAt', isEqualTo: asset.createdAt.toIso8601String())
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Error deleting asset from Firestore: $e");
    }
  }
}
