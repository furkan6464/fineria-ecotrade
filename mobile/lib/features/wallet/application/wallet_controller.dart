import 'package:flutter/foundation.dart';
import 'package:mobile/features/predictions/data/prediction_repository.dart';
import 'package:mobile/features/wallet/domain/wallet_model.dart';
import 'package:mobile/features/wallet/presentation/wallet_formatters.dart';

class WalletController extends ChangeNotifier {
  WalletModel? _model;

  WalletModel? get viewModel => _model;

  void applyModel(WalletModel next) {
    _model = next;
    notifyListeners();
  }

  /// C# yanıtı gelene kadar kullanılacak örnek yük.
  void loadDemo() {
    applyModel(
      WalletModel(
        liveDuzceFootnote: null,
        totalBalanceLabel: 'Net bakiye · EcoTrade cüzdan',
        totalBalanceTry: 1452.80,
        withdrawButtonLabel: 'Para çek',
        depositButtonLabel: 'Para yükle',
        pendingCard: const WalletMetricCardModel(
          visualKind: WalletMetricVisualKind.pendingOrange,
          title: 'Netleşmemiş havuz alacaklığı',
          amountTry: 340.50,
        ),
        upcomingBillCard: const WalletMetricCardModel(
          visualKind: WalletMetricVisualKind.billBlue,
          title: 'Öngörülen DEDAŞ mahsuplaşması',
          amountTry: 125.00,
        ),
        aiSummary: const WalletAiSummaryModel(
          parts: [
            WalletAiSummaryPart(
              text:
                  'Havuz satışların ve DEDAŞ mahsuplaşma kalemleri bu ekranda; bu ay dağıtım '
                  'tarifesine göre ',
            ),
            WalletAiSummaryPart(text: '%42 daha az', emphasizeSavings: true),
            WalletAiSummaryPart(
              text: ' şebeke maliyeti ödedin (önceki döneme göre).',
            ),
          ],
        ),
        historyTitle: 'İşlem geçmişi · mahsuplaşma kalemleri',
        transactions: const [
          TransactionItemModel(
            kind: WalletTransactionKind.income,
            title: 'EcoTrade Havuz Satışı (3,2 kWh)',
            detailLine: 'PTF referanslı havuz alım fiyatı · dönem içi satış',
            signedAmountTry: 6.72,
          ),
          TransactionItemModel(
            kind: WalletTransactionKind.expense,
            title: 'DEDAŞ Aylık Mahsuplaşma Bedeli',
            detailLine: 'Ticari tarife · aktif enerji + dağıtım payı (aylık)',
            signedAmountTry: -14.50,
          ),
          TransactionItemModel(
            kind: WalletTransactionKind.fee,
            title: 'Sistem Kullanım Bedeli (Dağıtım)',
            detailLine: 'kWh bazlı dağıtım şirketi sistem kullanım ücreti',
            signedAmountTry: -2.15,
          ),
          TransactionItemModel(
            kind: WalletTransactionKind.fee,
            title: 'TRT & Enerji Fonu Kesintisi',
            detailLine: 'Elektrik tüketim faturası kanuni kesintiler',
            signedAmountTry: -1.08,
          ),
        ],
      ),
    );
  }

  Future<void> hydrateFromApi(PredictionRepository repo) async {
    try {
      final live = await repo.fetchLive();
      final m = _model;
      if (m == null) return;

      final txs = List<TransactionItemModel>.from(m.transactions);
      if (txs.isNotEmpty) {
        final t0 = txs[0];
        txs[0] = TransactionItemModel(
          kind: t0.kind,
          title:
              'EcoTrade Havuz Satışı (${WalletFormatters.kwh(live.liveProductionKwh)})',
          detailLine: t0.detailLine,
          signedAmountTry: t0.signedAmountTry,
        );
      }

      applyModel(
        WalletModel(
          liveDuzceFootnote:
              'Anlık üretim (Düzce pilot): ${WalletFormatters.kwh(live.liveProductionKwh)}',
          totalBalanceLabel: m.totalBalanceLabel,
          totalBalanceTry: m.totalBalanceTry,
          withdrawButtonLabel: m.withdrawButtonLabel,
          depositButtonLabel: m.depositButtonLabel,
          pendingCard: m.pendingCard,
          upcomingBillCard: m.upcomingBillCard,
          aiSummary: m.aiSummary,
          historyTitle: m.historyTitle,
          transactions: txs,
        ),
      );
    } catch (_) {}
  }

  /// Tutar girildiğinde bakiyeyi artırır; işlem geçmişine tek satır ekler.
  bool applyDeposit(double tryAmount) {
    final m = _model;
    if (m == null || tryAmount <= 0) return false;

    final txs = List<TransactionItemModel>.from(m.transactions);
    txs.insert(
      0,
      TransactionItemModel(
        kind: WalletTransactionKind.income,
        title: 'Para yükleme',
        detailLine: 'Manuel tutar',
        signedAmountTry: tryAmount,
      ),
    );

    applyModel(
      WalletModel(
        liveDuzceFootnote: m.liveDuzceFootnote,
        totalBalanceLabel: m.totalBalanceLabel,
        totalBalanceTry: m.totalBalanceTry + tryAmount,
        withdrawButtonLabel: m.withdrawButtonLabel,
        depositButtonLabel: m.depositButtonLabel,
        pendingCard: m.pendingCard,
        upcomingBillCard: m.upcomingBillCard,
        aiSummary: m.aiSummary,
        historyTitle: m.historyTitle,
        transactions: txs,
      ),
    );
    return true;
  }

  /// Tutar girildiğinde bakiyeyi düşürür; yetersiz bakiyede false.
  bool applyWithdraw(double tryAmount) {
    final m = _model;
    if (m == null || tryAmount <= 0) return false;
    if (tryAmount > m.totalBalanceTry) return false;

    final txs = List<TransactionItemModel>.from(m.transactions);
    txs.insert(
      0,
      TransactionItemModel(
        kind: WalletTransactionKind.expense,
        title: 'Para çekme',
        detailLine: 'Manuel tutar',
        signedAmountTry: -tryAmount,
      ),
    );

    applyModel(
      WalletModel(
        liveDuzceFootnote: m.liveDuzceFootnote,
        totalBalanceLabel: m.totalBalanceLabel,
        totalBalanceTry: m.totalBalanceTry - tryAmount,
        withdrawButtonLabel: m.withdrawButtonLabel,
        depositButtonLabel: m.depositButtonLabel,
        pendingCard: m.pendingCard,
        upcomingBillCard: m.upcomingBillCard,
        aiSummary: m.aiSummary,
        historyTitle: m.historyTitle,
        transactions: txs,
      ),
    );
    return true;
  }
}
