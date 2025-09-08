import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/counter_provider.dart';
import 'core/router/app_router.dart';
import 'design_system/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CounterProvider())],
      child: MaterialApp.router(
        title: 'Flutter Annotations',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
