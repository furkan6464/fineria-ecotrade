import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/constants/nav_assets.dart';
import 'package:mobile/features/ai/ai_page.dart';
import 'package:mobile/features/consumer_home/consumer_home_page.dart';
import 'package:mobile/features/consumer_market/consumer_market_page.dart';
import 'package:mobile/features/home/home_page.dart';
import 'package:mobile/features/map/map_page.dart';
import 'package:mobile/features/market/market_page.dart';
import 'package:mobile/features/role/application/role_controller.dart';
import 'package:mobile/features/wallet/wallet_page.dart';
import 'package:provider/provider.dart';

/// Ana iskelet: üst çubuk, gövde (5 sekme) ve alt navigasyon.
/// Role göre Ana sayfa ve Borsa sekmeleri farklı sayfalar gösterir.
class EcoTradeShell extends StatefulWidget {
  const EcoTradeShell({super.key, required this.role});

  final UserRole role;

  @override
  State<EcoTradeShell> createState() => _EcoTradeShellState();
}

class _EcoTradeShellState extends State<EcoTradeShell> {
  int _index = 0;

  List<Widget> get _pages {
    final isProducer = widget.role == UserRole.producer;
    return [
      isProducer ? const HomePage() : const ConsumerHomePage(),
      isProducer ? const MarketPage() : const ConsumerMarketPage(),
      const MapPage(),
      const WalletPage(),
      const AiPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const _EcoDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menü',
          ),
        ),
        title: Text(
          'EcoTrade',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
            tooltip: 'Bildirimler',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _EcoBottomBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _EcoDrawer extends StatelessWidget {
  const _EcoDrawer();

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleController>().role;
    final roleLabel = role == UserRole.producer
        ? 'Üretici hesabı'
        : 'Tüketici hesabı';

    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EcoTrade',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: AppColors.text.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Colors.white,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.text,
                ),
                title: const Text(
                  'Çıkış yap',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<RoleController>().clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EcoBottomBar extends StatelessWidget {
  const _EcoBottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bottomBar,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.bottomBar,
                elevation: 0,
                selectedItemColor: AppColors.bottomBarSelected,
                unselectedItemColor: AppColors.bottomBarUnselected,
                selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: _NavBarSvg(asset: NavBarAssets.home, selected: false),
                    activeIcon: _NavBarSvg(
                      asset: NavBarAssets.home,
                      selected: true,
                    ),
                    label: 'Ana sayfa',
                  ),
                  BottomNavigationBarItem(
                    icon: _NavBarSvg(
                      asset: NavBarAssets.market,
                      selected: false,
                    ),
                    activeIcon: _NavBarSvg(
                      asset: NavBarAssets.market,
                      selected: true,
                    ),
                    label: 'Borsa',
                  ),
                  BottomNavigationBarItem(
                    icon: _NavBarSvg(asset: NavBarAssets.map, selected: false),
                    activeIcon: _NavBarSvg(
                      asset: NavBarAssets.map,
                      selected: true,
                    ),
                    label: 'Harita',
                  ),
                  BottomNavigationBarItem(
                    icon: _NavBarSvg(
                      asset: NavBarAssets.wallet,
                      selected: false,
                    ),
                    activeIcon: _NavBarSvg(
                      asset: NavBarAssets.wallet,
                      selected: true,
                    ),
                    label: 'Cüzdan',
                  ),
                  BottomNavigationBarItem(
                    icon: _NavBarSvg(asset: NavBarAssets.ai, selected: false),
                    activeIcon: _NavBarSvg(
                      asset: NavBarAssets.ai,
                      selected: true,
                    ),
                    label: 'Yapay Zeka',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarSvg extends StatelessWidget {
  const _NavBarSvg({required this.asset, required this.selected});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.bottomBarSelected
        : AppColors.bottomBarUnselected;
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
