import 'package:flutter/material.dart';
import 'package:mobile/features/map/domain/neighborhood_map_model.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';

class MapFilterChips extends StatelessWidget {
  const MapFilterChips({
    super.key,
    required this.chips,
    required this.selectedId,
    required this.onSelect,
  });

  final List<MapFilterChipModel> chips;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _Chip(
              label: chips[i].label,
              selected: chips[i].id == selectedId,
              onTap: () => onSelect(chips[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? NeighborhoodMapTheme.chipActiveBg
                : NeighborhoodMapTheme.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? NeighborhoodMapTheme.chipActiveBg
                  : NeighborhoodMapTheme.border,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: selected
                  ? NeighborhoodMapTheme.chipActiveFg
                  : NeighborhoodMapTheme.chipPassiveFg,
            ),
          ),
        ),
      ),
    );
  }
}
