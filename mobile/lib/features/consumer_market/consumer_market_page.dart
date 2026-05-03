import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/consumer_market/application/consumer_market_controller.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_body.dart';
import 'package:mobile/features/consumer_market/presentation/consumer_market_theme.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:provider/provider.dart';

class ConsumerMarketPage extends StatelessWidget {
  const ConsumerMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final c = ConsumerMarketController()..primeBaseline();
        final dio = context.read<Dio>();
        unawaited(c.hydrateFromPredictions(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<ConsumerMarketController>(
        builder: (context, controller, _) {
          final model = controller.model;
          if (model == null) {
            return const ColoredBox(
              color: ConsumerMarketTheme.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ConsumerMarketTheme.darkGreen,
                  ),
                ),
              ),
            );
          }
          return ConsumerMarketBody(model: model);
        },
      ),
    );
  }
}
