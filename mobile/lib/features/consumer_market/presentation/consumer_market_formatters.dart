import 'package:intl/intl.dart';

abstract final class ConsumerMarketFormatters {
  static final NumberFormat _dec = NumberFormat.decimalPattern('tr_TR');
  static final NumberFormat _dec2 = NumberFormat('#,##0.00', 'tr_TR');

  static String tryPerKwh(double v) =>
      '${_dec2.format(v)} ₺/kWh'.replaceAll(',', '.');

  static String tryAmount(double v) => '${_dec2.format(v)} TL';

  static String kwh(double v) => '${_dec.format(v)} kWh';
}
