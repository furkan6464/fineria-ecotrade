import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/home/application/producer_dashboard_controller.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_body.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:provider/provider.dart';

/// Üretici ana sayfa gövdesi; veri [ProducerDashboardModel] üzerinden gelir.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final c = ProducerDashboardController();
        final dio = context.read<Dio>();
        unawaited(c.hydrateFromPredictions(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<ProducerDashboardController>(
        builder: (context, controller, _) {
          final model = controller.model;
          if (model == null) {
            return const ColoredBox(
              color: ProducerDashboardColors.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ProducerDashboardColors.darkGreen,
                  ),
                ),
              ),
            );
          }
          return ProducerDashboardBody(model: model);
        },
      ),
    );
  }
}
