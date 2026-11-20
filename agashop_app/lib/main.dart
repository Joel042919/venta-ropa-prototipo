import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'layouts/shell.dart';
import 'screens/login.dart';
import 'state/app_state.dart';

void main() => runApp(const AgaShopApp());

/// Sin barras de desplazamiento visibles en ninguna pantalla.
class SinBarras extends MaterialScrollBehavior {
  const SinBarras();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class AgaShopApp extends StatefulWidget {
  const AgaShopApp({super.key});
  @override
  State<AgaShopApp> createState() => _AgaShopAppState();
}

class _AgaShopAppState extends State<AgaShopApp> {
  final state = AppState();
  @override
  Widget build(BuildContext context) => AppScope(
        state: state,
        child: MaterialApp(
          title: 'AgaShop',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: state.messengerKey,
          theme: buildTheme(),
          scrollBehavior: const SinBarras(),
          locale: const Locale('es'),
          supportedLocales: const [Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Root(),
        ),
      );
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) => AppScope.of(context).logged ? const Shell() : const LoginScreen();
}
