import 'package:flutter/material.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class MapActiveTransactionBanner extends StatelessWidget {
  const MapActiveTransactionBanner({
    super.key,
    required this.data,
    required this.onDetail,
  });

  final ActiveNeighborhoodTransactionModel data;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NeighborhoodMapTheme.activeBannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NeighborhoodMapTheme.activeBannerBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: NeighborhoodMapTheme.activeBannerDot,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.message,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: NeighborhoodMapTheme.chipActiveBg,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onDetail,
            style: TextButton.styleFrom(
              foregroundColor: NeighborhoodMapTheme.chipActiveBg,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: NeighborhoodMapTheme.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              data.detailButtonLabel,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
