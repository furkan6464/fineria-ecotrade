import 'package:flutter/material.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_formatters.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class NeighborhoodSummaryCard extends StatelessWidget {
  const NeighborhoodSummaryCard({super.key, required this.summary});

  final NeighborhoodSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final greenLine = NeighborhoodMapFormatters.summaryGreenLine(
      summary.greenEnergyMessageTemplate,
      summary.greenEnergyPercent,
    );
    final changeText = NeighborhoodMapFormatters.percentSigned(
      summary.transformerLoadChangePercent,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeighborhoodMapTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NeighborhoodMapTheme.producerFg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  greenLine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: NeighborhoodMapTheme.chipActiveBg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NeighborhoodMapTheme.summaryRedDot,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary.transformerLoadMessage,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: NeighborhoodMapTheme.chipActiveBg,
                  ),
                ),
              ),
              Text(
                changeText,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: NeighborhoodMapTheme.summaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
