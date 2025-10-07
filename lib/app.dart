import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:rodzendai_form/core/routes/app_router.dart';
import 'package:rodzendai_form/core/services/auth_service.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize AuthService from locator
    final authService = locator<AuthService>();
    authService.initialize();
    _appRouter = AppRouter();

    // ตั้งค่าสี status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.primary, // สีของ status bar
        statusBarIconBrightness:
            Brightness.light, // ไอคอนสีขาว (สำหรับ Android)
        statusBarBrightness: Brightness.dark, // ไอคอนสีขาว (สำหรับ iOS)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: locator<AuthService>()),
          BlocProvider(create: (_) => GetLocationDetailBloc()),
        ],
        child: MaterialApp.router(
          title: 'บริการรถรับ-ส่งผู้ป่วย',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'NotoSans',
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primary,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: AppColors.primary,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
