import 'package:intl/intl.dart';

abstract final class ConsumerDashboardFormatters {
  static final NumberFormat _decimal = NumberFormat.decimalPattern('tr_TR');
  static final NumberFormat _decimal2 = NumberFormat('#,##0.00', 'tr_TR');

  static String kwh(double v) => '${_decimal.format(v)} kWh';

  static String kg(double v) => '${_decimal.format(v)} kg';

  static String tryLira(double v) => '${_decimal2.format(v)} TL';

  /// Fiyat satırı için sembol başta — örn. "1.45 ₺".
  static String tryPriceTag(double v) => '${_decimal2.format(v)} ₺';

  static String decimal1(double v) => _decimal.format(v);
}
