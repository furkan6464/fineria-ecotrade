import 'package:flutter/material.dart';
import 'package:mobile/features/map/application/neighborhood_map_controller.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';
import 'package:mobile/features/map/presentation/widgets/map_active_transaction_banner.dart';
import 'package:mobile/features/map/presentation/widgets/map_filter_chips.dart';
import 'package:mobile/features/map/presentation/widgets/map_metrics_row.dart';
import 'package:mobile/features/map/presentation/widgets/neighborhood_map_canvas.dart';
import 'package:mobile/features/map/presentation/widgets/neighborhood_summary_card.dart';
import 'package:provider/provider.dart';

class NeighborhoodMapBody extends StatelessWidget {
  const NeighborhoodMapBody({super.key, required this.model});

  final NeighborhoodMapModel model;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NeighborhoodMapController>();

    return ColoredBox(
      color: NeighborhoodMapTheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapFilterChips(
              chips: model.filterChips,
              selectedId: model.selectedFilterId,
              onSelect: controller.selectFilter,
            ),
            const SizedBox(height: 12),
            Text(
              'Şu an haritada Düzce\'deki test ağımızı görüyorsunuz. Üreticiler ve '
              'tüketiciler arasındaki lokasyon bazlı eşleşmeyi bu harita üzerinden optimize ediyoruz.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.45,
                color: NeighborhoodMapTheme.subtitleGray,
              ),
            ),
            const SizedBox(height: 14),
            NeighborhoodMapCanvas(model: model),
            if (model.activeTransaction != null) ...[
              const SizedBox(height: 14),
              MapActiveTransactionBanner(
                data: model.activeTransaction!,
                onDetail: () {},
              ),
            ],
            const SizedBox(height: 18),
            MapMetricsRow(metrics: model.metrics),
            const SizedBox(height: 18),
            NeighborhoodSummaryCard(summary: model.summary),
          ],
        ),
      ),
    );
  }
}
