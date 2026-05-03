import 'package:flutter/foundation.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';

class NeighborhoodMapController extends ChangeNotifier {
  NeighborhoodMapModel? _full;
  String _selectedFilterId = 'all';

  NeighborhoodMapModel? get viewModel {
    final f = _full;
    if (f == null) return null;
    final nodes = f.mapNodes.where(_nodeVisible).toList();
    final ids = nodes.map((e) => e.id).toSet();
    final conns = f.mapConnections
        .where((c) => ids.contains(c.fromNodeId) && ids.contains(c.toNodeId))
        .toList();
    return NeighborhoodMapModel(
      filterChips: f.filterChips,
      selectedFilterId: _selectedFilterId,
      mapNodes: nodes,
      mapConnections: conns,
      legendEntries: f.legendEntries,
      activeTransaction: f.activeTransaction,
      metrics: f.metrics,
      summary: f.summary,
    );
  }

  void loadDemo() {
    _full = NeighborhoodMapModel(
      filterChips: const [
        MapFilterChipModel(id: 'all', label: 'Tümü'),
        MapFilterChipModel(id: 'producers', label: 'Üreticiler'),
        MapFilterChipModel(id: 'consumers', label: 'Tüketiciler'),
        MapFilterChipModel(id: 'active', label: 'Aktif işlem'),
      ],
      selectedFilterId: _selectedFilterId,
      mapNodes: const [
        MapNodeModel(
          id: 'ges_uni',
          kind: MapNodeKind.producer,
          displayName: 'Düzce Üniversitesi GES',
          energyKwh: 0,
          anchorX: 0.35,
          anchorY: 0.28,
          latitude: 40.8495,
          longitude: 31.1498,
          detailLine: '15 kW kapasite',
        ),
        MapNodeModel(
          id: 'ges_merkez',
          kind: MapNodeKind.producer,
          displayName: 'Merkez Çatı GES',
          energyKwh: 0,
          anchorX: 0.52,
          anchorY: 0.45,
          latitude: 40.8428,
          longitude: 31.1549,
          detailLine: '15 kW kapasite',
        ),
        MapNodeModel(
          id: 'osb_fabrika',
          kind: MapNodeKind.consumer,
          displayName: 'Düzce 1. OSB Fabrika',
          energyKwh: 0,
          anchorX: 0.72,
          anchorY: 0.62,
          latitude: 40.8275,
          longitude: 31.1698,
          detailLine: 'İhtiyaç: 50 kW',
        ),
        MapNodeModel(
          id: 'akcakoca_depot',
          kind: MapNodeKind.consumer,
          displayName: 'Akçakoca Soğuk Hava Deposu',
          energyKwh: 0,
          anchorX: 0.28,
          anchorY: 0.18,
          latitude: 41.0868,
          longitude: 31.1195,
          detailLine: 'İhtiyaç: 50 kW',
        ),
      ],
      mapConnections: const [],
      legendEntries: const [
        MapLegendEntryModel(swatchArgb: 0xFF1D9E75, label: 'Üretici'),
        MapLegendEntryModel(swatchArgb: 0xFFE53935, label: 'Tüketici'),
      ],
      activeTransaction: const ActiveNeighborhoodTransactionModel(
        message:
            'Düzce Üniversitesi GES → Düzce 1. OSB Fabrika: önerilen eşleşme',
        detailButtonLabel: 'Detay',
      ),
      metrics: NeighborhoodMapMetricsModel(
        productionKwh: 30,
        productionLabel: 'Üretici kapasitesi (kW)',
        consumptionKwh: 100,
        consumptionLabel: 'Tüketici ihtiyacı (kW)',
        transformerKwh: 24,
        transformerLabel: 'Şebeke / trafo (kW)',
        productionValueArgb: 0xFF1D9E75,
        consumptionValueArgb: 0xFFE53935,
        transformerValueArgb: 0xFFEF9F27,
      ),
      summary: NeighborhoodSummaryModel(
        greenEnergyPercent: 72,
        greenEnergyMessageTemplate:
            'Düzce pilotunda test alanı %s yerel üretim payıyla çalışıyor',
        transformerLoadMessage: 'Trafo yükü EcoTrade öncesine göre',
        transformerLoadChangePercent: -18,
      ),
    );
    notifyListeners();
  }

  void selectFilter(String id) {
    if (_selectedFilterId == id) return;
    _selectedFilterId = id;
    notifyListeners();
  }

  void applyModel(NeighborhoodMapModel next) {
    _full = next;
    notifyListeners();
  }

  bool _nodeVisible(MapNodeModel n) {
    switch (_selectedFilterId) {
      case 'all':
        return true;
      case 'producers':
        return n.kind == MapNodeKind.producer ||
            n.kind == MapNodeKind.hub ||
            n.kind == MapNodeKind.transformer;
      case 'consumers':
        return n.kind == MapNodeKind.consumer ||
            n.kind == MapNodeKind.hub ||
            n.kind == MapNodeKind.transformer;
      case 'active':
        return n.kind != MapNodeKind.neutral;
      default:
        return true;
    }
  }
}
