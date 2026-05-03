import 'package:flutter/material.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_formatters.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class MapMetricsRow extends StatelessWidget {
  const MapMetricsRow({super.key, required this.metrics});

  final NeighborhoodMapMetricsModel metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            value: NeighborhoodMapFormatters.metricKwh(metrics.productionKwh),
            label: metrics.productionLabel,
            valueColor: Color(metrics.productionValueArgb),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            value: NeighborhoodMapFormatters.metricKwh(metrics.consumptionKwh),
            label: metrics.consumptionLabel,
            valueColor: Color(metrics.consumptionValueArgb),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            value: NeighborhoodMapFormatters.metricKwh(metrics.transformerKwh),
            label: metrics.transformerLabel,
            valueColor: Color(metrics.transformerValueArgb),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 22,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: NeighborhoodMapTheme.subtitleGray,
            ),
          ),
        ],
      ),
    );
  }
}
