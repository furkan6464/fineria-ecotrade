import 'package:flutter/material.dart';
import 'package:mobile/features/market/domain/producer_exchange_model.dart';
import 'package:mobile/features/market/presentation/exchange_formatters.dart';
import 'package:mobile/features/market/presentation/exchange_theme.dart';

class ExchangeActiveOfferBlock extends StatelessWidget {
  const ExchangeActiveOfferBlock({
    super.key,
    required this.sectionTitle,
    required this.offer,
    required this.onCancel,
  });

  final String sectionTitle;
  final ExchangeActiveOfferModel offer;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: ExchangeTheme.darkGreen,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: ExchangeTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ExchangeTheme.cardBorder, width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ExchangeTheme.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          color: ExchangeTheme.darkGreen,
                        ),
                        children: [
                          TextSpan(
                            text: ExchangeFormatters.energyKwhPart(
                              offer.energyKwh,
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                ' · ${ExchangeFormatters.offerPricePerKwhPart(offer.priceTryPerKwh)}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.statusMessage,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: ExchangeTheme.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: ExchangeTheme.darkGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: ExchangeTheme.cardBorder,
                      width: 0.5,
                    ),
                  ),
                  backgroundColor: ExchangeTheme.white,
                ),
                child: const Text(
                  'İptal et',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
