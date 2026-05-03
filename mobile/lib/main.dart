import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/constants/colors.dart';
import 'package:mobile/core/network/dio_client.dart';
import 'package:mobile/core/storage/secure_token_storage.dart';
import 'package:mobile/features/role/application/role_controller.dart';
import 'package:mobile/features/role/presentation/role_gate.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Auth tamamen kaldırıldı — yine de Dio + güvenli depolama kalır (zararsız no-op).
  final tokenStorage = SecureTokenStorage();
  final dio = DioClient.create(tokenStorage);

  runApp(EcoTradeApp(dio: dio));
}

class EcoTradeApp extends StatelessWidget {
  const EcoTradeApp({super.key, required this.dio});

  final Dio dio;

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.interTextTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleController()),
        Provider<Dio>.value(value: dio),
      ],
      child: MaterialApp(
        title: 'EcoTrade',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.light(
            surface: AppColors.background,
            onSurface: AppColors.text,
            primary: AppColors.bottomBar,
            onPrimary: AppColors.bottomBarSelected,
            secondary: AppColors.accent,
            onSecondary: AppColors.text,
            tertiary: AppColors.secondary,
            onTertiary: AppColors.text,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.text,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
            iconTheme: const IconThemeData(color: AppColors.text),
          ),
          textTheme: baseText.copyWith(
            titleLarge: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
            titleMedium: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            bodyLarge: GoogleFonts.inter(color: AppColors.text),
            bodyMedium: GoogleFonts.inter(color: AppColors.text),
            bodySmall: GoogleFonts.inter(color: AppColors.text),
            labelSmall: GoogleFonts.inter(),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.bottomBar,
            selectedItemColor: AppColors.bottomBarSelected,
            unselectedItemColor: AppColors.bottomBarUnselected,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
          dividerColor: AppColors.secondary.withValues(alpha: 0.5),
        ),
        home: const RoleGate(),
      ),
    );
  }
}
