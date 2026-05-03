import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/market/application/producer_exchange_controller.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';
import 'package:mobile/features/market/presentation/producer_exchange_body.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:provider/provider.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final c = ProducerExchangeController()..loadDemo();
        final dio = context.read<Dio>();
        unawaited(c.hydrateFromApi(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<ProducerExchangeController>(
        builder: (context, controller, _) {
          final model = controller.model;
          if (model == null) {
            return const ColoredBox(
              color: ExchangeTheme.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ExchangeTheme.darkGreen,
                  ),
                ),
              ),
            );
          }
          return ProducerExchangeBody(model: model);
        },
      ),
    );
  }
}
