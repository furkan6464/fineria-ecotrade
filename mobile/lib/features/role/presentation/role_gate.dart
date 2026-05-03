import 'package:flutter/material.dart';
import 'package:mobile/features/role/application/role_controller.dart';
import 'package:mobile/features/role/presentation/role_select_screen.dart';
import 'package:mobile/widgets/eco_trade_shell.dart';
import 'package:provider/provider.dart';

/// Auth yerine konuldu: rol seçilene kadar [RoleSelectScreen], sonra [EcoTradeShell].
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleController>(
      builder: (context, controller, _) {
        if (!controller.hasSelected) {
          return const RoleSelectScreen();
        }
        return EcoTradeShell(role: controller.role);
      },
    );
  }
}
