import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/wallet/application/wallet_controller.dart';
import 'package:mobile/features/wallet/presentation/wallet_theme.dart';

/// Sadece tutar (rakam) girişi — Para çek / Para yükle akışı.
class WalletAmountPage extends StatefulWidget {
  const WalletAmountPage({
    super.key,
    required this.isWithdraw,
    required this.controller,
  });

  final bool isWithdraw;
  final WalletController controller;

  static Future<void> open(
    BuildContext context,
    WalletController controller, {
    required bool isWithdraw,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) =>
            WalletAmountPage(isWithdraw: isWithdraw, controller: controller),
      ),
    );
  }

  @override
  State<WalletAmountPage> createState() => _WalletAmountPageState();
}

class _WalletAmountPageState extends State<WalletAmountPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _title => widget.isWithdraw ? 'Para çek' : 'Para yükle';

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tutar girin')));
      return;
    }

    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Geçerli bir tutar girin')));
      return;
    }

    final ok = widget.isWithdraw
        ? widget.controller.applyWithdraw(amount)
        : widget.controller.applyDeposit(amount);

    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yetersiz bakiye')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('$_title: ${amount.toStringAsFixed(2)} TL')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: WalletTheme.background,
      appBar: AppBar(
        backgroundColor: WalletTheme.background,
        elevation: 0,
        title: Text(_title),
        foregroundColor: WalletTheme.titleDark,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tutar (TL)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: WalletTheme.labelGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: WalletTheme.titleDark,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: WalletTheme.cardWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: WalletTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: WalletTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: WalletTheme.incomeFg,
                    width: 1.5,
                  ),
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  color: WalletTheme.labelGray.withValues(alpha: 0.5),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: WalletTheme.incomeFg,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Onayla',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
