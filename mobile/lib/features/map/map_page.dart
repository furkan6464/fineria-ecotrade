import 'package:flutter/material.dart';
import 'package:mobile/features/map/application/neighborhood_map_controller.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_body.dart';
import 'package:mobile/features/map/presentation/neighborhood_map_theme.dart';
import 'package:provider/provider.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NeighborhoodMapController()..loadDemo(),
      child: Consumer<NeighborhoodMapController>(
        builder: (context, controller, _) {
          final model = controller.viewModel;
          if (model == null) {
            return const ColoredBox(
              color: NeighborhoodMapTheme.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: NeighborhoodMapTheme.chipActiveBg,
                  ),
                ),
              ),
            );
          }
          return NeighborhoodMapBody(model: model);
        },
      ),
    );
  }
}
