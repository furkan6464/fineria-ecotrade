import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_home/application/consumer_dashboard_controller.dart';
import 'package:mobile/features/consumer_home/presentation/consumer_dashboard_body.dart';
import 'package:mobile/features/home/presentation/producer_dashboard_colors.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:provider/provider.dart';

/// Tüketici ana sayfası — `/api/predictions/*` üzerinden hidrate edilir.
class ConsumerHomePage extends StatelessWidget {
  const ConsumerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final c = ConsumerDashboardController();
        final dio = context.read<Dio>();
        unawaited(c.hydrateFromPredictions(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<ConsumerDashboardController>(
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
          return ConsumerDashboardBody(model: model);
        },
      ),
    );
  }
}
