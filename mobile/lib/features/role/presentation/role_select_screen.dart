import 'package:flutter/material.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/features/role/application/role_controller.dart';
import 'package:provider/provider.dart';

/// Uygulama açılışı: kullanıcı kendini "Üretici" veya "Tüketici" olarak seçer.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<RoleController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'EcoTrade',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Düzce pilot — komşudan komşuya enerji ticareti',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.text.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                'Nasıl katılmak istersin?',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 24),
              _RoleCard(
                icon: Icons.solar_power_rounded,
                title: 'Üreticiyim',
                subtitle:
                    'Çatımda GES var; ürettiğimi havuzda satıp gelir elde edeceğim.',
                onTap: () => controller.selectProducer(),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.electric_bolt_rounded,
                title: 'Tüketiciyim',
                subtitle:
                    'Komşumun ürettiği enerjiyi DEDAŞ tarifesinden ucuza satın alacağım.',
                onTap: () => controller.selectConsumer(),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.text.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.bottomBar,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.bottomBarSelected, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.text.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.text.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
