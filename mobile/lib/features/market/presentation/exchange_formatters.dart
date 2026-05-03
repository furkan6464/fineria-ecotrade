import 'package:intl/intl.dart';

abstract final class ExchangeFormatters {
  static final NumberFormat _dec = NumberFormat.decimalPattern('tr_TR');
  static final NumberFormat _money = NumberFormat('#,##0.00', 'tr_TR');

  static String tryPerKwh(double v) => '${_money.format(v)} ₺/kWh';

  static String kwh(double v) => '${_dec.format(v)} kWh';

  static String timeAndKwh(String time, double kwh) =>
      '$time · ${_dec.format(kwh)} kWh';

  static String plusTry(double v) => '+${_money.format(v)} TL';

  static String energyKwhPart(double v) => '${_dec.format(v)} kWh';

  static String offerPricePerKwhPart(double v) => '${_money.format(v)} TL/kWh';
}
