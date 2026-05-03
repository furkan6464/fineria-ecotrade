import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:mobile/features/wallet/application/wallet_controller.dart';
import 'package:mobile/features/wallet/presentation/wallet_body.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final c = WalletController()..loadDemo();
        final dio = context.read<Dio>();
        unawaited(c.hydrateFromApi(PredictionRepository(dio)));
        return c;
      },
      child: Consumer<WalletController>(
        builder: (context, controller, _) {
          final model = controller.viewModel;
          if (model == null) {
            return const ColoredBox(
              color: WalletTheme.background,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: WalletTheme.incomeFg,
                  ),
                ),
              ),
            );
          }
          return WalletBody(model: model);
        },
      ),
    );
  }
}
