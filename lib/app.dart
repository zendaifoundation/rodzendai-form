import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/routes/app_router.dart';
import 'package:rodzendai_form/presentation/register_status/blocs/get_location_detail_bloc/get_location_detail_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // สร้าง router instance เดียวเพื่อไม่ให้สร้างใหม่ทุกครั้งที่ hot reload
  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetLocationDetailBloc(),
      child: MaterialApp.router(
        title: 'Flutter Web LINE LIFF + Firebase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
