import 'dart:math' as math;

import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/predictions/data/prediction_dtos.dart';

/// Gün içi EPİAŞ/havuz benzeri referans eğrisi (₺/kWh): öğlen yenilenebilir etkisiyle dip, akşam tepe.
/// Statik dizi — demo ve API yokken gerçekçi profil.
ExchangePriceChartModel staticIntradayHavuzCurve() {
  const raw = [1.95, 2.05, 2.10, 2.50, 2.15, 1.90];
  const hourLabels = ['08:00', '11:00', '14:00', '17:00', '20:00', '23:00'];

  var maxV = raw.reduce(math.max);
  var minV = raw.reduce(math.min);
  if (maxV == minV) {
    maxV = minV + 0.01;
  }

  final peakIdx = raw.indexOf(maxV);
  final peakNormX = peakIdx / (raw.length - 1);

  const nSmooth = 48;
  final pts = <ExchangeChartPoint>[];
  for (var i = 0; i <= nSmooth; i++) {
    final t = i / nSmooth;
    final fIdx = t * (raw.length - 1);
    final i0 = fIdx.floor().clamp(0, raw.length - 1);
    final i1 = (i0 + 1).clamp(0, raw.length - 1);
    final frac = fIdx - i0;
    final v0 = raw[i0];
    final v1 = raw[i1];
    final v = v0 + (v1 - v0) * frac;
    final yNorm = (v - minV) / (maxV - minV);
    pts.add(ExchangeChartPoint(t, yNorm.clamp(0.0, 1.0)));
  }

  final peakFormatted = maxV.toStringAsFixed(2).replaceAll('.', ',');

  return ExchangePriceChartModel(
    linePointsNormalized: pts,
    xAxisTicks: [
      ExchangeChartXTick(
        label: hourLabels.first,
        positionNormalizedX: 0.06,
        emphasized: false,
      ),
      ExchangeChartXTick(
        label: hourLabels[hourLabels.length ~/ 2],
        positionNormalizedX: 0.5,
        emphasized: true,
      ),
      ExchangeChartXTick(
        label: hourLabels.last,
        positionNormalizedX: 0.94,
        emphasized: false,
      ),
    ],
    peakNormalizedX: peakNormX.clamp(0.05, 0.95),
    peakTooltipText: 'Akşam pik: $peakFormatted ₺/kWh',
  );
}

/// 6 saatlik fiyat/üretim serisinden normalize çan eğrisi + eksen etiketleri.
ExchangePriceChartModel producerExchangeChartFromForecast(
  ProducerForecastDto forecast,
) {
  final rows = forecast.next6Hours;
  if (rows.length < 2) {
    return staticIntradayHavuzCurve();
  }

  final values = rows.map((r) => r.priceTryPerKwh ?? r.surplusKwh).toList();
  var maxV = values.reduce(math.max);
  var minV = values.reduce(math.min);
  if (maxV == minV) {
    maxV = minV + 0.01;
  }

  final nSmooth = 48;
  final pts = <ExchangeChartPoint>[];
  for (var i = 0; i <= nSmooth; i++) {
    final t = i / nSmooth;
    final fIdx = t * (rows.length - 1);
    final i0 = fIdx.floor().clamp(0, rows.length - 1);
    final i1 = (i0 + 1).clamp(0, rows.length - 1);
    final frac = fIdx - i0;
    final v0 = values[i0];
    final v1 = values[i1];
    final v = v0 + (v1 - v0) * frac;
    final yNorm = (v - minV) / (maxV - minV);
    pts.add(ExchangeChartPoint(t, yNorm.clamp(0.0, 1.0)));
  }

  var peakI = 0;
  var peakSurplus = -double.infinity;
  for (var i = 0; i < rows.length; i++) {
    if (rows[i].surplusKwh > peakSurplus) {
      peakSurplus = rows[i].surplusKwh;
      peakI = i;
    }
  }
  var peakIdx = peakI;
  final best = forecast.bestSellHour;
  if (best != null && best.isNotEmpty) {
    final j = rows.indexWhere((r) => r.hour == best);
    if (j >= 0) peakIdx = j;
  }
  final peakNormX = peakIdx / (rows.length - 1);

  final bestLabel = forecast.bestSellHour ?? rows[peakIdx].hour;
  final first = rows.first.hour;
  final mid = rows[rows.length ~/ 2].hour;
  final last = rows.last.hour;

  return ExchangePriceChartModel(
    linePointsNormalized: pts,
    xAxisTicks: [
      ExchangeChartXTick(
        label: first,
        positionNormalizedX: 0.08,
        emphasized: false,
      ),
      ExchangeChartXTick(
        label: mid,
        positionNormalizedX: 0.5,
        emphasized: true,
      ),
      ExchangeChartXTick(
        label: last,
        positionNormalizedX: 0.92,
        emphasized: false,
      ),
    ],
    peakNormalizedX: peakNormX.clamp(0.05, 0.95),
    peakTooltipText: 'En iyi sat saati: $bestLabel',
  );
}
