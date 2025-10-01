import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // สร้าง router instance เดียวเพื่อไม่ให้สร้างใหม่ทุกครั้งที่ hot reload
  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Web LINE LIFF + Firebase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _appRouter.router,
    );
  }
}
