import 'package:flutter/foundation.dart';

/// Cüzdan ekranı için backend uyumlu kök model.
@immutable
class WalletModel {
  const WalletModel({
    this.liveDuzceFootnote,
    required this.totalBalanceLabel,
    required this.totalBalanceTry,
    required this.withdrawButtonLabel,
    required this.depositButtonLabel,
    required this.pendingCard,
    required this.upcomingBillCard,
    required this.aiSummary,
    required this.historyTitle,
    required this.transactions,
  });

  /// Örn. anlık üretim satırı — API yoksa null (gösterilmez).
  final String? liveDuzceFootnote;

  final String totalBalanceLabel;
  final double totalBalanceTry;
  final String withdrawButtonLabel;
  final String depositButtonLabel;
  final WalletMetricCardModel pendingCard;
  final WalletMetricCardModel upcomingBillCard;
  final WalletAiSummaryModel aiSummary;
  final String historyTitle;
  final List<TransactionItemModel> transactions;
}

@immutable
class WalletMetricCardModel {
  const WalletMetricCardModel({
    required this.visualKind,
    required this.title,
    required this.amountTry,
  });

  final WalletMetricVisualKind visualKind;
  final String title;
  final double amountTry;
}

enum WalletMetricVisualKind { pendingOrange, billBlue }

@immutable
class WalletAiSummaryModel {
  const WalletAiSummaryModel({required this.parts});

  /// Sırayla birleştirilen metin parçaları; vurgulu parça yeşil çizilir.
  final List<WalletAiSummaryPart> parts;
}

@immutable
class WalletAiSummaryPart {
  const WalletAiSummaryPart({
    required this.text,
    this.emphasizeSavings = false,
  });

  final String text;
  final bool emphasizeSavings;
}

enum WalletTransactionKind { income, expense, support, fee }

@immutable
class TransactionItemModel {
  const TransactionItemModel({
    required this.kind,
    required this.title,
    required this.detailLine,
    required this.signedAmountTry,
  });

  final WalletTransactionKind kind;
  final String title;
  final String detailLine;
  final double signedAmountTry;
}
