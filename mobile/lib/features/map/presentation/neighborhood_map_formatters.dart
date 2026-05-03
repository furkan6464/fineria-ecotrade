import 'package:intl/intl.dart';

abstract final class NeighborhoodMapFormatters {
  static final NumberFormat _dec = NumberFormat.decimalPattern('tr_TR');

  static String signedKwh(double v) {
    if (v > 0) return '+${_dec.format(v)} kWh';
    if (v < 0) return '${_dec.format(v)} kWh';
    return '${_dec.format(v)} kWh';
  }

  static String metricKwh(double v) => _dec.format(v);

  static String percentSigned(double v) {
    if (v == 0) return '0%';
    final s = _dec.format(v.abs());
    return v < 0 ? '-$s%' : '+$s%';
  }

  static String summaryGreenLine(String template, double percent) {
    return template.replaceFirst('%s', '%${_dec.format(percent)}');
  }
}
