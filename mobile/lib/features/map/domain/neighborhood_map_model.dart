import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mahalle haritası — backend JSON ile doldurulacak taslak.
@immutable
class NeighborhoodMapModel {
  const NeighborhoodMapModel({
    required this.filterChips,
    required this.selectedFilterId,
    required this.mapNodes,
    required this.mapConnections,
    required this.legendEntries,
    required this.activeTransaction,
    required this.metrics,
    required this.summary,
  });

  final List<MapFilterChipModel> filterChips;
  final String selectedFilterId;
  final List<MapNodeModel> mapNodes;
  final List<MapConnectionModel> mapConnections;
  final List<MapLegendEntryModel> legendEntries;
  final ActiveNeighborhoodTransactionModel? activeTransaction;
  final NeighborhoodMapMetricsModel metrics;
  final NeighborhoodSummaryModel summary;
}

@immutable
class MapFilterChipModel {
  const MapFilterChipModel({required this.id, required this.label});

  final String id;
  final String label;
}

@immutable
class MapNodeModel {
  const MapNodeModel({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.energyKwh,
    required this.anchorX,
    required this.anchorY,
    this.latitude,
    this.longitude,
    this.detailLine = '',
  });

  final String id;
  final MapNodeKind kind;
  final String displayName;
  final double energyKwh;

  /// Stack içinde yatay konum (0–1).
  final double anchorX;

  /// Stack içinde dikey konum (0–1).
  final double anchorY;

  /// Gerçek harita (WGS84). Varsa `NeighborhoodMapCanvas` OSM üzerinde gösterir.
  final double? latitude;

  final double? longitude;

  /// Örn. "15 kW kapasite" — doluysa `energyKwh` yerine gösterilir.
  final String detailLine;
}

enum MapNodeKind { hub, producer, consumer, neutral, transformer }

@immutable
class MapConnectionModel {
  const MapConnectionModel({
    required this.fromNodeId,
    required this.toNodeId,
    required this.lineArgb,
  });

  final String fromNodeId;
  final String toNodeId;

  /// Çizgi rengi (ARGB).
  final int lineArgb;
}

@immutable
class MapLegendEntryModel {
  const MapLegendEntryModel({required this.swatchArgb, required this.label});

  final int swatchArgb;
  final String label;
}

@immutable
class ActiveNeighborhoodTransactionModel {
  const ActiveNeighborhoodTransactionModel({
    required this.message,
    required this.detailButtonLabel,
  });

  final String message;
  final String detailButtonLabel;
}

@immutable
class NeighborhoodMapMetricsModel {
  const NeighborhoodMapMetricsModel({
    required this.productionKwh,
    required this.productionLabel,
    required this.consumptionKwh,
    required this.consumptionLabel,
    required this.transformerKwh,
    required this.transformerLabel,
    required this.productionValueArgb,
    required this.consumptionValueArgb,
    required this.transformerValueArgb,
  });

  final double productionKwh;
  final String productionLabel;
  final double consumptionKwh;
  final String consumptionLabel;
  final double transformerKwh;
  final String transformerLabel;
  final int productionValueArgb;
  final int consumptionValueArgb;
  final int transformerValueArgb;
}

@immutable
class NeighborhoodSummaryModel {
  const NeighborhoodSummaryModel({
    required this.greenEnergyPercent,
    required this.greenEnergyMessageTemplate,
    required this.transformerLoadMessage,
    required this.transformerLoadChangePercent,
  });

  /// Örn. 66 — metin şablonda % olarak kullanılır.
  final double greenEnergyPercent;

  /// Örn. "Mahalle %s yeşil enerjiyle çalışıyor" → formatter doldurur.
  final String greenEnergyMessageTemplate;

  final String transformerLoadMessage;

  /// Örn. -44.0
  final double transformerLoadChangePercent;
}
