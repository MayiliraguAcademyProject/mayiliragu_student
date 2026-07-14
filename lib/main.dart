import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/services/app_initializer.dart';

void main() async {
  final ThemeMode themeMode = await AppInitializer.init();
  runApp(MyApp(initialRoute: AppPages.INITIAL, themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ThemeMode themeMode;
  const MyApp({super.key, required this.initialRoute, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Mayiliragu Academy",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
