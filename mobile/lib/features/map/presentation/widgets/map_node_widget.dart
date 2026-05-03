import 'package:flutter/material.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_formatters.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class MapNodeWidget extends StatelessWidget {
  const MapNodeWidget({super.key, required this.node});

  final MapNodeModel node;

  @override
  Widget build(BuildContext context) {
    switch (node.kind) {
      case MapNodeKind.hub:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NeighborhoodMapTheme.hubFill.withValues(alpha: 0.95),
            border: Border.all(
              color: NeighborhoodMapTheme.hubBorder,
              width: 1.5,
            ),
          ),
        );
      case MapNodeKind.transformer:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              size: 18,
              color: NeighborhoodMapTheme.transformerFg,
            ),
            Text(
              NeighborhoodMapFormatters.signedKwh(node.energyKwh),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: NeighborhoodMapTheme.transformerFg,
              ),
            ),
            Text(
              node.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: NeighborhoodMapTheme.transformerFg,
              ),
            ),
          ],
        );
      case MapNodeKind.producer:
      case MapNodeKind.consumer:
      case MapNodeKind.neutral:
        return _HouseholdNode(node: node);
    }
  }
}

class _HouseholdNode extends StatelessWidget {
  const _HouseholdNode({required this.node});

  final MapNodeModel node;

  Color get _bg {
    switch (node.kind) {
      case MapNodeKind.producer:
        return NeighborhoodMapTheme.producerBg;
      case MapNodeKind.consumer:
        return NeighborhoodMapTheme.consumerBg;
      case MapNodeKind.neutral:
        return NeighborhoodMapTheme.neutralBg;
      default:
        return NeighborhoodMapTheme.neutralBg;
    }
  }

  Color get _fg {
    switch (node.kind) {
      case MapNodeKind.producer:
        return NeighborhoodMapTheme.producerFg;
      case MapNodeKind.consumer:
        return NeighborhoodMapTheme.consumerFg;
      case MapNodeKind.neutral:
        return NeighborhoodMapTheme.neutralFg;
      default:
        return NeighborhoodMapTheme.neutralFg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _fg, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.home_outlined, size: 22, color: _fg),
        ),
        const SizedBox(height: 4),
        Text(
          node.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: _fg,
          ),
        ),
        Text(
          node.detailLine.isNotEmpty
              ? node.detailLine
              : NeighborhoodMapFormatters.signedKwh(node.energyKwh),
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: _fg,
          ),
        ),
      ],
    );
  }
}
