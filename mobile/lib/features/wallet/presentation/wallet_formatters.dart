import 'package:intl/intl.dart';

abstract final class WalletFormatters {
  static final NumberFormat _dec = NumberFormat.decimalPattern('tr_TR');

  static String kwh(double v) => '${_dec.format(v)} kWh';

  static final NumberFormat _money = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final NumberFormat _amount = NumberFormat('#,##0.00', 'tr_TR');

  /// Ana bakiye — örn. "₺1.452,80".
  static String tryAmount(double v) => _money.format(v);

  /// Liste tutarları — örn. "+14,20 ₺" / "-6,45 ₺".
  static String signedTryDisplay(double signedAmountTry) {
    final n = _amount.format(signedAmountTry.abs());
    if (signedAmountTry > 0) return '+$n ₺';
    if (signedAmountTry < 0) return '-$n ₺';
    return '$n ₺';
  }
}
