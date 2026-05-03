import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class NeighborhoodMapCanvas extends StatelessWidget {
  const NeighborhoodMapCanvas({super.key, required this.model});

  final NeighborhoodMapModel model;

  /// Pilot odağı — OSM ilk kadrajda Düzce merkezi mutlaka görünsün.
  static const LatLng _duzcePilotCenter = LatLng(40.8438, 31.1565);

  static List<MapNodeModel> _geoNodes(NeighborhoodMapModel m) =>
      m.mapNodes.where((n) => n.latitude != null && n.longitude != null).toList();

  @override
  Widget build(BuildContext context) {
    final geoNodes = _geoNodes(model);
    final coords = <LatLng>[
      _duzcePilotCenter,
      ...geoNodes.map((n) => LatLng(n.latitude!, n.longitude!)),
    ];

    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        color: NeighborhoodMapTheme.mapPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: geoNodes.isEmpty
          ? Center(
              child: Text(
                'Harita konumu yüklenemedi',
                style: TextStyle(
                  fontSize: 14,
                  color: NeighborhoodMapTheme.subtitleGray,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCameraFit: CameraFit.coordinates(
                        coordinates: coords,
                        padding: const EdgeInsets.fromLTRB(28, 52, 28, 56),
                        maxZoom: 11.8,
                      ),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      backgroundColor: NeighborhoodMapTheme.mapPanel,
                      keepAlive: true,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'EcoTrade.mobile',
                      ),
                      MarkerLayer(
                        markers: [
                          for (final n in geoNodes)
                            Marker(
                              width: 158,
                              height: 112,
                              alignment: Alignment.bottomCenter,
                              point: LatLng(n.latitude!, n.longitude!),
                              child: _PilotLocationPin(node: n),
                            ),
                        ],
                      ),
                      SimpleAttributionWidget(
                        alignment: Alignment.bottomRight,
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        source: const Text(
                          'OpenStreetMap katkıcıları',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _PilotRegionBadge(),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _LegendCard(entries: model.legendEntries),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PilotRegionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Düzce pilot bölgesi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: NeighborhoodMapTheme.chipPassiveFg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '40,8438°N · 31,1565°E',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: NeighborhoodMapTheme.subtitleGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _PilotLocationPin extends StatelessWidget {
  const _PilotLocationPin({required this.node});

  final MapNodeModel node;

  Color get _pinColor {
    switch (node.kind) {
      case MapNodeKind.producer:
        return NeighborhoodMapTheme.producerFg;
      case MapNodeKind.consumer:
        return NeighborhoodMapTheme.summaryRed;
      default:
        return NeighborhoodMapTheme.chipPassiveFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = node.detailLine.isNotEmpty
        ? node.detailLine
        : '${node.energyKwh} kWh';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 150,
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                node.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.2,
                  color: NeighborhoodMapTheme.chipPassiveFg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  height: 1.2,
                  color: NeighborhoodMapTheme.subtitleGray,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.location_on_rounded,
          size: 44,
          color: _pinColor,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.entries});

  final List<MapLegendEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < entries.length - 1 ? 6 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(entries[i].swatchArgb),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entries[i].label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: NeighborhoodMapTheme.chipPassiveFg,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
